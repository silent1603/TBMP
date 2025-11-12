#!/usr/bin/env bash
# setup.sh - download and install ISPC and Ninja into tools/ and copy binaries to bin/
# Usage: ./setup.sh [<ispc_version>] [<ninja_version>]

set -euo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ISPC_VERSION=${1:-v1.28.2}
NINJA_VERSION=${2:-v1.12.1}
TOOLS_DIR="${SCRIPT_DIR}/tools"
BIN_DIR="${SCRIPT_DIR}/bin"
ISPC_ROOT="${TOOLS_DIR}/ispc"
NINJA_ROOT="${TOOLS_DIR}/ninja"

echo "Setup ISPC (version: ${ISPC_VERSION}) and Ninja (version: ${NINJA_VERSION})"

# Ensure directories exist
if [ ! -d "${TOOLS_DIR}" ]; then
  mkdir -p "${TOOLS_DIR}"
  echo "Created ${TOOLS_DIR}"
else
  echo "Found ${TOOLS_DIR}"
fi

if [ ! -d "${BIN_DIR}" ]; then
  mkdir -p "${BIN_DIR}"
  echo "Created ${BIN_DIR}"
else
  echo "Found ${BIN_DIR}"
fi

# Detect OS (Linux or macOS). This script is for UNIX-like systems.
OSNAME=$(uname -s)
case "$OSNAME" in
  Darwin)
    ISPC_ARCHIVE_EXT=tar.gz
    ISPC_URL="https://github.com/ispc/ispc/releases/download/${ISPC_VERSION}/ispc-${ISPC_VERSION}-macos.tar.gz"
    NINJA_URL="https://github.com/ninja-build/ninja/releases/download/${NINJA_VERSION}/ninja-mac.zip"
    ;;
  Linux)
    ISPC_ARCHIVE_EXT=tar.gz
    ISPC_URL="https://github.com/ispc/ispc/releases/download/${ISPC_VERSION}/ispc-${ISPC_VERSION}-linux.tar.gz"
    NINJA_URL="https://github.com/ninja-build/ninja/releases/download/${NINJA_VERSION}/ninja-linux.zip"
    ;;
  *)
    echo "Unsupported OS for this script: $OSNAME" >&2
    echo "Use the PowerShell script on Windows or adapt this script." >&2
    exit 1
    ;;
esac

echo "ISPC URL: $ISPC_URL"
echo "Ninja URL: $NINJA_URL"

# ===== ISPC Installation =====
echo ""
echo "=== Installing ISPC ==="
TMPDIR=$(mktemp -d)
ISPC_ARCHIVE_NAME="$TMPDIR/ispc_download.$ISPC_ARCHIVE_EXT"

if [ "${ISPC_ARCHIVE_EXT}" = "zip" ]; then
  curl -L -o "$ISPC_ARCHIVE_NAME" "$ISPC_URL"
  unzip -q "$ISPC_ARCHIVE_NAME" -d "$TMPDIR"
else
  curl -L -o "$ISPC_ARCHIVE_NAME" "$ISPC_URL"
  tar -xzf "$ISPC_ARCHIVE_NAME" -C "$TMPDIR"
fi

# Normalize extracted contents into tools/ispc
if [ -d "$ISPC_ROOT" ]; then
  rm -rf "$ISPC_ROOT"
fi

# If extraction created a single top-level directory that starts with 'ispc',
# move/rename it to tools/ispc. Otherwise create tools/ispc and move contents.
top_entries=("$TMPDIR"/*)
if [ ${#top_entries[@]} -eq 1 ] && [[ "${top_entries[0]}" == *ispc* ]]; then
  mv "${top_entries[0]}" "$ISPC_ROOT"
else
  mkdir -p "$ISPC_ROOT"
  # move everything except the tmp dir itself
  for f in "$TMPDIR"/*; do
    mv "$f" "$ISPC_ROOT/" 2>/dev/null || true
  done
fi

# Locate the ispc binary under tools/ispc (prefer tools/ispc/bin)
ISPC_BIN=""
if [ -x "$ISPC_ROOT/bin/ispc" ]; then
  ISPC_BIN="$ISPC_ROOT/bin/ispc"
elif [ -x "$ISPC_ROOT/ispc" ]; then
  ISPC_BIN="$ISPC_ROOT/ispc"
else
  # fallback: find any file named 'ispc'
  ISPC_BIN=$(find "$ISPC_ROOT" -type f -iname "ispc" -print -quit || true)
fi

if [ -n "$ISPC_BIN" ]; then
  echo "Found ISPC binary: $ISPC_BIN"
  # ensure tools/ispc/bin exists
  mkdir -p "$ISPC_ROOT/bin"
  cp "$ISPC_BIN" "$ISPC_ROOT/bin/ispc"
  cp "$ISPC_BIN" "$ISPC_ROOT/ispc" 2>/dev/null || true
  chmod +x "$ISPC_ROOT/bin/ispc" || true
  echo "Installed ispc -> ${ISPC_ROOT}/bin/ispc"
else
  echo "ERROR: could not find ispc binary under extracted archive. Please extract manually into ${ISPC_ROOT} and ensure bin/ispc exists." >&2
  rm -rf "$TMPDIR"
  exit 2
fi

# cleanup
rm -rf "$TMPDIR"

# ===== Ninja Installation =====
echo ""
echo "=== Installing Ninja ==="
NINJA_TMPDIR=$(mktemp -d)
NINJA_ARCHIVE_NAME="$NINJA_TMPDIR/ninja_download.zip"

# Ninja is always distributed as zip
curl -L -o "$NINJA_ARCHIVE_NAME" "$NINJA_URL"
unzip -q "$NINJA_ARCHIVE_NAME" -d "$NINJA_TMPDIR"

# Find ninja binary
NINJA_BIN=$(find "$NINJA_TMPDIR" -type f -name "ninja" -print -quit || true)

if [ -n "$NINJA_BIN" ]; then
  echo "Found Ninja binary: $NINJA_BIN"
  mkdir -p "$NINJA_ROOT/bin"
  cp "$NINJA_BIN" "$NINJA_ROOT/bin/ninja"
  chmod +x "$NINJA_ROOT/bin/ninja" || true
  echo "Installed Ninja -> ${NINJA_ROOT}/bin/ninja"
else
  echo "ERROR: could not find ninja binary in downloaded archive." >&2
  rm -rf "$NINJA_TMPDIR"
  exit 2
fi

# cleanup
rm -rf "$NINJA_TMPDIR"
  echo "ERROR: could not find ispc binary under extracted archive. Please extract manually into ${ISPC_ROOT} and ensure bin/ispc exists." >&2
  rm -rf "$TMPDIR"
  exit 2
fi

# cleanup
rm -rf "$TMPDIR"

echo "Setup completed."
