# ADR: Kustomize Base + Overlays

## Status: Accepted

## Context
PlantSuite has multiple deployment environments (demo, staging, production) with different resource requirements. Base configs must remain stable and shared.

## Decision
Use Kustomize base + overlay pattern:
- `k8s/base/` — canonical HA configs (never modify directly)
- `k8s/overlays/{env}/` — patches per environment

## Consequences
- Base files are templates; users customize via overlays
- Overlay patches: JSON6902 for complex changes, merge patches for simple field overrides
- New environments: copy an existing overlay and adjust
- No drift between environments if base is untouched
