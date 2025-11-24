@echo off
echo.
echo ===========================================================================
echo   STARTING GCC DEBUG BUILD
echo ===========================================================================
call "%~dp0unity_build.bat" debug gcc "-O0 -g" "-g" "--debug --opt=disable-all"