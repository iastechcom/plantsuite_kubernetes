# Resource Management

## HPA Pattern (services with scaling)
- `minReplicas: 1`, `maxReplicas: 3`
- CPU target: `averageUtilization: 70`
- Scale-up: 90s stabilization, 50% or 3 pods per 30s
- Scale-down: 300s stabilization, 25% or 1 pod per 120s
- Demo overlay: patched to 1/1 (no scaling)

## PDB Pattern
- Every service: `maxUnavailable: 1`
- Istio Gateway: `maxUnavailable: 1` (in helm-values)
- VerneMQ: `maxUnavailable: 1` (in helm-values)

## Topology Spread
```yaml
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
```

## Example Resource Ranges (base)

| Service | CPU req/lim | Mem req/lim |
|---------|-------------|-------------|
| portal | 50m/200m | 32Mi/32Mi |
| devices | 100m/500m | 512Mi/512Mi |
| istio-gateway | 100m/100m | 128Mi/128Mi |
| vernemq | 500m/1000m | 1Gi/3Gi |
