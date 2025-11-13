<#
Generate Debug build with Visual Studio 2022 and CMake into `build_debug/`
Usage:
  .\gen_debug.ps1
Prerequisites:
  - CMake 3.18+
  - Visual Studio 2022 (MSVC)
#>

param(
  [string]$OutDir = "$PSScriptRoot\prj\vs2022"
)

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Path $OutDir | Out-Null
}

$vsGenerator = "Visual Studio 17 2022"
$vsArch = "x64"

Write-Host "Using generator: $vsGenerator ($vsArch)"
Write-Host "Running: cmake -S . -B $OutDir -G `"$vsGenerator`" -A $vsArch -DCMAKE_BUILD_TYPE=Debug"

cmake -S . -B $OutDir -G "$vsGenerator" -A $vsArch -DCMAKE_BUILD_TYPE=Debug

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nSuccessfully generated Visual Studio 2022 solution in: $OutDir"
    Write-Host "To build: msbuild $OutDir\\ALL_BUILD.vcxproj /p:Configuration=Debug"
    Write-Host "Or open the generated .sln file in Visual Studio 2022."
} else {
    Write-Error "CMake configuration failed."
    exit 1
}
