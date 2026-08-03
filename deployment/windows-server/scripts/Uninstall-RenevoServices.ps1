[CmdletBinding()]
param([string]$Root = 'D:\Renevo')
$ErrorActionPreference = 'Stop'
$nssm = "$Root\runtime\nssm\nssm.exe"
foreach ($name in @('RenevoFrontend','RenevoBackend')) {
    $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
    if ($svc) {
        if ($svc.Status -ne 'Stopped') { Stop-Service -Name $name -Force }
        if (Test-Path $nssm) { & $nssm remove $name confirm | Out-Null }
        else { & sc.exe delete $name | Out-Null }
    }
}
Write-Host 'Renevo services removed. Existing MySQL/Tomcat/Java services were not modified.'
