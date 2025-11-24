@echo off
setlocal
REM ==== CONFIG ====
set GODOT_VERSION=4.5.1
set PLATFORM=win64
set ZIP=Godot_v%GODOT_VERSION%-stable_mono_%PLATFORM%.zip
REM Note: Binaries are in godot-builds repo, not main godot repo
set URL=https://github.com/godotengine/godot-builds/releases/download/%GODOT_VERSION%-stable/%ZIP%
REM ================
echo Downloading %ZIP%...
curl -L --fail -o "%ZIP%" "%URL%"
if NOT exist "%ZIP%" (
    echo [ERROR] Download failed!
    exit /b 1
)
echo Extracting ZIP...
powershell -Command "Expand-Archive -Path '%ZIP%' -DestinationPath '.' -Force"
echo Locating extracted folder...
for /d %%F in (Godot_v%GODOT_VERSION%-stable_mono_%PLATFORM%*) do set EXTRACTED=%%F
if "%EXTRACTED%"=="" (
    echo [ERROR] Extracted folder not found!
    exit /b 1
)
echo Moving all files out of extracted folder...
xcopy "%EXTRACTED%\*" ".\" /E /H /Y > nul
echo Deleting extracted folder...
rmdir /S /Q "%EXTRACTED%"
echo Renaming executables...
if exist "Godot_v%GODOT_VERSION%-stable_mono_%PLATFORM%.exe" (
    ren "Godot_v%GODOT_VERSION%-stable_mono_%PLATFORM%.exe" "godot.exe"
)
if exist "Godot_v%GODOT_VERSION%-stable_mono_%PLATFORM%_console.exe" (
    ren "Godot_v%GODOT_VERSION%-stable_mono_%PLATFORM%_console.exe" "godot_console.exe"
)
echo Deleting ZIP...
del "%ZIP%"
echo Done!
endlocal