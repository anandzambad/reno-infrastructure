# Reno V2 — Deployment & Browser Testing Guide

## 1. Recommended first test: local Docker Compose

Use this before Kubernetes. It is the fastest way to validate frontend + backend + MySQL on your laptop.

### Prerequisites

- Git
- Docker Desktop
- Docker Compose v2
- Node.js 22 only if you want to run the frontend outside Docker
- Java 21 + Maven only if you want to run the backend outside Docker

### Clone

```bash
git clone https://github.com/anandzambad/reno-frontend.git
git clone https://github.com/anandzambad/reno-backend.git
git clone https://github.com/anandzambad/reno-infrastructure.git
```

### Start

From `reno-infrastructure`:

```bash
docker compose -f docker-compose.local.yml up --build
```

### Browser

Open:

```text
http://localhost:3000
```

The frontend should load. The frontend calls the backend through the configured API URL.

### Backend health

Open:

```text
http://localhost:8080/actuator/health
```

Expected result contains:

```json
{"status":"UP"}
```

### API test

Open:

```text
http://localhost:8080/api/v1/leads
```

Expected response is the standard Reno API envelope.

## 2. Browser smoke test

After opening `http://localhost:3000`, verify:

1. Dashboard loads without a console error.
2. Navigate to Leads.
3. Leads list loads.
4. Search by name/email/phone filters results.
5. Click Create lead.
6. Service dropdown loads from `/api/v1/services`.
7. Enter valid customer details.
8. Submit.
9. Verify success message.
10. Return to Leads and verify the new lead appears.
11. Refresh the browser and verify persisted data is still present.
12. Test invalid required fields.
13. Test API failure by stopping the backend and confirm a friendly error is displayed.

## 3. Browser developer tools

Use Chrome/Edge DevTools:

- Console: JavaScript/runtime errors
- Network: API status, request payload and response
- Application: cookies/local storage when authentication is enabled
- Performance: slow pages and long tasks

For every API request verify:

- HTTP status is expected
- no sensitive values are logged
- response time is reasonable
- no repeated/unnecessary API calls occur

## 4. Local Kubernetes test

Prerequisites:

- Docker Desktop Kubernetes enabled, or Minikube/kind
- kubectl
- an image registry accessible by the cluster, or locally loaded images

Create the namespace and supporting secrets first. Never commit real database credentials.

```bash
kubectl apply -f kubernetes/base/namespace.yaml
```

Then deploy the appropriate overlay:

```bash
kubectl apply -k kubernetes/overlays/dev
```

Check:

```bash
kubectl get pods -n reno-dev
kubectl get svc -n reno-dev
kubectl get ingress -n reno-dev
```

Check rollout:

```bash
kubectl -n reno-dev rollout status deployment/dev-reno-backend
kubectl -n reno-dev rollout status deployment/dev-reno-frontend
```

If using a local cluster without an ingress controller, use port-forwarding:

```bash
kubectl -n reno-dev port-forward svc/dev-reno-frontend 3000:3000
```

Then open:

```text
http://localhost:3000
```

## 5. GitHub Actions deployment

The infrastructure repository contains a manual deployment workflow:

`Actions → Reno Deploy → Run workflow`

Choose:

- `dev`
- `staging`
- `beta`
- `prod`

Provide the exact frontend and backend Git SHA image tags.

Each GitHub Environment should contain the cluster credential secret:

```text
KUBE_CONFIG
```

The workflow applies the selected Kubernetes overlay and waits for frontend/backend rollouts.

## 6. Recommended promotion flow

```text
Developer
   ↓
Pull Request
   ↓
Frontend CI + Backend CI
   ↓
Merge main
   ↓
GHCR images tagged with Git SHA
   ↓
DEV
   ↓
Browser smoke test
   ↓
STAGING
   ↓
QA / regression
   ↓
BETA
   ↓
UAT
   ↓
PROD approval
   ↓
PROD
```

## 7. If browser shows a blank page

Check in this order:

```bash
kubectl get pods -n reno-dev
kubectl logs -n reno-dev deployment/dev-reno-frontend
kubectl logs -n reno-dev deployment/dev-reno-backend
kubectl get ingress -n reno-dev
```

Then inspect browser DevTools → Console and Network.

## 8. If frontend cannot call backend

Verify:

1. `NEXT_PUBLIC_API_URL` is correct for the deployed environment.
2. Backend Service exists.
3. Ingress routes `/api` to backend.
4. CORS allows the actual frontend origin when cross-origin access is used.
5. Browser Network tab shows the actual failing URL/status.

## 9. If database connection fails

Check:

```bash
kubectl get secret reno-db -n reno-dev
kubectl logs -n reno-dev deployment/dev-reno-backend
```

Verify the secret contains `url`, `username`, and `password` and that MySQL is reachable from the cluster.

## 10. Production rule

Do not expose MySQL publicly. Do not put passwords in Git. Do not use `latest` for production promotion. Promote immutable Git-SHA images and keep production behind TLS, authentication, authorization and an ingress/load balancer.
