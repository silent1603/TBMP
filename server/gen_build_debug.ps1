<#
Generate Debug build with Ninja and CMake into `build_debug/`
Usage:
  .\gen_debug.ps1
Prerequisites:
  - CMake 3.18+
  - Ninja
#>
param(
  [string]$OutDir = "$PSScriptRoot\build_debug"
)

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Check if Ninja is available
$ninjaPath = "$PSScriptRoot/tools/ninja/bin/ninja"
if (Test-Path $ninjaPath) {
    Write-Host "Using Ninja from: $ninjaPath"
    Write-Host "Running: cmake -S . -B $OutDir -G Ninja -DCMAKE_MAKE_PROGRAM=$ninjaPath -DCMAKE_BUILD_TYPE=Debug"
    cmake -S . -B $OutDir -G Ninja -DCMAKE_MAKE_PROGRAM=$ninjaPath -DCMAKE_BUILD_TYPE=Debug
} else {
    if (-not (Get-Command ninja -ErrorAction SilentlyContinue)) {
        Write-Error "Ninja not found in tools/ninja/bin or system PATH. Run setup.ps1 first."
        exit 1
    }
    Write-Host "Running: cmake -S . -B $OutDir -G Ninja -DCMAKE_BUILD_TYPE=Debug"
    cmake -S . -B $OutDir -G Ninja -DCMAKE_BUILD_TYPE=Debug
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully generated Ninja build files in $OutDir"
    Write-Host "To build: cd $OutDir && ninja"
} else {
    Write-Error "CMake configuration failed"
    exit 1
}
