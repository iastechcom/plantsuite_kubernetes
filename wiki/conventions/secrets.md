# Secret Management

## Pattern
1. `.env.secret` files (gitignored) contain environment variables
2. `secretGenerator` in `kustomization.yaml` reads from `.env.secret`
3. `disableNameSuffixHash: true` — stable names, no hash suffix
4. Secrets mounted via `envFrom: secretRef` in containers

## Files
| File | Secret Name | Type |
|------|-------------|------|
| `.env.secret` | `plantsuite-env` | Opaque |
| `dockerconfig.json` | `plantsuite-cr` | kubernetes.io/dockerconfigjson |
| `license.crt` | `plantsuite-license` | Opaque (file mount) |

## Management Script
- `tools/lib/secrets.sh` — AWK-based file manipulation
- `set_env_value()` / `get_env_value()` — read/write .env.secret
- `get_k8s_secret_value()` — read from existing K8s secrets (base64)
- `sanitize_env_file()` — remove invalid keys
- Idempotent: safe to run multiple times

## Gitignored
- `.env.secret` (credentials)
- `dockerconfig.json` (registry creds)
- `license.crt` (licensed file)
