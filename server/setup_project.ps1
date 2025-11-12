<#
PowerShell setup script to download ISPC and Ninja, place them into tools/ and bin/
Usage: run from repository's `server` folder (PowerShell elevated not required):
  .\setup.ps1
#>
param(
  [string]$IspcVersion = "v1.28.2",
  [string]$NinjaVersion = "v1.12.1",
  [string]$DestTools = "$PSScriptRoot\tools",
  [string]$DestBin = "$PSScriptRoot\bin",
  [string]$IspcUrl = "",
  [string]$NinjaUrl = ""
)

Write-Host "Running setup.ps1 (ISPC = $IspcVersion, Ninja = $NinjaVersion)"

# Determine OS in a robust way (works in Windows PowerShell and PowerShell Core)
try {
  $Setup_IsWindows  = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)
  $Setup_IsMacOS    = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)
  $Setup_IsLinux    = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Linux)
} catch {
  # Fallback: assume Windows when detection API unavailable
  $Setup_IsWindows = $true
  $Setup_IsMacOS = $false
  $Setup_IsLinux = $false
}

if (-not (Test-Path $DestTools)) { New-Item -ItemType Directory -Path $DestTools | Out-Null }
if (-not (Test-Path $DestBin)) { New-Item -ItemType Directory -Path $DestBin | Out-Null }

# ===== ISPC Setup =====
if (-not $IspcUrl) {
  # Choose platform-appropriate default archive when URL not provided
  if ($Setup_IsWindows) {
    $IspcUrl = "https://github.com/ispc/ispc/releases/download/$IspcVersion/ispc-$IspcVersion-windows.zip"
  } elseif ($Setup_IsMacOS) {
    $IspcUrl = "https://github.com/ispc/ispc/releases/download/$IspcVersion/ispc-$IspcVersion-macos.tar.gz"
  } elseif ($Setup_IsLinux) {
    $IspcUrl = "https://github.com/ispc/ispc/releases/download/$IspcVersion/ispc-$IspcVersion-linux.tar.gz"
  } else {
    Write-Warning "Unknown OS; defaulting to Windows archive URL"
    $IspcUrl = "https://github.com/ispc/ispc/releases/download/$IspcVersion/ispc-$IspcVersion-windows.zip"
  }
}

Write-Host "`nDownloading ISPC from: $IspcUrl"

# ===== Ninja Setup =====
if (-not $NinjaUrl) {
  # Choose platform-appropriate Ninja archive
  if ($Setup_IsWindows) {
    $NinjaUrl = "https://github.com/ninja-build/ninja/releases/download/$NinjaVersion/ninja-win.zip"
  } elseif ($Setup_IsMacOS) {
    $NinjaUrl = "https://github.com/ninja-build/ninja/releases/download/$NinjaVersion/ninja-mac.zip"
  } elseif ($Setup_IsLinux) {
    $NinjaUrl = "https://github.com/ninja-build/ninja/releases/download/$NinjaVersion/ninja-linux.zip"
  } else {
    Write-Warning "Unknown OS; defaulting to Windows Ninja archive URL"
    $NinjaUrl = "https://github.com/ninja-build/ninja/releases/download/$NinjaVersion/ninja-win.zip"
  }
}

Write-Host "Downloading Ninja from: $NinjaUrl"

$archive = Join-Path $env:TEMP "ispc_download_$([Guid]::NewGuid().ToString())"
$zipPath = "$archive.zip"
$tgzPath = "$archive.tar.gz"
$extractDir = Join-Path $env:TEMP "ispc_extract_$([Guid]::NewGuid().ToString())"

$ninjaArchive = Join-Path $env:TEMP "ninja_download_$([Guid]::NewGuid().ToString()).zip"
$ninjaExtractDir = Join-Path $env:TEMP "ninja_extract_$([Guid]::NewGuid().ToString())"

