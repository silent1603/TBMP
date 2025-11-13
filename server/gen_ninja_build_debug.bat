@echo off
:: --------------------------------------------------------------
:: Generate Debug build with Ninja and CMake
:: Output: build files in build_debug/
:: Usage:  gen_debug.bat
:: Requires: CMake 3.18+ and Ninja
:: --------------------------------------------------------------

setlocal enabledelayedexpansion

set OUT_DIR=%~dp0build_debug
set NINJA_PATH=%~dp0tools\ninja\bin\ninja.exe

if not exist "%OUT_DIR%" (
    echo Creating directory: %OUT_DIR%
    mkdir "%OUT_DIR%"
)

echo.
if exist "%NINJA_PATH%" (
    echo Using Ninja from: %NINJA_PATH%
    echo Running: cmake -S . -B "%OUT_DIR%" -G Ninja -DCMAKE_MAKE_PROGRAM=%NINJA_PATH% -DCMAKE_BUILD_TYPE=Debug
    cmake -S . -B "%OUT_DIR%" -G Ninja -DCMAKE_MAKE_PROGRAM=%NINJA_PATH% -DCMAKE_BUILD_TYPE=Debug
) else (
    where ninja >nul 2>nul
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Ninja not found in tools\ninja\bin or system PATH. Run setup first.
        exit /b 1
    )
    echo Using system Ninja.
    echo Running: cmake -S . -B "%OUT_DIR%" -G Ninja -DCMAKE_BUILD_TYPE=Debug
    cmake -S . -B "%OUT_DIR%" -G Ninja -DCMAKE_BUILD_TYPE=Debug
)

echo.
echo Debug build generation completed!
pause
