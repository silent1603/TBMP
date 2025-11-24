#!/bin/bash

# ==== CONFIG ====
GODOT_VERSION=4.5.1
PLATFORM=linux_x86_64
ZIP="Godot_v${GODOT_VERSION}-stable_mono_${PLATFORM}.zip"
URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${ZIP}"
# ================

echo "Downloading $ZIP..."
curl -L --fail -o "$ZIP" "$URL"
if [ ! -f "$ZIP" ]; then
    echo "[ERROR] Download failed!"
    exit 1
fi

echo "Extracting ZIP..."
unzip -o "$ZIP"

echo "Finding extracted folder..."
EXTRACTED=$(find . -maxdepth 1 -type d -name "Godot_v${GODOT_VERSION}-stable_mono_${PLATFORM}*" | head -n 1)

if [ -z "$EXTRACTED" ]; then
    echo "[ERROR] Extracted folder not found!"
    exit 1
fi

echo "Moving all files out of extracted folder..."
mv "$EXTRACTED"/* .

echo "Removing extracted folder..."
rm -rf "$EXTRACTED"

echo "Renaming executables..."
# GUI editor
if [ -f "Godot_v${GODOT_VERSION}-stable_mono_${PLATFORM}.x8]()
