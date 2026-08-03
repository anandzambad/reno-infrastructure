[CmdletBinding()]
param([string]$Root = 'D:\Renevo')
$ErrorActionPreference = 'Stop'
foreach ($name in @('RenevoFrontend','RenevoBackend')) {
    $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne 'Stopped') { Stop-Service -Name $name -Force }
}
Get-Service RenevoBackend,RenevoFrontend -ErrorAction SilentlyContinue | Select-Object Name,Status
Write-Host 'Only Renevo services were stopped.'
