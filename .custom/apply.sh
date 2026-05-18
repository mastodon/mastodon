#!/bin/bash
set -euo pipefail

CUSTOM_DIR="${1:-.custom}"
SOURCE_DIR="${2:-.}"

echo "==> Applying custom patches to $SOURCE_DIR from $CUSTOM_DIR"

# 1. Apply git patches (character limit, themes config)
for patch in "$CUSTOM_DIR/patches/"*.patch; do
  [ -f "$patch" ] || continue
  echo "  Applying patch: $(basename "$patch")"
  git -C "$SOURCE_DIR" apply "$patch" --verbose
done

# 2. Copy theme SCSS files
echo "  Copying Tangerine UI theme files..."
cp -r "$CUSTOM_DIR/themes/"* "$SOURCE_DIR/app/javascript/styles/"

# 3. Copy locale files
echo "  Copying locale files..."
cp "$CUSTOM_DIR/locales/"*.yml "$SOURCE_DIR/config/locales/"

echo "==> All customizations applied successfully"
