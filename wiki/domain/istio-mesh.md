# Istio Service Mesh

## Mode: Ambient (CNI-based, no sidecar)
- Profile: `ambient`
- CNI plugin handles traffic redirection
- ZTunnel DaemonSet for L4 traffic interception
- No sidecar injection needed

## Control Plane (`k8s/base/istio-system/`)
- Helm charts: base, istiod, cni, ztunnel (all v1.29.1)
- Chart repo: `https://istio-release.storage.googleapis.com/charts`

## Ingress Gateway (`k8s/base/istio-ingress/`)
- Helm chart: gateway v1.28.2
- Service type: LoadBalancer
- Replicas: 3-6 (HPA)
- Ports: 15021 (status), 80 (HTTP), 443 (HTTPS), 1883 (MQTT), 8883 (MQTTS)

## Gateway Routing
- HTTP → HTTPS redirect (301)
- HTTPS: TLS SIMPLE, wildcard cert (*.plantsuite.local)
- MQTT: TCP passthrough (1883)
- MQTTS: TLS SIMPLE, MQTT cert (8883)

## VirtualService Pattern
Every service gets a VirtualService:
- Host: `{service}.plantsuite.local`
- Gateway: `istio-ingress/gateway`
- Route: `→ {service}:80`

## Key Files
- `k8s/base/istio-ingress/gateway.yaml` — gateway definition
- `k8s/base/istio-ingress/certificate-wildcard.yaml` — wildcard cert
- `k8s/base/istio-ingress/certificate-mqtt.yaml` — MQTT cert
- `k8s/base/istio-ingress/helm-values.yaml` — gateway helm values
