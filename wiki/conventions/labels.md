# Labels & Selectors

## Global Labels (applied via kustomization.yaml)
- `app.kubernetes.io/part-of: plantsuite` — all PlantSuite resources

## Per-Service Labels
- `app: {service-name}`
- `app.kubernetes.io/name: {service-name}`

## Kustomize Settings
- `includeSelectors: true` — labels applied to resource selectors
- `includeTemplates: true` — labels applied to pod templates

## Istio Labels
- `istio: gateway` — Istio gateway pod selector

## Selector Matching
Deployments use label selectors matching `app: {service-name}`.
PDBs and HPAs reference the same selectors.
