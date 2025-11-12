# TBMP Server - Build Guide

A C/ISPC project built with CMake and Ninja, featuring Intel ISPC for high-performance computing kernels.

## Prerequisites

- **CMake** 3.18+ ([download](https://cmake.org/download/))
- **Ninja** (installed via `setup.ps1` or `setup.sh`)
- **ISPC** (installed via `setup.ps1` or `setup.sh`)
- **C Compiler**: 
  - Windows: MSVC (Visual Studio Build Tools)
  - macOS: Clang (Xcode Command Line Tools)
  - Linux: GCC

## Quick Start

### 1. Install Tools (ISPC + Ninja)

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**macOS/Linux (Bash):**
```bash
./setup.sh
```

This will download and install:
- ISPC compiler → `tools/ispc/`
- Ninja build tool → `tools/ninja/`
- Copies executables to `bin/`

### 2. Generate Build Configuration

**Windows:**
```powershell
# Generate Release build
.\gen_release.ps1

# Or generate Debug build
.\gen_debug.ps1

# Or use the master build script for both
.\build.ps1
```

**macOS/Linux:**
```bash
# Generate Release build
./gen_release.sh

# Or generate Debug build
./gen_debug.sh

# Or use the master build script for both
./build.sh
```

### 3. Build the Project

**Using the master build script (Recommended):**

Windows:
```powershell
.\build.ps1                    # Build both Release and Debug
.\build.ps1 -Type Release      # Build only Release
.\build.ps1 -Type Debug        # Build only Debug
.\build.ps1 -Clean             # Clean and rebuild
```

macOS/Linux:
```bash
./build.sh                     # Build both Release and Debug
./build.sh release             # Build only Release
./build.sh debug               # Build only Debug
./build.sh clean               # Clean and rebuild
```

**Manual build:**
```bash
cd build_release
ninja

# or for debug
cd build_debug
ninja
```

## Project Structure

```
server/
├── CMakeLists.txt              # Main CMake configuration
├── setup.ps1                   # Windows tool installer
├── setup.sh                    # macOS/Linux tool installer
├── gen_release.ps1             # Generate Release build (Windows)
├── gen_debug.ps1               # Generate Debug build (Windows)
├── gen_release.sh              # Generate Release build (Unix)
├── gen_debug.sh                # Generate Debug build (Unix)
├── build.ps1                   # Master build script (Windows)
├── build.sh                    # Master build script (Unix)
├── sources/
│   ├── main.c                  # Entry point
│   ├── foo.c                   # Helper functions
│   ├── foo.h                   # Function declarations
│   └── kernels.ispc            # ISPC kernels
├── tools/
│   ├── ispc/                   # ISPC compiler (installed)
│   └── ninja/                  # Ninja build tool (installed)
├── bin/                        # Output executables and libraries
├── build_release/              # Release build artifacts
└── build_debug/                # Debug build artifacts
```

## Build Output

All binaries are placed in `bin/`:
- `tbmp_server` - Main executable
- `ispc` - ISPC compiler binary
- `ninja` - Ninja build tool binary

Debug information is included in all builds:
- **Windows**: `.pdb` files (Program Database)
- **macOS/Linux**: Debug symbols embedded in binaries

## Configuration

### CMake Options

Edit `CMakeLists.txt` to customize:
- **ISPC Target**: Change `--target=sse2-i32x4` to other targets (avx2, neon-i32x4, etc.)
- **Build Type**: Debug or Release (set via `-DCMAKE_BUILD_TYPE`)

### ISPC Compiler Flags

- `--target=sse2-i32x4` - CPU instruction set
- `-O0` / `-O2` - Optimization level
- `-g` - Debug information

## Troubleshooting

### "Ninja not found"
Run `setup.ps1` or `setup.sh` to install Ninja into tools folder.

### "ISPC not found"
Run `setup.ps1` or `setup.sh` to install ISPC into tools folder.

### CMake configuration fails
Ensure you have a compatible C compiler installed:
- Windows: Visual Studio Build Tools
- macOS: `xcode-select --install`
- Linux: `sudo apt-get install build-essential` (Debian/Ubuntu)

### Build errors with ISPC
- Verify ISPC binary exists: `bin/ispc --version`
- Check ISPC target architecture is supported on your CPU

## VS Code Integration

### Build Tasks

VS Code tasks are configured in `.vscode/tasks.json`. Use:
- `Ctrl+Shift+B` (Windows/Linux) or `Cmd+Shift+B` (macOS) to open task picker
- Select from available build tasks

Available tasks:
- **Build Release** - Build Release configuration
- **Build Debug** - Build Debug configuration
- **Clean & Build** - Clean and rebuild both

## Development Tips

- **Fast iteration**: Use Debug build for testing during development
- **Deployment**: Use Release build for production
- **Debug symbols**: Included in all builds for debugging

## License

See LICENSE file for details.
