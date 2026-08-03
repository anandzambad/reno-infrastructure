# Renevo Windows Server prerequisites

Target host: Techno-SRV1 / Windows Server 2012 R2 Standard.

## Existing software that must remain untouched

- Existing Java 8 installation
- Existing MySQL57 service / MySQL 5.7 configuration
- Existing Tomcat service
- Existing system `PATH` and `JAVA_HOME`
- Existing ports and firewall rules

## Private runtimes

Stage these under `D:\Renevo\runtime`:

```text
D:\Renevo\runtime\jdk21\bin\java.exe
D:\Renevo\runtime\node18\node.exe
D:\Renevo\runtime\nssm\nssm.exe
```

Validate without changing system environment variables:

```powershell
& 'D:\Renevo\runtime\jdk21\bin\java.exe' -version
& 'D:\Renevo\runtime\node18\node.exe' --version
& 'D:\Renevo\runtime\nssm\nssm.exe' version
```

The current backend POM declares Java 21, so Java 8 cannot be used to run it. The frontend uses Next.js 15 and should run on Node 18.18+.

## Application artifacts

Backend:

```text
reno-backend.jar
```

Frontend:

```text
server.js
.next\static\...
public\...
```

The frontend repository already uses Next.js standalone output. Build in CI rather than installing npm globally on Techno-SRV1.

## Data services

Existing MySQL 5.7 may be reused for a **separate** Renevo database/schema. The installer does not change the MySQL service configuration.

The current backend configuration also expects Redis and an OIDC issuer. Those services must be reachable before testing availability/booking and authenticated flows.

## Network policy

Preferred external entry point:

```text
TCP 8088 -> Renevo frontend
```

Keep these private unless there is a documented reason to expose them:

```text
TCP 8090 -> Spring Boot backend
TCP 3306 -> MySQL
TCP 6379 -> Redis
TCP 8081 -> OIDC/Keycloak
```
