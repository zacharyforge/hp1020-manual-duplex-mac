#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="${1:-$PROJECT_DIR/build}"
APP_NAME="HP1020 Manual Duplex"
APP_PATH="$OUTPUT_DIR/$APP_NAME.app"
CONTENTS="$APP_PATH/Contents"

if [[ -z "$OUTPUT_DIR" || "$OUTPUT_DIR" == "/" ]]; then
  print -u2 "Refusing to use an unsafe output directory."
  exit 2
fi

if [[ -e "$APP_PATH" ]]; then
  /bin/rm -rf "$APP_PATH"
fi

/bin/mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"

CLANG_MODULE_CACHE_PATH="${TMPDIR:-/tmp}/hp1020-manual-duplex-clang-cache" \
  /usr/bin/clang \
  -fobjc-arc \
  -fmodules \
  -O2 \
  -arch arm64 \
  -arch x86_64 \
  -mmacosx-version-min=13.0 \
  -framework Cocoa \
  -framework UniformTypeIdentifiers \
  "$PROJECT_DIR/Sources/main.m" \
  -o "$CONTENTS/MacOS/HP1020ManualDuplex"

/usr/bin/ditto "$PROJECT_DIR/Info.plist" "$CONTENTS/Info.plist"
/usr/bin/ditto "$PROJECT_DIR/Resources/two-page-test.pdf" "$CONTENTS/Resources/two-page-test.pdf"
/usr/bin/ditto "$PROJECT_DIR/Resources/blank-a4.pdf" "$CONTENTS/Resources/blank-a4.pdf"
/usr/bin/ditto "$PROJECT_DIR/Resources/AppIcon.icns" "$CONTENTS/Resources/AppIcon.icns"

/usr/bin/codesign --force --deep --sign - "$APP_PATH"
/usr/bin/codesign --verify --deep --strict "$APP_PATH"

print "$APP_PATH"
