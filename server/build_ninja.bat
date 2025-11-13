@echo off
:: --------------------------------------------------------------
:: Build script using Ninja + Clang (clang/clang++)
:: Usage:
::   build_ninja.bat Debug    -> build Debug
::   build_ninja.bat Release  -> build Release
:: --------------------------------------------------------------

setlocal enabledelayedexpansion

:: --- Parse argument ---
if "%~1"=="" (
    echo [ERROR] Please specify build type: Debug or Release
    exit /b 1
)
set "TARGET_TYPE=%~1"

:: --- Determine build directory ---
if /I "%TARGET_TYPE%"=="Debug" (
    set "TARGET_DIR=%~dp0build_debug"
) else if /I "%TARGET_TYPE%"=="Release" (
    set "TARGET_DIR=%~dp0build_release"
) else (
    echo [ERROR] Unknown build type: %TARGET_TYPE%
    exit /b 1
)

:: --- Set Ninja path ---
set "NINJA_PATH=%~dp0tools\ninja\bin\ninja.exe"

:: --- Check Ninja ---
if not exist "%NINJA_PATH%" (
    where ninja >nul 2>nul
    if %ERRORLEVEL% neq 0 (
        echo [ERROR] Ninja not found. Run setup first.
        exit /b 1
    )
    set "NINJA_PATH=ninja"
)

:: --- Create build directory if missing ---
if not exist "%TARGET_DIR%" (
    echo Creating directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

:: --- Run CMake with Clang ---
echo.
echo Using Ninja: %NINJA_PATH%
echo Running: cmake -S . -B "%TARGET_DIR%" -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=%TARGET_TYPE%
cmake -S . -B "%TARGET_DIR%" -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=%TARGET_TYPE%
if %ERRORLEVEL% neq 0 (
    echo [ERROR] CMake configuration failed.
    exit /b 1
)

:: --- Build with Ninja ---
echo.
echo Building %TARGET_TYPE%...
pushd "%TARGET_DIR%"
"%NINJA_PATH%"
set BUILD_STATUS=%ERRORLEVEL%
popd

if %BUILD_STATUS%==0 (
    echo.
    echo %TARGET_TYPE% build completed successfully!
    echo Output: .\bin\tbmp_server
) else (
    echo.
    echo %TARGET_TYPE% build failed!
    exit /b 1
)

pause
exit /b 0
