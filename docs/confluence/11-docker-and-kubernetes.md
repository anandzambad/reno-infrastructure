# Reno V2 — Docker & Kubernetes

## Container model

Two application images are maintained:

- `reno-frontend`
- `reno-backend`

Images must be minimal, non-root where supported, reproducible and configured at runtime.

## Kubernetes workload model

```text
Namespace
 ├── frontend Deployment + Service
 ├── backend Deployment + Service
 ├── Ingress
 ├── ConfigMaps
 ├── Secrets
 ├── HPA
 └── ServiceAccount / RBAC
```

MySQL should use a managed/approved stateful platform in production rather than a disposable application pod.

## Probes

Backend should expose liveness and readiness endpoints. Frontend should expose a lightweight health endpoint.

## Resources

Every deployment must define CPU/memory requests and limits. Initial values should be tuned using observed workload rather than assumed as final production sizing.

## Scaling

Backend and frontend are stateless and can use HPA. Scaling thresholds should be based on CPU, memory and, where available, request latency/throughput.

## Deployment safety

Use rolling updates, readiness gates, pod disruption controls where appropriate, and environment-specific namespaces or clusters.
