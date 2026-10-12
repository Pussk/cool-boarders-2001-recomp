"""Inventory ISO9660 entries without distributing game assets."""
import json
import pathlib
import struct

root = pathlib.Path(__file__).resolve().parent.parent
entries = []
with (root / "disc/coolboarders2001.bin").open("rb") as image:
    def read(lba, size=2048):
        out = bytearray()
        while len(out) < size:
            image.seek(lba * 2352 + 24)
            out.extend(image.read(2048))
            lba += 1
        return bytes(out[:size])

    def directory(lba, size, prefix=""):
        data = read(lba, size)
        pos = 0
        while pos < len(data):
            length = data[pos]
            if not length:
                pos = (pos // 2048 + 1) * 2048
                continue
            record = data[pos:pos + length]
            pos += length
            name = record[33:33 + record[32]]
            if name in (b"\0", b"\1"):
                continue
            name = name.decode("ascii").split(";")[0]
            extent, count = struct.unpack_from("<I", record, 2)[0], struct.unpack_from("<I", record, 10)[0]
            path = prefix + name
            is_dir = bool(record[25] & 2)
            entries.append(dict(path=path, lba=extent, size=count, directory=is_dir,
                                signature=read(extent, min(count, 16)).hex() if not is_dir else ""))
            if is_dir:
                directory(extent, count, path + "/")

    pvd = read(16)
    assert pvd[1:6] == b"CD001"
    record = pvd[156:190]
    directory(struct.unpack_from("<I", record, 2)[0], struct.unpack_from("<I", record, 10)[0])
(root / "disc_inventory.json").write_text(json.dumps(entries, indent=2) + "\n")
print(f"{len(entries)} ISO9660 entries")
