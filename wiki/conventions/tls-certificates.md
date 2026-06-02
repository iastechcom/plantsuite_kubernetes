# TLS & Certificates

## cert-manager Setup
- Operator: `k8s/base/cert-manager/cert-manager-v1.19.1.yaml` (direct include)
- Namespace: `cert-manager`

## ClusterIssuer
- Name: `selfsigned`
- Type: Self-signed
- File: `k8s/base/cert-manager/issuers/clusterissuer-selfsigned.yaml`

## Certificates

| Certificate CR Name | Secret Name | Domain | Key Size | Duration | Renewal |
|---------------------|-------------|--------|----------|----------|---------|
| plantsuite-wildcard | plantsuite-wildcard-cert | *.plantsuite.local | 4096-bit RSA | 6 months | 30 days before |
| plantsuite-mqtt | plantsuite-mqtt-cert | MQTT-specific | 4096-bit RSA | 6 months | 30 days before |

> **Note**: The Certificate CR name (e.g. `plantsuite-wildcard`) differs from the Secret it generates (e.g. `plantsuite-wildcard-cert`). The `-cert` suffix is added by cert-manager.

## Extract CA Certificate
```bash
kubectl get secret plantsuite-wildcard-cert -n istio-ingress \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > plantsuite-ca.crt
```

## Gateway TLS
- HTTPS (443): TLS SIMPLE, uses wildcard cert
- MQTTS (8883): TLS SIMPLE, uses MQTT cert
- HTTP (80): redirects to HTTPS (301)
