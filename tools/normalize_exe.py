"""Keep the disc EXE intact and extract only its declared load image."""
import pathlib
import struct

root = pathlib.Path(__file__).resolve().parent.parent
source = root / "disc/SCUS_945.97"
data = source.read_bytes()
assert data[:8] == b"PS-X EXE", "Invalid PS-X EXE"
size = 2048 + struct.unpack_from("<I", data, 0x1C)[0]
assert len(data) >= size, "Truncated executable"
target = source.parent / "normalized" / source.name
target.parent.mkdir(parents=True, exist_ok=True)
target.write_bytes(data[:size])
print(f"{len(data)} -> {size} bytes; preserved {source.name}")
