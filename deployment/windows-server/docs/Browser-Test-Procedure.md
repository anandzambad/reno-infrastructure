# Renevo Browser and Deployment Test Procedure

## 1. Server-side checks

Run PowerShell as Administrator:

```powershell
D:\Renevo\scripts\HealthCheck-Renevo.ps1
```

Expected:

- `RenevoBackend` = Running
- `RenevoFrontend` = Running
- backend listener = `8090`
- frontend listener = `8088`
- backend jar exists
- frontend `server.js` exists
- private Java and Node runtimes exist

## 2. Local browser test on the server

Open a browser on Techno-SRV1:

```text
http://127.0.0.1:8088
```

Backend:

```text
http://127.0.0.1:8090/actuator/health
```

Swagger:

```text
http://127.0.0.1:8090/swagger-ui.html
```

## 3. Remote browser test

From a trusted workstation:

```text
http://<SERVER-IP>:8088
```

Do not expose MySQL 3306 or Redis 6379 to the Internet.

Keep backend 8090 private unless the frontend architecture requires direct browser-to-API calls. If direct access is required, restrict the firewall rule to trusted source IPs rather than opening it globally.

## 4. Functional smoke test

1. Landing/login page renders without console errors.
2. Login/authentication completes against the configured OIDC issuer.
3. Admin can view dashboard.
4. Customer can create a lead.
5. Contractor can view assigned/nearby work according to permissions.
6. Contractor availability and map/list view work when Redis is reachable.
7. Booking prevents duplicate allocation when two requests race.
8. Estimate/quotation can be created.
9. Invoice can be generated.
10. Email/WhatsApp integration fails gracefully when provider credentials are absent.
11. CRM 30/60/90-day follow-up records are created and scheduled correctly.
12. Dispute creation, evidence upload and status transitions work.

## 5. API checks

Use Swagger or Postman. Verify at minimum:

- health/readiness
- authentication/authorization
- leads
- contractors
- nearby contractor search
- availability
- booking
- estimate/quotation
- invoice
- CRM follow-up
- disputes

Record status code, response time, correlation/request ID and response validation.

## 6. Browser performance checks

Use browser DevTools:

- no failed JS/CSS requests
- no mixed-content errors
- no CORS errors
- first meaningful render is acceptable on the target network
- API calls do not repeatedly fire due to render loops
- map markers are clustered/limited for large result sets
- pagination/infinite loading is used for large tables

## 7. Rollback

```powershell
D:\Renevo\scripts\Stop-Renevo.ps1
D:\Renevo\scripts\Uninstall-RenevoServices.ps1
```

Do not stop MySQL57 or existing Tomcat services as part of Renevo rollback.