try {
  if (Test-Path $extractDir) { Remove-Item -Recurse -Force $extractDir }
  New-Item -ItemType Directory -Path $extractDir | Out-Null

  if ($IspcUrl -like "*.zip") {
    Invoke-WebRequest -Uri $IspcUrl -OutFile $zipPath -UseBasicParsing
    Write-Host "Extracting zip to temporary folder"
    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
  } else {
    # assume tar.gz
    Invoke-WebRequest -Uri $IspcUrl -OutFile $tgzPath -UseBasicParsing
    Write-Host "Extracting tar.gz to temporary folder"
    # Use tar if available
    if (Get-Command tar -ErrorAction SilentlyContinue) {
      tar -xzf $tgzPath -C $extractDir
    } else {
      Write-Error "tar not found; please extract $tgzPath into $extractDir manually"
      exit 2
    }
  }

  # Normalize extracted folder: determine the actual extracted root inside the temp dir
  $extractedTop = Get-ChildItem -Path $extractDir -Directory -ErrorAction SilentlyContinue
  $ispcRoot = Join-Path $DestTools 'ispc'

  if ($extractedTop.Count -eq 1 -and ($extractedTop[0].Name -match '^ispc')) {
    $sourceRoot = $extractedTop[0].FullName
  } else {
    # Use the temp extract directory as the source root
    $sourceRoot = $extractDir
  }

  # Remove any existing tools/ispc and move the extracted files there
  if (Test-Path $ispcRoot) { Remove-Item -Recurse -Force $ispcRoot }
  New-Item -ItemType Directory -Path $ispcRoot | Out-Null
  Get-ChildItem -Path $sourceRoot -Force | ForEach-Object {
    try { Move-Item -Path $_.FullName -Destination $ispcRoot -Force } catch { }
  }

  # Now look for the ispc binary under tools/ispc (prefer tools/ispc/bin)
  $binCandidates = @()
  $binDir = Join-Path $ispcRoot 'bin'
  if (Test-Path $binDir) {
    $binCandidates = Get-ChildItem -Path $binDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^ispc(\.exe)?$' }
  }
  if (-not $binCandidates) {
    $binCandidates = Get-ChildItem -Path $ispcRoot -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^ispc(\.exe)?$' }
  }

  if ($binCandidates) {
    $found = $binCandidates | Select-Object -First 1
    $foundPath = $found.FullName
    $destName = if ($found.Extension -ieq '.exe') { 'ispc.exe' } else { 'ispc' }
    $destToolExe = Join-Path $ispcRoot $destName

    Write-Host "Found ISPC binary: $foundPath -> copying as $destName"
    Copy-Item -Path $foundPath -Destination $destToolExe -Force
    # ensure a small bin/ folder exists under tools/ispc
    if (-not (Test-Path $binDir)) { New-Item -ItemType Directory -Path $binDir | Out-Null }
    Copy-Item -Path $foundPath -Destination (Join-Path $binDir $destName) -Force
    # Ensure the copied file is executable (platform-specific)
    if ($Setup_IsWindows) {
      try { icacls $destToolExe /grant Everyone:RX | Out-Null } catch { }
    } else {
      try { chmod 0755 $destToolExe } catch { }
    }
    Write-Host "Installed ispc -> $destToolExe and $binDir/$destName"
  } else {
    Write-Warning "Could not locate ispc in extracted files. Please place the ispc binary into $ispcRoot or $DestBin manually."
  }
} finally {
  # Cleanup temporary archives
  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  if (Test-Path $tgzPath) { Remove-Item $tgzPath -Force }
  if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
}

# ===== Ninja Setup =====
Write-Host "`n=== Installing Ninja ==="
try {
  if (Test-Path $ninjaExtractDir) { Remove-Item -Recurse -Force $ninjaExtractDir }
  New-Item -ItemType Directory -Path $ninjaExtractDir | Out-Null

  # Ninja is always distributed as zip
  Invoke-WebRequest -Uri $NinjaUrl -OutFile $ninjaArchive -UseBasicParsing
  Write-Host "Extracting Ninja to temporary folder"
  Expand-Archive -Path $ninjaArchive -DestinationPath $ninjaExtractDir -Force

  # Look for ninja executable
  $ninjaCandidates = Get-ChildItem -Path $ninjaExtractDir -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^ninja(\.exe)?$' }
  
  if ($ninjaCandidates) {
    $found = $ninjaCandidates | Select-Object -First 1
    $foundPath = $found.FullName
    $destName = if ($found.Extension -ieq '.exe') { 'ninja.exe' } else { 'ninja' }
    $ninjaToolDir = Join-Path $DestTools 'ninja'
    $ninjaBinDir = Join-Path $ninjaToolDir 'bin'
    $destToolExe = Join-Path $ninjaBinDir $destName

    Write-Host "Found Ninja binary: $foundPath -> copying as $destName"
    if (-not (Test-Path $ninjaBinDir)) { New-Item -ItemType Directory -Path $ninjaBinDir | Out-Null }
    Copy-Item -Path $foundPath -Destination $destToolExe -Force
    
    # Set executable permissions
    if ($Setup_IsWindows) {
      try { icacls $destToolExe /grant Everyone:RX | Out-Null } catch { }
    } else {
      try { chmod 0755 $destToolExe } catch { }
    }
    Write-Host "Installed Ninja -> $destToolExe"
  } else {
    Write-Warning "Could not locate ninja in extracted files. Please place the ninja binary into $DestBin manually."
  }
} finally {
  # Cleanup temporary archives
  if (Test-Path $ninjaArchive) { Remove-Item $ninjaArchive -Force }
  if (Test-Path $ninjaExtractDir) { Remove-Item $ninjaExtractDir -Recurse -Force }
}

Write-Host "Setup completed."
