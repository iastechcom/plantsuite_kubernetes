# Health Check Probes

All PlantSuite services use HTTP probes on `/health` (port `http`, scheme `HTTP`).

## Startup Probe
- Initial delay: 15s, timeout: 3s, period: 3s
- failureThreshold: 30 (total ~100s startup window)

## Readiness Probe
- Initial delay: 5s, timeout: 3s, period: 10s
- failureThreshold: 3

## Liveness Probe
- Initial delay: 30s, timeout: 3s, period: 20s
- failureThreshold: 5
