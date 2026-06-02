# Naming Conventions

## Resources
- **Services**: lowercase, matches deployment name (`devices`, `portal`, `gateway`)
- **Namespaces**: component name (`plantsuite`, `mongodb`, `istio-ingress`)
- **StatefulSets**: prefixed (`plantsuite-redis-{0..5}`, `plantsuite-vmq`)
- **ConfigMaps**: `{service}-appsettings` or generated via configMapGenerator
- **Secrets**: `plantsuite-env`, `plantsuite-cr`, `plantsuite-license`, `{service}-env`

## Container Images
- Registry: `plantsuite.azurecr.io`
- Pattern: `plantsuite-{service-name}:{tag}`
- Tags: semver (`0.45.0`, `0.12.2`) or PR tags (`pr-1014.5`)
- Override via `images` section in kustomization.yaml

## VirtualServices
- Host: `{service}.plantsuite.local`
- Route: `→ {service}:80` (ClusterIP)
- Gateway: `istio-ingress/gateway`

## Helm Releases
- Istio: charts from `https://istio-release.storage.googleapis.com/charts`
- VerneMQ: chart from `https://vernemq.github.io/docker-vernemq`
