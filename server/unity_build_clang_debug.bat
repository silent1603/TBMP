@echo off
echo.
echo ===========================================================================
echo   STARTING CLANG DEBUG BUILD
echo ===========================================================================
call "%~dp0unity_build.bat" debug clang "-O0 -g" "-g" "--debug --opt=disable-all"