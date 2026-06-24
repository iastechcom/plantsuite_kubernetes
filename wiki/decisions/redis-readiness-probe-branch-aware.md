# ADR: Redis Readiness Probe — Branch-Aware (Standalone vs Cluster)

## Status: Accepted

## Context
The Redis StatefulSet runs as 1 replica (standalone) in the demo overlay and 6 replicas (cluster) in base/production. `init-cluster.sh` is already adaptive (exits 0 when `REPLICAS<=1`, sets `cluster-enabled no`), but the readiness probe ran `redis-cli cluster info`/`cluster nodes` unconditionally. In standalone mode those commands fail, so the probe never succeeded: Pod `Running` but `NotReady (0/1)` indefinitely, with no `CrashLoopBackOff` because the liveness probe uses only `PING`. The original hypothesis (bug in `init-cluster.sh`) was refuted; the root cause was a mode-fixed probe.

## Decision
Make the readiness probe branch-aware on `REPLICAS` (sourced from `/shared/replicas.env`, defaulting to 6):
- `REPLICAS==1` (standalone): `redis-cli ping` **and** `redis-cli info server | grep -q 'redis_mode:standalone'`
- `REPLICAS>1` (cluster): `cluster_state:ok` **and** membership (`myself.*master|myself.*slave`) **and** `cluster_size>=2`

Additional decisions:
- Use POSIX `grep -o 'cluster_size:[0-9][0-9]*' | cut -d: -f2 | head -n1` instead of `grep -oP` (PCRE) for portability across GNU grep and busybox/alpine.
- Fail-closed: no `|| echo 3` fallback that would mask an incomplete cluster as ready.

Reference: `k8s/base/redis/statefulset.yaml:205-214`.

## Consequences
- One probe definition serves both standalone and cluster overlays; no per-overlay probe patch needed.
- Probe logic must stay in sync with `init-cluster.sh`'s mode detection (both key off `REPLICAS`).
- General rule: when a StatefulSet supports both standalone (1 replica) and cluster (>1), probes must branch by mode — adaptive init scripts alone are insufficient if the probe assumes a fixed mode.
- Slightly more complex probe command; trade-off accepted to avoid silent NotReady pods.
