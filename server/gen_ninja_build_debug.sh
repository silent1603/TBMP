#!/usr/bin/env bash
# Generate Debug build with Ninja and CMake into `build_debug/`
OUTDIR="${PSScriptRoot:-$(cd "$(dirname "$0")" && pwd)}/build_debug"

mkdir -p "$OUTDIR"

# Check if Ninja is available
if ! command -v ninja &> /dev/null; then
    echo "Error: Ninja not found. Please install Ninja."
    echo "  macOS: brew install ninja"
    echo "  Linux: apt-get install ninja-build (Debian/Ubuntu) or equivalent"
    exit 1
fi

echo "Generating Debug build in $OUTDIR"
echo "Running: cmake -S . -B $OUTDIR -G Ninja -DCMAKE_BUILD_TYPE=Debug"
cmake -S . -B "$OUTDIR" -G Ninja -DCMAKE_BUILD_TYPE=Debug

if [ $? -eq 0 ]; then
    echo "Successfully generated Ninja build files in $OUTDIR"
    echo "To build: cd $OUTDIR && ninja"
else
    echo "Error: CMake configuration failed"
    exit 1
fi
