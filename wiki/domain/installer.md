# Installer (TUI)

## Entry Point
`tools/install.sh` — bash TUI wizard

## Pipeline Phases (tools/lib/pipeline.sh)
Fixed order, 12+ phases:
1. metrics-server (conditional skip)
2. cert-manager-operator
3. cert-manager-issuers
4. istio-system
5. istio-ingress
6. aspire (conditional)
7. mongodb-operator + mongodb-instance (conditional)
8. postgresql-operator + postgresql-instance (conditional)
9. redis (conditional)
10. keycloak-operator + keycloak-instance (conditional)
11. rabbitmq-operator + rabbitmq-instance (conditional)
12. vernemq (conditional)
13. plantsuite-base
14. plantsuite-service:{name} (per selected service)

## TUI Screens (tools/lib/screen-*.sh)
1. **screen-context.sh** — K8s context selection
2. **screen-overlay.sh** — overlay selection (demo/production/base)
3. **screen-discovery.sh** — auto-detect install vs update
4. **screen-services.sh** — service multi-select (17 services)
5. **screen-infra-optional.sh** — optional infra (gateway-only mode)
6. **screen-confirmation.sh** — review before install
7. **screen-execution-real.sh** — progress bar, spinner, log tailing
8. **screen-update-selection.sh** — update component selection
9. **screen-confirmation-update.sh** — review update plan
10. **screen-infra-update.sh** — infra update selection
11. **screen-services-update.sh** — services update selection

## Execution Layer (tools/lib/k8s-adapter.sh)
```bash
kubectl kustomize --enable-helm <path> | kubectl apply --server-side --force-conflicts -f -
```
- Server-side apply, force conflict resolution
- Retry: max 5 attempts, 20s delay

## Update Detection (tools/lib/update-detect.sh)
- Probes deployments/statefulsets/operators
- Returns: absent/degraded/installed
- Switches between install and update mode

## Secrets (tools/lib/secrets.sh)
- AWK-based .env.secret manipulation
- Functions: set_env_value, get_env_value, get_k8s_secret_value
- Idempotent

## Update & Delete Pipelines (tools/lib/pipeline.sh)

- `build_update_pipeline()` — orchestrates a mixed update: deletes selected services/infra in reverse order, then applies updated infra and services.
- `build_infra_delete_pipeline()` — deletes selected infra components in reverse dependency order (vernemq → metrics-server).
- `append_infra_update_steps(component)` — adds update steps for a single infra component (operator + instance).
- `append_infra_delete_steps(component)` — adds delete steps for a single infra component (instance first, then operator).
- `REMOVE_ALL_MODE` — when true, deletes the entire plantsuite namespace instead of per-service removal.

## TUI Primitives (tools/lib/common/tui.sh)

Shared TUI helpers used across all `screen-*.sh` modules — provides reusable UI primitives (prompts, menus, formatting) for the bash wizard.

## Metrics Server TLS Fix (tools/lib/metrics-server-tls-fix.sh)
- Auto-patches `--kubelet-insecure-tls` on x509 errors
- Scans all selector pods, idempotent
