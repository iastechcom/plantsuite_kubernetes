# ADR: Self-Signed Certificates

## Status: Accepted

## Context
Local/dev deployments need TLS without external CA dependency.

## Decision
Use cert-manager self-signed ClusterIssuer:
- Wildcard cert: `*.plantsuite.local` (4096-bit RSA, 6-month)
- MQTT-specific cert for broker TLS

## Consequences
- No external CA dependency
- CA certificate must be extracted and trusted manually
- Production: replace issuer with ACME/Let's Encrypt or corporate CA
- Certificates auto-renew 30 days before expiry
