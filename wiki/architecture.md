# Architecture Overview

## Stack
- **Kustomize** base + overlay pattern for all manifests
- **Istio** ambient service mesh (CNI-based, no sidecar injection)
- **Percona operators** for MongoDB and PostgreSQL
- **Helm charts** for Istio and VerneMQ
- **Custom TUI installer** (bash) with pipeline execution

## Directory Layout
- `k8s/base/` — lean HA base configs (never modify directly)
- `k8s/overlays/{env}/` — environment-specific patches (demo, production)
- `tools/install.sh` — entry point, TUI wizard
- `tools/lib/` — installer modules (pipeline, k8s-adapter, screens, secrets)
- `docs/` — setup guides (Kind, MicroK8s, Kustomize, OpenTelemetry)

## Component Map (k8s/base/)

| Component | Namespace | Type | Version |
|-----------|-----------|------|---------|
| metrics-server | kube-system | Deployment | v0.8.1 |
| cert-manager | cert-manager | Operator | v1.19.1 |
| istio-system | istio-system | Helm (ambient) | v1.29.1 |
| istio-ingress | istio-ingress | Helm gateway | v1.28.2 |
| aspire | aspire | Deployment | — |
| mongodb | mongodb | Percona operator | — |
| postgresql | postgresql | Percona operator | — |
| redis | redis | StatefulSet | 6 replicas |
| keycloak | keycloak | Operator | v26.5.1 |
| rabbitmq | rabbitmq | Operator | — |
| vernemq | vernemq | Helm | 2.1.1 |
| plantsuite | plantsuite | 17 microservices | — |

## Dependency Chain
```
metrics-server → cert-manager → istio-system → istio-ingress
                                              ↓
                         aspire, mongodb, postgresql, redis, keycloak, rabbitmq, vernemq
                                              ↓
                                        plantsuite (services)
```

## Service Access
- All HTTP services: `https://{service}.plantsuite.local` via Istio Gateway
- MQTT: `mqtt.plantsuite.local:1883` (TCP), `:8883` (TLS)
- Keycloak: `account.plantsuite.local`
- Aspire Dashboard: `aspire-dashboard.plantsuite.local`

## Container Registry
- `plantsuite.azurecr.io` (Azure Container Registry)
- Auth via `k8s/base/plantsuite/dockerconfig.json` → secret `plantsuite-cr`

## Environment Sizing

| Overlay | Nodes | vCPU | RAM | Disk |
|---------|-------|------|-----|------|
| demo | 1 | 4 | 16Gi | 150Gi |
| base | 3 | 4 | 16Gi | 200Gi |
| production | 3 | 8 | 32Gi | 500Gi |
