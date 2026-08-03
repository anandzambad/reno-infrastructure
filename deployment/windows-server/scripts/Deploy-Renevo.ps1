[CmdletBinding()]
param(
    [string]$Root = 'D:\Renevo',
    [string]$BackendJar = "$PSScriptRoot\..\..\..\reno-backend\target\reno-backend.jar",
    [string]$FrontendStandalone = "$PSScriptRoot\..\..\..\reno-frontend\.next\standalone",
    [string]$FrontendPublic = "$PSScriptRoot\..\..\..\reno-frontend\public",
    [string]$FrontendStatic = "$PSScriptRoot\..\..\..\reno-frontend\.next\static"
)

$ErrorActionPreference = 'Stop'

function Copy-Tree {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path $Source)) { throw "Artifact path not found: $Source" }
    if (-not (Test-Path $Destination)) { New-Item -ItemType Directory -Path $Destination -Force | Out-Null }
    Copy-Item -Path (Join-Path $Source '*') -Destination $Destination -Recurse -Force
}

$backendDest = "$Root\app\backend"
$frontendDest = "$Root\app\frontend"
if (-not (Test-Path $Root)) { throw "Renevo root does not exist. Run Install-Renevo.ps1 first." }

if (-not (Test-Path $BackendJar)) { throw "Backend jar not found: $BackendJar" }
Copy-Item $BackendJar (Join-Path $backendDest 'reno-backend.jar') -Force

Copy-Tree -Source $FrontendStandalone -Destination $frontendDest

# Next standalone builds commonly require public and .next/static alongside server.js.
if (Test-Path $FrontendPublic) { Copy-Tree -Source $FrontendPublic -Destination (Join-Path $frontendDest 'public') }
if (Test-Path $FrontendStatic) { Copy-Tree -Source $FrontendStatic -Destination (Join-Path $frontendDest '.next\static') }

if (-not (Test-Path (Join-Path $frontendDest 'server.js'))) {
    throw 'Frontend deployment is missing server.js. Supply the complete Next.js standalone artifact.'
}

$envPath = "$Root\config\reno.env"
if (-not (Test-Path $envPath)) { throw "Missing config: $envPath" }

# Read only non-comment KEY=VALUE entries and generate local launchers.
$envLines = Get-Content $envPath | Where-Object { $_ -and (-not $_.Trim().StartsWith('#')) -and $_ -match '^\s*[A-Za-z_][A-Za-z0-9_]*=' }
$envText = ($envLines -join "`r`n")

$backendCmd = @"
@echo off
setlocal
for /f "usebackq tokens=1,* delims==" %%A in ("$envPath") do (
  if not "%%A"=="" if not "%%A:~0,1%%"=="#" set "%%A=%%B"
)
cd /d "$backendDest"
"$Root\runtime\jdk21\bin\java.exe" -jar "reno-backend.jar"
exit /b %ERRORLEVEL%
"@
Set-Content -Path "$Root\scripts\run-backend.cmd" -Value $backendCmd -Encoding ASCII

$frontendCmd = @"
@echo off
setlocal
for /f "usebackq tokens=1,* delims==" %%A in ("$envPath") do (
  if not "%%A"=="" if not "%%A:~0,1%%"=="#" set "%%A=%%B"
)
set "HOSTNAME=0.0.0.0"
set "PORT=%FRONTEND_PORT%"
cd /d "$frontendDest"
"$Root\runtime\node18\node.exe" "server.js"
exit /b %ERRORLEVEL%
"@
Set-Content -Path "$Root\scripts\run-frontend.cmd" -Value $frontendCmd -Encoding ASCII

Write-Host 'Deployment artifacts copied and launch scripts generated.'
Write-Host "Backend: $backendDest\reno-backend.jar"
Write-Host "Frontend: $frontendDest\server.js"
