# PlantSuite Microservices

17 services in `k8s/base/plantsuite/`. Most services have: deployment, service, virtualservice, hpa, pdb. Exceptions: gateway (no HPA), workflows (no HPA/PDB), timeseries-buffer (StatefulSet instead of Deployment, no VirtualService).

| Service | Image Tag | Port | Description |
|---------|-----------|------|-------------|
| portal | 0.45.0 | 80 | Main web UI |
| gateway | pr-1014.5 | 80 | OPC-UA/MQTT data acquisition (uses PVC) |
| devices | 0.12.2 | 80 | IoT device management |
| entities | — | 80 | Entity management |
| queries | — | 80 | Query execution |
| dashboards | — | 80 | Dashboard service |
| tenants | — | 80 | Multi-tenancy |
| alarms | — | 80 | Alarm management |
| notifications | — | 80 | Notification service |
| spc | — | 80 | Statistical process control |
| timeseries-buffer | — | 80 | Time-series buffering |
| timeseries-mqtt | — | 80 | MQTT time-series ingestion |
| mes | — | 80 | Manufacturing execution |
| production | — | 80 | Production tracking |
| controlstations | — | 80 | Control station management |
| wd | — | 80 | Work definition |
| workflows | — | 80 | Workflow orchestration |

## CA Certificate Sync

`k8s/base/plantsuite/ca-certificate-sync/` — a CronJob that syncs the CA certificate from the wildcard TLS Secret into a ConfigMap every 4 hours. This allows non-Istio workloads (e.g. agents, sidecars) to trust the cluster's internal CA. Uses a dedicated `certificate-sync` ServiceAccount with RBAC to read Secrets and write ConfigMaps.

## Common Config
- All services: `envFrom: secretRef: plantsuite-env`
- Image pull: `IfNotPresent` from `plantsuite.azurecr.io`
- Gateway uses PVC for data persistence
- Observability: OTLP endpoint to Aspire Dashboard
