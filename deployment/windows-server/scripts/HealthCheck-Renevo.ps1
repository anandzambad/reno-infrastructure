[CmdletBinding()]
param(
    [string]$Root = 'D:\Renevo',
    [string]$HostName = '127.0.0.1',
    [int]$BackendPort = 8090,
    [int]$FrontendPort = 8088
)

$ErrorActionPreference = 'Continue'

Write-Host '=== Renevo services ==='
Get-Service RenevoBackend,RenevoFrontend -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType

Write-Host "`n=== Renevo listeners ==="
netstat -ano | Select-String (':'+$BackendPort+'|:'+$FrontendPort)

function Test-Http {
    param([string]$Url)
    try {
        $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 10
        Write-Host "$Url -> $($r.StatusCode)"
    } catch {
        Write-Warning "$Url -> FAILED: $($_.Exception.Message)"
    }
}

Test-Http "http://$HostName`:$BackendPort/actuator/health"
Test-Http "http://$HostName`:$FrontendPort/"

Write-Host "`n=== Runtime presence ==="
Write-Host "Java:" (Test-Path "$Root\runtime\jdk21\bin\java.exe")
Write-Host "Node:" (Test-Path "$Root\runtime\node18\node.exe")
Write-Host "Backend jar:" (Test-Path "$Root\app\backend\reno-backend.jar")
Write-Host "Frontend server:" (Test-Path "$Root\app\frontend\server.js")
Write-Host "Config:" (Test-Path "$Root\config\reno.env")
