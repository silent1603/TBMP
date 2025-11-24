@echo off

echo [MSVC Debug] Setting up Visual Studio 2022 (v142) environment...

rem --- Try all common VS2022 editions ------------------------------------------
set "VCVARSALL="

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat"
) else if exist "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" (
    set "VCVARSALL=C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat"
)

if not defined VCVARSALL (
    echo.
    echo [ERROR] Visual Studio 2022 not found!
    echo Please install VS2022 Community/Professional/Enterprise/BuildTools
    pause
    exit /b 1
)

echo [MSVC] Found VS2022 using %VCVARSALL%
call "%VCVARSALL%" x64 >nul

echo.
echo ===========================================================================
echo   STARTING MSVC DEBUG BUILD (v142 toolset)
echo ===========================================================================

call "%~dp0unity_build.bat" debug msvc "" "" "" "" 

