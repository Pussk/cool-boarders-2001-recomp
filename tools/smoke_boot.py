"""Bounded unattended boot; save logs without claiming gameplay validation."""
import json
import pathlib
import subprocess
import time

root = pathlib.Path(__file__).resolve().parent.parent
args = [str(root / "build/Cool_Boarders_2001_Recompiled.exe"),
        "--game", str(root / "game.toml"), "--disc", str(root / "disc/coolboarders2001.cue"),
        "--bios", str(root / "psxrecomp/bios/openbios.bin"), "--headless",
        "--memcard-dir", str(root / "analysis/smoke-saves")]
(root / "analysis").mkdir(exist_ok=True)
start = time.monotonic()
with (root / "analysis/boot.log").open("wb") as log:
    process = subprocess.Popen(args, cwd=root, stdout=log, stderr=subprocess.STDOUT)
    timeout = False
    try:
        process.wait(timeout=30)
    except subprocess.TimeoutExpired:
        timeout = True
        process.kill()
        process.wait()
report = dict(exit_code=process.returncode, timeout=timeout,
              seconds=round(time.monotonic() - start, 2),
              note="A 30-second boot probe does not establish playable status.")
(root / "analysis/boot_result.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report))
