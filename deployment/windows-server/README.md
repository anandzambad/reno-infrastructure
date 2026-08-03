# Renevo Windows Server Installation Package

This package is designed for **Techno-SRV1 / Windows Server 2012 R2** and deliberately isolates Renevo from the existing Java 8, MySQL 5.7 and Tomcat installations.

## Safety rules

- Do not change the existing global `JAVA_HOME`, `PATH`, MySQL configuration, MySQL service, Tomcat service, or existing ports.
- Use `D:\Renevo` for Renevo files because the server's C: drive has very little free space.
- The backend requires Java 17+ (the repository currently declares Java 21). The existing Java 8 installation cannot run this Spring Boot application.
- The frontend is Next.js 15 standalone and needs Node.js 18.18+ at runtime. Keep Node private to Renevo; do not modify the system Node/PATH.
- Redis is a runtime dependency in the current backend configuration. Provide a reachable Redis instance before enabling location/availability features.
- OIDC/Keycloak is also expected by the current backend security configuration. Set `OIDC_ISSUER_URI` to the real issuer before user login testing.

## Expected package layout

```text
D:\Renevo\
  app\backend\reno-backend.jar
  app\frontend\server.js
  app\frontend\node_modules\...
  config\reno.env
  logs\backend\
  logs\frontend\
  backup\
  runtime\jdk17\
  runtime\node18\
  runtime\nssm\nssm.exe
  scripts\...
```

## Artifacts

Build the backend with Maven from `anandzambad/reno-backend` and copy the resulting Spring Boot jar to `app\backend\reno-backend.jar`.

Build the frontend from `anandzambad/reno-frontend` with `npm run build`. Copy the Next standalone output into `app\frontend`; it must contain `server.js` and its required `.next\standalone` runtime files. The preferred artifact is the complete contents of `.next\standalone`, with static/public assets copied according to the repository's Next.js deployment setup.

## Installation

Run PowerShell as Administrator and execute:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
D:\Renevo\scripts\Install-Renevo.ps1 -Root D:\Renevo
```

The installer is intentionally conservative. It validates the host, creates only Renevo directories, creates a separate database/schema and application user, writes a protected environment file, installs two services using a private NSSM binary, and configures only Renevo firewall rules if explicitly requested.

## Configuration

Edit `D:\Renevo\config\reno.env` before starting the services. At minimum set:

```text
DB_URL=jdbc:mysql://127.0.0.1:3306/reno
DB_USERNAME=reno_app
DB_PASSWORD=<generated-or-your-value>
REDIS_HOST=<redis-host>
REDIS_PORT=6379
OIDC_ISSUER_URI=<your-oidc-issuer>
RENO_ALLOWED_ORIGINS=http://<server-ip>:8088
```

Do not commit this file to Git.

## Deployment

```powershell
D:\Renevo\scripts\Deploy-Renevo.ps1 -Root D:\Renevo
D:\Renevo\scripts\Install-RenevoServices.ps1 -Root D:\Renevo
```

The default private ports are:

- Frontend: `8088`
- Backend: `8090`

These are intentionally different from the existing services shown on Techno-SRV1.

## Browser test

Open:

```text
http://<server-ip>:8088
```

Backend health:

```text
http://<server-ip>:8090/actuator/health
```

Swagger:

```text
http://<server-ip>:8090/swagger-ui.html
```

If the backend starts but authenticated API calls fail, verify `OIDC_ISSUER_URI` and the frontend allowed origin. If nearby-contractor availability fails, verify Redis connectivity.

## Rollback

```powershell
D:\Renevo\scripts\Stop-Renevo.ps1 -Root D:\Renevo
D:\Renevo\scripts\Uninstall-RenevoServices.ps1 -Root D:\Renevo
```

These commands remove only Renevo services. They do not stop or modify the existing MySQL/Tomcat services.

## Important limitation

This repository package is an **installation/deployment automation package**, not a copy of the application binaries. Build artifacts must come from the CI pipeline or the corresponding frontend/backend repositories.
