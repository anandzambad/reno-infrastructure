#!/usr/bin/env bash
set -Eeuo pipefail

# Renevo one-command deployment for Git Bash on Windows Server.
# Usage: bash deploy-renovo.sh
# Safety: does not modify system JAVA_HOME/PATH, existing Java, MySQL57 or Tomcat.

ROOT='D:/Renevo'
BACKEND_REPO='https://github.com/anandzambad/reno-backend.git'
FRONTEND_REPO='https://github.com/anandzambad/reno-frontend.git'
INFRA_REPO='https://github.com/anandzambad/reno-infrastructure.git'
BACKEND_DIR="$ROOT/source/reno-backend"
FRONTEND_DIR="$ROOT/source/reno-frontend"
INFRA_DIR="$ROOT/source/reno-infrastructure"
BACKEND_PORT='8090'
FRONTEND_PORT='8088'

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail(){ echo "ERROR: $*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || fail 'Git is required.'
command -v powershell.exe >/dev/null 2>&1 || fail 'Windows PowerShell is required.'

say 'Checking existing server software without changing it...'
powershell.exe -NoProfile -Command "Get-Service MySQL57 -ErrorAction SilentlyContinue | Select-Object Name,Status,StartType | Format-Table -AutoSize" || true

say 'Checking free disk space on D:...'
powershell.exe -NoProfile -Command "Get-PSDrive D | Select-Object Name,@{N='FreeGB';E={[math]::Round(\$_.Free/1GB,2)}} | Format-Table -AutoSize"

say 'Creating Renevo directories...'
powershell.exe -NoProfile -Command "New-Item -ItemType Directory -Force -Path 'D:\Renevo\source','D:\Renevo\app\backend','D:\Renevo\app\frontend','D:\Renevo\config','D:\Renevo\logs\backend','D:\Renevo\logs\frontend','D:\Renevo\backup','D:\Renevo\scripts' | Out-Null"

clone_or_update(){
  local url="$1" dir="$2"
  if [[ -d "$dir/.git" ]]; then
    git -C "$dir" fetch --all --prune
    git -C "$dir" pull --ff-only
  else
    git clone "$url" "$dir"
  fi
}

say 'Fetching application repositories...'
clone_or_update "$BACKEND_REPO" "$BACKEND_DIR"
clone_or_update "$FRONTEND_REPO" "$FRONTEND_DIR"
clone_or_update "$INFRA_REPO" "$INFRA_DIR"

# Build with existing tools only if they are available. We intentionally do not alter system Java.
if command -v mvn >/dev/null 2>&1; then
  say 'Building backend with Maven...'
  (cd "$BACKEND_DIR" && mvn -B clean package -DskipTests)
else
  fail 'Maven is not available. The one-command deployment expects a CI-produced backend JAR or Maven installed separately; it will not alter your existing Java installation.'
fi

if command -v npm >/dev/null 2>&1; then
  say 'Building frontend with npm...'
  (cd "$FRONTEND_DIR" && npm ci && npm run build)
else
  fail 'npm is not available. The one-command deployment expects a CI-produced Next.js standalone artifact or Node/npm staged separately; it will not modify system Node.'
fi

JAR=$(find "$BACKEND_DIR/target" -maxdepth 1 -type f -name '*.jar' ! -name '*-sources.jar' ! -name '*-javadoc.jar' | head -n 1 || true)
[[ -n "$JAR" ]] || fail 'Backend JAR was not produced.'
[[ -f "$FRONTEND_DIR/.next/standalone/server.js" ]] || fail 'Next.js standalone server.js was not produced. Check next.config.ts output: standalone.'

say 'Copying build artifacts to D:...'
cp -f "$JAR" "$ROOT/app/backend/reno-backend.jar"
rm -rf "$ROOT/app/frontend"/*
cp -a "$FRONTEND_DIR/.next/standalone/." "$ROOT/app/frontend/"
mkdir -p "$ROOT/app/frontend/.next/static"
if [[ -d "$FRONTEND_DIR/.next/static" ]]; then cp -a "$FRONTEND_DIR/.next/static/." "$ROOT/app/frontend/.next/static/"; fi
if [[ -d "$FRONTEND_DIR/public" ]]; then rm -rf "$ROOT/app/frontend/public"; cp -a "$FRONTEND_DIR/public" "$ROOT/app/frontend/public"; fi

say 'Preparing protected configuration...'
if [[ ! -f "$ROOT/config/reno.env" ]]; then
  DB_PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32 || true)
  cat > "$ROOT/config/reno.env" <<EOF
PORT=$BACKEND_PORT
DB_URL=jdbc:mysql://127.0.0.1:3306/reno?useSSL=false&serverTimezone=UTC
DB_USERNAME=reno_app
DB_PASSWORD=$DB_PASSWORD
DB_POOL_SIZE=10
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_TIMEOUT=1000ms
OIDC_ISSUER_URI=http://127.0.0.1:8081/realms/reno
RENO_ALLOWED_ORIGINS=http://127.0.0.1:$FRONTEND_PORT
FRONTEND_PORT=$FRONTEND_PORT
EOF
  powershell.exe -NoProfile -Command "& icacls.exe 'D:\Renevo\config\reno.env' /inheritance:r /grant:r 'SYSTEM:F' 'Administrators:F' | Out-Null"
else
  say 'Existing reno.env preserved.'
fi

say 'Creating local launchers...'
cat > "$ROOT/scripts/run-backend.cmd" <<EOF
@echo off
setlocal
for /f "usebackq tokens=1,* delims==" %%A in ("D:\Renevo\config\reno.env") do if not "%%A"=="" set "%%A=%%B"
cd /d "D:\Renevo\app\backend"
"D:\Renevo\runtime\jdk21\bin\java.exe" -jar "reno-backend.jar"
EOF
cat > "$ROOT/scripts/run-frontend.cmd" <<EOF
@echo off
setlocal
for /f "usebackq tokens=1,* delims==" %%A in ("D:\Renevo\config\reno.env") do if not "%%A"=="" set "%%A=%%B"
set HOSTNAME=0.0.0.0
set PORT=%FRONTEND_PORT%
cd /d "D:\Renevo\app\frontend"
"D:\Renevo\runtime\node18\node.exe" "server.js"
EOF

say 'Validating private runtimes...'
[[ -f "$ROOT/runtime/jdk21/bin/java.exe" ]] || fail 'Private Java 21 is missing: D:/Renevo/runtime/jdk21/bin/java.exe. Stage a compatible JDK 21 there and rerun.'
[[ -f "$ROOT/runtime/node18/node.exe" ]] || fail 'Private Node is missing: D:/Renevo/runtime/node18/node.exe. Stage Node 18.18+ there and rerun.'
[[ -f "$ROOT/runtime/nssm/nssm.exe" ]] || fail 'NSSM is missing: D:/Renevo/runtime/nssm/nssm.exe. Stage a trusted NSSM binary there and rerun.'

say 'Initializing the isolated Renevo database...'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ROOT/scripts/Initialize-RenevoDatabase.ps1"

say 'Installing/restarting only Renevo services...'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ROOT/scripts/Install-RenevoServices.ps1" -Root "$ROOT"

say 'Running health check...'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$ROOT/scripts/HealthCheck-Renevo.ps1" -Root "$ROOT"

cat <<EOF

========================================
 RENEVO DEPLOYMENT COMPLETE
========================================
Frontend: http://<SERVER-IP>:$FRONTEND_PORT
Backend:  http://127.0.0.1:$BACKEND_PORT
Health:   http://127.0.0.1:$BACKEND_PORT/actuator/health
Install:  D:/Renevo

Existing Java/MySQL/Tomcat were not modified by this script.
Backend 8090 is private by default; no public firewall rule is added.
========================================
EOF
