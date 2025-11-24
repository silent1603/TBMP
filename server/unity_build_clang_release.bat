@echo off
echo.
echo ===========================================================================
echo   STARTING CLANG RELEASE BUILD
echo ===========================================================================
call "%~dp0unity_build.bat" release clang "-O3 -march=znver4" "-flto -s" "-O2 --target=avx512knl-i32x16"    
