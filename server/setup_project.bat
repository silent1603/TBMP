@echo off
setlocal ENABLEDELAYEDEXPANSION

rem ============================================================
rem  setup.bat — Download and extract ISPC and Ninja for Windows
rem  Usage: run from repository's "server" folder
rem ============================================================

set ISPC_VERSION=v1.28.2
set NINJA_VERSION=v1.12.1
set DEST_TOOLS=%~dp0tools
set DEST_BIN=%~dp0bin
set ISPC_URL=
set NINJA_URL=

echo Running setup.bat (ISPC = %ISPC_VERSION%, Ninja = %NINJA_VERSION%)

rem ---- Detect OS (this script is Windows-only) ----
set SETUP_IS_WINDOWS=1

if not exist "%DEST_TOOLS%" mkdir "%DEST_TOOLS%"
if not exist "%DEST_BIN%" mkdir "%DEST_BIN%"

rem ===== ISPC Setup =====
if "%ISPC_URL%"=="" (
    set ISPC_URL=https://github.com/ispc/ispc/releases/download/%ISPC_VERSION%/ispc-%ISPC_VERSION%-windows.zip
)
echo.
echo Downloading ISPC from: %ISPC_URL%

set TMP_DIR=%TEMP%\ispc_%RANDOM%_%TIME:~6,5%
set ZIP_PATH=%TMP_DIR%.zip
set EXTRACT_DIR=%TMP_DIR%_extract

powershell -Command "Invoke-WebRequest -Uri '%ISPC_URL%' -OutFile '%ZIP_PATH%' -UseBasicParsing"
if errorlevel 1 (
    echo [ERROR] Failed to download ISPC
    exit /b 1
)

echo Extracting ISPC...
powershell -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%EXTRACT_DIR%' -Force"

for /f "delims=" %%A in ('dir /b /ad "%EXTRACT_DIR%"') do set EXTRACTED_FOLDER=%%A

set ISPC_ROOT=%DEST_TOOLS%\ispc
if exist "%ISPC_ROOT%" rmdir /s /q "%ISPC_ROOT%"
mkdir "%ISPC_ROOT%"

xcopy "%EXTRACT_DIR%\%EXTRACTED_FOLDER%\*" "%ISPC_ROOT%\" /E /I /Y >nul

:ispc_done

rem Cleanup
del "%ZIP_PATH%" >nul 2>&1
rmdir /s /q "%EXTRACT_DIR%" >nul 2>&1

rem ===== Ninja Setup =====
echo.
echo === Installing Ninja ===
if "%NINJA_URL%"=="" (
    set NINJA_URL=https://github.com/ninja-build/ninja/releases/download/%NINJA_VERSION%/ninja-win.zip
)
echo Downloading Ninja from: %NINJA_URL%

set NINJA_ARCHIVE=%TEMP%\ninja_%RANDOM%.zip
set NINJA_EXTRACT=%TEMP%\ninja_extract_%RANDOM%

powershell -Command "Invoke-WebRequest -Uri '%NINJA_URL%' -OutFile '%NINJA_ARCHIVE%' -UseBasicParsing"
if errorlevel 1 (
    echo [ERROR] Failed to download Ninja
    exit /b 1
)

echo Extracting Ninja...
powershell -Command "Expand-Archive -Path '%NINJA_ARCHIVE%' -DestinationPath '%NINJA_EXTRACT%' -Force"

set NINJA_TOOL_DIR=%DEST_TOOLS%\ninja
set NINJA_BIN_DIR=%NINJA_TOOL_DIR%\bin

if not exist "%NINJA_BIN_DIR%" mkdir "%NINJA_BIN_DIR%"

del "%NINJA_ARCHIVE%" >nul 2>&1
rmdir /s /q "%NINJA_EXTRACT%" >nul 2>&1

echo.
echo Setup completed successfully.
pause
endlocal
exit /b 0
