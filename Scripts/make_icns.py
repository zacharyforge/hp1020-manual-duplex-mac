#!/usr/bin/python3
"""Pack modern PNG icon chunks into an ICNS container."""

from pathlib import Path
import struct
import sys


CHUNKS = (
    (b"icp4", "icon_16x16.png"),
    (b"icp5", "icon_32x32.png"),
    (b"icp6", "icon_32x32@2x.png"),
    (b"ic07", "icon_128x128.png"),
    (b"ic08", "icon_256x256.png"),
    (b"ic09", "icon_512x512.png"),
    (b"ic10", "icon_512x512@2x.png"),
)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: make_icns.py ICONSET_DIR OUTPUT.icns", file=sys.stderr)
        return 2

    iconset = Path(sys.argv[1])
    output = Path(sys.argv[2])
    payload = bytearray()

    for chunk_type, filename in CHUNKS:
        png = (iconset / filename).read_bytes()
        if not png.startswith(b"\x89PNG\r\n\x1a\n"):
            raise ValueError(f"{filename} is not a PNG file")
        payload.extend(chunk_type)
        payload.extend(struct.pack(">I", len(png) + 8))
        payload.extend(png)

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(b"icns" + struct.pack(">I", len(payload) + 8) + payload)
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
