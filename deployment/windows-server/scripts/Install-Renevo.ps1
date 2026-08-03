[CmdletBinding()]
param(
    [string]$Root = 'D:\Renevo',
    [string]$DbName = 'reno',
    [string]$DbUser = 'reno_app',
    [int]$FrontendPort = 8088,
    [int]$BackendPort = 8090,
    [switch]$ConfigureFirewall
)

$ErrorActionPreference = 'Stop'

function Assert-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run this script from an elevated PowerShell window.'
    }
}

function Write-EnvFile {
    param([string]$Path, [hashtable]$Values)
    $lines = @()
    foreach ($key in $Values.Keys) { $lines += ($key + '=' + [string]$Values[$key]) }
    Set-Content -Path $Path -Value $lines -Encoding ASCII
    & icacls.exe $Path /inheritance:r /grant:r 'SYSTEM:F' 'Administrators:F' | Out-Null
}

Assert-Admin

if (-not (Test-Path $Root)) { New-Item -ItemType Directory -Path $Root -Force | Out-Null }
$dirs = @(
    "$Root\app\backend",
    "$Root\app\frontend",
    "$Root\config",
    "$Root\logs\backend",
    "$Root\logs\frontend",
    "$Root\backup",
    "$Root\runtime\jdk17",
    "$Root\runtime\node18",
    "$Root\runtime\nssm",
    "$Root\scripts"
)
foreach ($d in $dirs) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null } }

# Never modify system JAVA_HOME/PATH. Renevo uses a private runtime.
$javaExe = "$Root\runtime\jdk17\bin\java.exe"
$nodeExe = "$Root\runtime\node18\node.exe"
$nssmExe = "$Root\runtime\nssm\nssm.exe"

if (-not (Test-Path $javaExe)) { Write-Warning "Private Java runtime not found: $javaExe. Place Java 17+ there before starting the backend." }
if (-not (Test-Path $nodeExe)) { Write-Warning "Private Node runtime not found: $nodeExe. Place Node 18.18+ there before starting the frontend." }
if (-not (Test-Path $nssmExe)) { Write-Warning "NSSM not found: $nssmExe. Place nssm.exe there before installing Windows services." }

# Detect the existing MySQL service without changing it.
$mysqlService = Get-Service -Name 'MySQL57' -ErrorAction SilentlyContinue
if ($mysqlService) {
    Write-Host "Existing MySQL57 detected: $($mysqlService.Status). No service configuration will be changed."
} else {
    Write-Warning 'MySQL57 service was not found. Database setup will need a manually supplied mysql.exe path.'
}

$envPath = "$Root\config\reno.env"
if (-not (Test-Path $envPath)) {
    $secret = -join ((48..57)+(65..90)+(97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
    $values = @{
        PORT = $BackendPort
        DB_URL = "jdbc:mysql://127.0.0.1:3306/$DbName?useSSL=false&serverTimezone=UTC"
        DB_USERNAME = $DbUser
        DB_PASSWORD = $secret
        DB_POOL_SIZE = 10
        REDIS_HOST = '127.0.0.1'
        REDIS_PORT = 6379
        REDIS_TIMEOUT = '1000ms'
        OIDC_ISSUER_URI = 'http://127.0.0.1:8081/realms/reno'
        RENO_ALLOWED_ORIGINS = "http://127.0.0.1:$FrontendPort"
        FRONTEND_PORT = $FrontendPort
    }
    Write-EnvFile -Path $envPath -Values $values
    Write-Host "Created protected config: $envPath"
} else {
    Write-Host "Existing Renevo config preserved: $envPath"
}

if ($ConfigureFirewall) {
    & netsh.exe advfirewall firewall add rule name='Renevo Frontend 8088' dir=in action=allow protocol=TCP localport=$FrontendPort profile=Any | Out-Null
    & netsh.exe advfirewall firewall add rule name='Renevo Backend 8090' dir=in action=allow protocol=TCP localport=$BackendPort profile=Any | Out-Null
    Write-Host 'Only Renevo firewall rules were requested/created.'
}

Write-Host ''
Write-Host 'Renevo host preparation completed.'
Write-Host 'No existing Java, MySQL, Tomcat, PATH or JAVA_HOME settings were changed.'
Write-Host "Next: populate $Root\runtime\jdk17, $Root\runtime\node18 and $Root\runtime\nssm, then run Deploy-Renevo.ps1 and Install-RenevoServices.ps1."
