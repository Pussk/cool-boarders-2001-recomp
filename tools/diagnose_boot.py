"""Boot once and record native debug state and a rendered frame if available."""
import json
import argparse
import pathlib
import subprocess
import sys
import time

root = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(root / "psxrecomp/tools"))
from debug_client import query

port = 19497
args = [str(root / "build/Cool_Boarders_2001_Recompiled.exe"),
        "--game", str(root / "game.toml"), "--disc", str(root / "disc/coolboarders2001.cue"),
        "--bios", str(root / "psxrecomp/bios/openbios.bin"), "--headless",
        "--debug-port", str(port), "--memcard-dir", str(root / "analysis/smoke-saves")]
(root / "analysis").mkdir(exist_ok=True)
results = []
parser = argparse.ArgumentParser()
parser.add_argument("--advance", action="store_true")
parser.add_argument("--samples", type=int, default=3)
parser.add_argument("--race", action="store_true")
parser.add_argument("--reference", action="store_true")
parser.add_argument("--window-check", action="store_true")
options = parser.parse_args()
if options.window_check:
    args[args.index("--headless")] = "--hidden-window"
    args.extend(["--renderer", "software"])
with (root / "analysis/diagnostic_boot.log").open("wb") as log:
    process = subprocess.Popen(args, cwd=root, stdout=log, stderr=subprocess.STDOUT)
    try:
        for attempt in range(20):
            if process.poll() is not None:
                break
            try:
                response = query("127.0.0.1", port, {"id": 1, "cmd": "ping"}, timeout=1)
                results.append(response)
                if options.reference:
                    results.append(query("127.0.0.1", port, {"id": 1, "cmd": "overlay_native_off"}, timeout=2))
                break
            except OSError:
                time.sleep(1)
        for sample in range(options.samples):
            if process.poll() is not None:
                break
            time.sleep(5)
            if sample == 0 and options.advance:
                # The supplied disc's intro offers Circle for NTSC (active-low pad).
                results.append(query("127.0.0.1", port, {"id": 1, "cmd": "set_input", "buttons": "0xDFFF"}, timeout=2))
                time.sleep(0.25)
                query("127.0.0.1", port, {"id": 1, "cmd": "clear_input"}, timeout=2)
            if options.advance and sample in (2, 4, 6, 8):
                query("127.0.0.1", port, {"id": 1, "cmd": "set_input", "buttons": "0xFFF7"}, timeout=2)
                time.sleep(0.25)
                query("127.0.0.1", port, {"id": 1, "cmd": "clear_input"}, timeout=2)
            if options.race and sample >= (4 if options.reference else 8):
                query("127.0.0.1", port, {"id": 1, "cmd": "set_input", "buttons": "0xBFFF"}, timeout=2)
                time.sleep(1)
                results.append({"sample": sample, "command": "pad_status", "response": query("127.0.0.1", port, {"id": 1, "cmd": "pad_status"}, timeout=2)})
                query("127.0.0.1", port, {"id": 1, "cmd": "clear_input"}, timeout=2)
            for command in ("ping", "get_registers", "gpu_state", "overlay_loader_status", "autocompile_status"):
                try:
                    results.append({"sample": sample, "command": command,
                                    "response": query("127.0.0.1", port, {"id": 1, "cmd": command}, timeout=2)})
                except OSError as error:
                    results.append({"command": command, "error": str(error)})
        try:
            results.append(query("127.0.0.1", port, {"id": 1, "cmd": "screenshot_file",
                                                    "path": str(root / "analysis/boot.png").replace("\\", "/")}, timeout=2))
            query("127.0.0.1", port, {"id": 1, "cmd": "quit"}, timeout=2)
            process.wait(timeout=3)
        except (OSError, subprocess.TimeoutExpired):
            pass
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()
(root / "analysis/diagnostic_boot.json").write_text(json.dumps(results, indent=2) + "\n")
print(json.dumps(results))
