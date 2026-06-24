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

## Branch-Aware Probes (Standalone vs Cluster)
When a StatefulSet supports both standalone (1 replica) and cluster (>1) modes — e.g. Redis, where the demo overlay runs `replicas:1` with `cluster-enabled no` and base/production runs `replicas:6` in cluster mode — probes must branch by mode. An adaptive init script is not enough: if the probe assumes a fixed mode, the Pod ends up `Running` but `NotReady` indefinitely (no `CrashLoopBackOff` if liveness is just `PING`).

Pattern:
- Source the replica count from a shared env file (`/shared/replicas.env`, written by an initContainer), defaulting to the base value.
- `REPLICAS==1`: assert standalone semantics (`PING` + `redis_mode:standalone`).
- `REPLICAS>1`: assert cluster semantics (`cluster_state:ok` + membership + `cluster_size>=2`).
- Use POSIX `grep` (`grep -o 'cluster_size:[0-9][0-9]*' | cut -d: -f2 | head -n1`), not `grep -oP` (PCRE), for portability across GNU grep and busybox/alpine.
- Fail-closed: never add a fallback (`|| echo N`) that masks an incomplete cluster as ready.

Example: `k8s/base/redis/statefulset.yaml:205-214`. Rationale: see [ADR: Redis Readiness Probe — Branch-Aware](../decisions/redis-readiness-probe-branch-aware.md).
