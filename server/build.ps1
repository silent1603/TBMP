<#
Build script for both Release and Debug builds
Usage:
  .\build.ps1                    # Build both Release and Debug
  .\build.ps1 -Type Release      # Build only Release
  .\build.ps1 -Type Debug        # Build only Debug
  .\build.ps1 -Clean             # Clean build directories before building
Prerequisites:
  - CMake 3.18+
  - Ninja
#>
param(
  [ValidateSet("Release", "Debug", "Both")]
  [string]$Type = "Both",
  [switch]$Clean
)

function Build-Target {
    param(
        [string]$BuildType,
        [string]$BuildDir
    )
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Building $BuildType" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Generate if not exists or Clean flag set
    if ((Test-Path $BuildDir) -and $Clean) {
        Write-Host "Cleaning $BuildDir"
        Remove-Item -Recurse -Force $BuildDir
    }
    
    if (-not (Test-Path $BuildDir)) {
        Write-Host "Generating $BuildType build configuration..."
        $ninjaPath = "$PSScriptRoot/tools/ninja/bin/ninja"
        if (Test-Path $ninjaPath) {
            cmake -S . -B $BuildDir -G Ninja -DCMAKE_MAKE_PROGRAM=$ninjaPath -DCMAKE_BUILD_TYPE=$BuildType
        } else {
            cmake -S . -B $BuildDir -G Ninja -DCMAKE_BUILD_TYPE=$BuildType
        }
        if ($LASTEXITCODE -ne 0) {
            Write-Error "CMake configuration failed for $BuildType"
            return $false
        }
    }
    
    # Build
    Write-Host "Building with Ninja..."
    cd $BuildDir
    ninja
    $buildSuccess = $LASTEXITCODE -eq 0
    cd ..
    
    if ($buildSuccess) {
        Write-Host "$BuildType build completed successfully!" -ForegroundColor Green
        Write-Host "Output: ./bin/tbmp_server" -ForegroundColor Green
    } else {
        Write-Error "$BuildType build failed"
    }
    
    return $buildSuccess
}

# Check if Ninja is available
$ninjaToolPath = "$PSScriptRoot/tools/ninja/bin/ninja"
if (Test-Path $ninjaToolPath) {
    Write-Host "Using Ninja from: $ninjaToolPath"
} elseif (-not (Get-Command ninja -ErrorAction SilentlyContinue)) {
    Write-Error "Ninja not found in tools/ninja/bin or system PATH. Run setup.ps1 first."
    exit 1
}

$releaseSuccess = $true
$debugSuccess = $true

if ($Type -eq "Release" -or $Type -eq "Both") {
    $releaseSuccess = Build-Target "Release" "$PSScriptRoot\build_release"
}

if ($Type -eq "Debug" -or $Type -eq "Both") {
    $debugSuccess = Build-Target "Debug" "$PSScriptRoot\build_debug"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Build Summary" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

if ($Type -eq "Release" -or $Type -eq "Both") {
    $status = if ($releaseSuccess) { "Success" } else { "Failed" }
    Write-Host "Release: $status" -ForegroundColor $(if ($releaseSuccess) { "Green" } else { "Red" })
}

if ($Type -eq "Debug" -or $Type -eq "Both") {
    $status = if ($debugSuccess) { "Success" } else { "Failed" }
    Write-Host "Debug:   $status" -ForegroundColor $(if ($debugSuccess) { "Green" } else { "Red" })
}

$allSuccess = $releaseSuccess -and $debugSuccess
if (-not $allSuccess) {
    exit 1
}
