"""Make the local build executable runnable directly from Explorer."""
import pathlib
import re
import sys
import tomllib
import json

root = pathlib.Path(__file__).resolve().parent.parent
text = (root / "game.toml").read_text(encoding="utf-8-sig")
config = tomllib.loads(text)
for field in ("exe", "disc"):
    value = (root / config["game"][field]).resolve().as_posix()
    text = re.sub(rf'(?m)^{field} = .*$', f"{field} = {json.dumps(value)}", text)
target = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else root / "build/game.toml"
target.write_text(text, encoding="utf-8")
print(f"Staged local runtime config: {target}")
