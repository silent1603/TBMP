#!/usr/bin/env bash
# Build script for both Release and Debug builds
# Usage:
#   ./build.sh                    # Build both Release and Debug
#   ./build.sh release            # Build only Release
#   ./build.sh debug              # Build only Debug
#   ./build.sh clean              # Clean build directories before building
# Prerequisites:
#   - CMake 3.18+
#   - Ninja

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_TYPE="${1:-both}"
RELEASE_DIR="$SCRIPT_DIR/build_release"
DEBUG_DIR="$SCRIPT_DIR/build_debug"
NINJA_BIN="$SCRIPT_DIR/tools/ninja/bin/ninja"

build_target() {
    local type=$1
    local dir=$2
    
    echo ""
    echo "========================================"
    echo "Building $type"
    echo "========================================""
    echo ""
    
    # Generate if not exists
    if [ ! -d "$dir" ]; then
        echo "Generating $type build configuration..."
        if [ -f "$NINJA_BIN" ]; then
            cmake -S "$SCRIPT_DIR" -B "$dir" -G Ninja -DCMAKE_MAKE_PROGRAM="$NINJA_BIN" -DCMAKE_BUILD_TYPE="$type"
        else
            cmake -S "$SCRIPT_DIR" -B "$dir" -G Ninja -DCMAKE_BUILD_TYPE="$type"
        fi
        if [ $? -ne 0 ]; then
            echo "Error: CMake configuration failed for $type"
            return 1
        fi
    fi
    
    # Build
    echo "Building with Ninja..."
    cd "$dir"
    ninja
    local build_status=$?
    cd "$SCRIPT_DIR"
    
    if [ $build_status -eq 0 ]; then
        echo "$type build completed successfully!" 
        echo "Output: ./bin/tbmp_server"
        return 0
    else
        echo "Error: $type build failed"
        return 1
    fi
}

# Check if Ninja is available
if [ -f "$NINJA_BIN" ]; then
    echo "Using Ninja from: $NINJA_BIN"
elif ! command -v ninja &> /dev/null; then
    echo "Error: Ninja not found in tools/ninja/bin or system PATH."
    echo "Run ./setup.sh first to download and install Ninja."
    exit 1
fi

# Handle clean flag
if [ "$BUILD_TYPE" = "clean" ]; then
    echo "Cleaning build directories..."
    rm -rf "$RELEASE_DIR" "$DEBUG_DIR"
    BUILD_TYPE="both"
fi

RELEASE_SUCCESS=0
DEBUG_SUCCESS=0

if [ "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "both" ]; then
    build_target "Release" "$RELEASE_DIR"
    RELEASE_SUCCESS=$?
fi

if [ "$BUILD_TYPE" = "debug" ] || [ "$BUILD_TYPE" = "both" ]; then
    build_target "Debug" "$DEBUG_DIR"
    DEBUG_SUCCESS=$?
fi

echo ""
echo "========================================"
echo "Build Summary"
echo "========================================""
echo ""

if [ "$BUILD_TYPE" = "release" ] || [ "$BUILD_TYPE" = "both" ]; then
    if [ $RELEASE_SUCCESS -eq 0 ]; then
        echo "Release: ✓ Success"
    else
        echo "Release: ✗ Failed"
    fi
fi

if [ "$BUILD_TYPE" = "debug" ] || [ "$BUILD_TYPE" = "both" ]; then
    if [ $DEBUG_SUCCESS -eq 0 ]; then
        echo "Debug:   ✓ Success"
    else
        echo "Debug:   ✗ Failed"
    fi
fi

if [ $RELEASE_SUCCESS -ne 0 ] || [ $DEBUG_SUCCESS -ne 0 ]; then
    exit 1
fi
