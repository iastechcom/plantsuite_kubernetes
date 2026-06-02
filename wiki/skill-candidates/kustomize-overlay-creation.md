---
name: kustomize-overlay-creation
encounters: 1
status: candidate
---

## Trigger
User requests a new environment overlay (e.g., staging, qa, custom-prod).

## Why a skill
Creating a new overlay requires:
1. Copying the correct base structure
2. Selecting appropriate patches for the environment
3. Adjusting replica counts, resource limits, HPA settings
4. Ensuring kustomization.yaml references are correct
5. Validating with `kubectl kustomize` dry-run

Non-obvious steps: which patches to include, how to structure JSON6902 patches, which components to scale differently.

## Pattern
1. Copy `k8s/overlays/demo/` or `k8s/overlays/production/` as starting point
2. Edit kustomization.yaml — update namespace, patches, images
3. Adjust patches/ for target environment (replicas, resources, PDBs)
4. Validate: `kubectl kustomize --enable-helm k8s/overlays/{name}/`
5. Update installer pipeline if new overlay should appear in TUI
