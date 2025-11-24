@echo off
echo.
echo ===========================================================================
echo   STARTING GCC RELEASE BUILD
echo ===========================================================================
call "%~dp0unity_build.bat" release gcc "-O3 -march=znver4" "-flto -s" "-O2 --target=avx512knl-i32x16"