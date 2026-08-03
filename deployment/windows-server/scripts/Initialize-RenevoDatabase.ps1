[CmdletBinding()]
param(
    [string]$Root = 'D:\Renevo',
    [string]$MySqlExe = 'C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe',
    [string]$DbName = 'reno',
    [string]$DbUser = 'reno_app'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $MySqlExe)) { throw "mysql.exe not found at $MySqlExe. Supply -MySqlExe with the existing installation path." }
$envPath = "$Root\config\reno.env"
if (-not (Test-Path $envPath)) { throw "Missing $envPath. Run Install-Renevo.ps1 first." }

function Read-EnvValue([string]$Name) {
    $line = Get-Content $envPath | Where-Object { $_ -match ('^' + [regex]::Escape($Name) + '=') } | Select-Object -First 1
    if ($line) { return $line.Substring($Name.Length + 1) }
    return $null
}

$dbPassword = Read-EnvValue 'DB_PASSWORD'
if (-not $dbPassword) { throw 'DB_PASSWORD is missing from reno.env.' }

$adminUser = Read-Host 'Existing MySQL administrative username (for example root)'
$secure = Read-Host 'Existing MySQL administrative password' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
try { $adminPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }

$temp = Join-Path $env:TEMP ('reno-mysql-' + [guid]::NewGuid().ToString('N') + '.cnf')
$sql = Join-Path $env:TEMP ('reno-db-' + [guid]::NewGuid().ToString('N') + '.sql')
try {
    @("[client]", "user=$adminUser", "password=$adminPassword", "host=127.0.0.1") | Set-Content $temp -Encoding ASCII
    & icacls.exe $temp /inheritance:r /grant:r "$env:USERNAME:F" | Out-Null

    @(
        "CREATE DATABASE IF NOT EXISTS ``$DbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;",
        "CREATE USER IF NOT EXISTS '$DbUser'@'127.0.0.1' IDENTIFIED BY '$dbPassword';",
        "ALTER USER '$DbUser'@'127.0.0.1' IDENTIFIED BY '$dbPassword';",
        "GRANT ALL PRIVILEGES ON ``$DbName``.* TO '$DbUser'@'127.0.0.1';",
        "FLUSH PRIVILEGES;"
    ) | Set-Content $sql -Encoding ASCII

    & $MySqlExe --defaults-extra-file=$temp --batch --skip-column-names < $sql
    if ($LASTEXITCODE -ne 0) { throw "MySQL bootstrap failed with exit code $LASTEXITCODE." }
    Write-Host "Database '$DbName' and application user '$DbUser' are ready. Existing MySQL service/configuration was not changed."
}
finally {
    Remove-Item $temp,$sql -Force -ErrorAction SilentlyContinue
}
