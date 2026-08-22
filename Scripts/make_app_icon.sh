#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SOURCE_SVG="${1:-$PROJECT_DIR/Resources/AppIcon.svg}"
OUTPUT_ICNS="${2:-$PROJECT_DIR/Resources/AppIcon.icns}"
MAGICK="/opt/homebrew/bin/magick"

if [[ ! -x "$MAGICK" ]]; then
  MAGICK="$(command -v magick || true)"
fi
if [[ -z "$MAGICK" || ! -x "$MAGICK" ]]; then
  print -u2 "ImageMagick is required to regenerate the app icon."
  exit 1
fi

WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/HP1020AppIcon.XXXXXX")"
ICONSET="$WORK_DIR/AppIcon.iconset"
trap '/bin/rm -rf "$WORK_DIR"' EXIT
/bin/mkdir -p "$ICONSET"

for entry in \
  "icon_16x16.png:16" \
  "icon_16x16@2x.png:32" \
  "icon_32x32.png:32" \
  "icon_32x32@2x.png:64" \
  "icon_128x128.png:128" \
  "icon_128x128@2x.png:256" \
  "icon_256x256.png:256" \
  "icon_256x256@2x.png:512" \
  "icon_512x512.png:512" \
  "icon_512x512@2x.png:1024"
do
  NAME="${entry%%:*}"
  SIZE="${entry##*:}"
  "$MAGICK" -background none "$SOURCE_SVG" -resize "${SIZE}x${SIZE}" -strip -depth 8 "$ICONSET/$NAME"
done

/usr/bin/python3 "$SCRIPT_DIR/make_icns.py" "$ICONSET" "$OUTPUT_ICNS"
