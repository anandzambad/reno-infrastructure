[CmdletBinding()]
param([string]$Root = 'D:\Renevo')

$ErrorActionPreference = 'Stop'
$nssm = "$Root\runtime\nssm\nssm.exe"
if (-not (Test-Path $nssm)) { throw "NSSM not found at $nssm. Place a trusted NSSM binary there first." }
if (-not (Test-Path "$Root\scripts\run-backend.cmd")) { throw 'Backend launcher missing. Run Deploy-Renevo.ps1 first.' }
if (-not (Test-Path "$Root\scripts\run-frontend.cmd")) { throw 'Frontend launcher missing. Run Deploy-Renevo.ps1 first.' }

function Install-Service {
    param([string]$Name, [string]$DisplayName, [string]$Launcher, [string]$LogDir)
    $existing = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Host "$Name already exists; updating only the Renevo service definition."
        & $nssm stop $Name 2>$null | Out-Null
        & $nssm remove $Name confirm 2>$null | Out-Null
    }

    & $nssm install $Name "$env:ComSpec" '/c' "`"$Launcher`""
    if ($LASTEXITCODE -ne 0) { throw "NSSM failed to install $Name" }
    & $nssm set $Name DisplayName $DisplayName
    & $nssm set $Name Description "Renevo application service - isolated from existing server software"
    & $nssm set $Name Start SERVICE_AUTO_START
    & $nssm set $Name AppDirectory $Root
    & $nssm set $Name AppStdout "$LogDir\stdout.log"
    & $nssm set $Name AppStderr "$LogDir\stderr.log"
    & $nssm set $Name AppRotateFiles 1
    & $nssm set $Name AppRotateOnline 1
    & $nssm set $Name AppRotateBytes 10485760
    & $nssm set $Name AppExit Default Restart
    & $nssm set $Name AppRestartDelay 5000
}

Install-Service -Name 'RenevoBackend' -DisplayName 'Renevo Backend' -Launcher "$Root\scripts\run-backend.cmd" -LogDir "$Root\logs\backend"
Install-Service -Name 'RenevoFrontend' -DisplayName 'Renevo Frontend' -Launcher "$Root\scripts\run-frontend.cmd" -LogDir "$Root\logs\frontend"

Start-Service RenevoBackend
Start-Sleep -Seconds 5
Start-Service RenevoFrontend

Get-Service RenevoBackend,RenevoFrontend | Select-Object Name,Status,StartType
Write-Host 'Renevo services installed and started. Existing services were not touched.'
