@echo off
:: --------------------------------------------------------------
:: Generate Debug build with Visual Studio 2022 and CMake
:: Output: build files in prj/vs2022/
:: Usage:  gen_debug.bat
:: Requires: CMake 3.18+, Visual Studio 2022 (with ClangCL)
:: --------------------------------------------------------------

setlocal enabledelayedexpansion

set OUT_DIR=%~dp0prj\vs2022
set VS_GENERATOR=Visual Studio 17 2022
set VS_ARCH=x64
set TOOLSET=v142

if not exist "%OUT_DIR%" (
    echo Creating directory: %OUT_DIR%
    mkdir "%OUT_DIR%"
)

echo.
echo Using generator: %VS_GENERATOR% (%VS_ARCH%)
echo Running: cmake -S . -B "%OUT_DIR%" -G "%VS_GENERATOR%" -T %TOOLSET% -A %VS_ARCH% -DCMAKE_BUILD_TYPE=Debug
echo.

cmake -S . -B "%OUT_DIR%" -G "%VS_GENERATOR%" -T %TOOLSET% -A %VS_ARCH% -DCMAKE_BUILD_TYPE=Debug

if %ERRORLEVEL%==0 (
    echo.
    echo Successfully generated Visual Studio 2022 solution in: %OUT_DIR%
    echo To build: msbuild "%OUT_DIR%\ALL_BUILD.vcxproj" /p:Configuration=Debug
    echo Or open the generated .sln file in Visual Studio 2022.
) else (
    echo.
    echo [ERROR] CMake configuration failed.
    exit /b 1
)

endlocal
