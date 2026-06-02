# ADR: Istio Ambient Mode

## Status: Accepted

## Context
Traditional Istio uses sidecar injection, which doubles pod resource usage and complicates operations.

## Decision
Use Istio ambient profile (CNI-based):
- CNI plugin handles traffic redirection
- ZTunnel DaemonSet for L4 interception
- No sidecar containers in application pods

## Consequences
- Lower resource overhead per pod
- Simpler pod lifecycle (no sidecar init/sync)
- L4 mTLS handled by ZTunnel
- L7 features via waypoint proxies (if needed)
