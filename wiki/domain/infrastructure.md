# Infrastructure Dependencies

## Databases

### MongoDB (Percona)
- Operator: `k8s/base/mongodb/percona-operator/`
- Instance: `plantsuite-psmdb` in `mongodb` namespace
- Use: unstructured data, timeseries

### PostgreSQL (Percona)
- Operator: `k8s/base/postgresql/percona-operator/`
- Instance: `plantsuite-ppgc` in `postgresql` namespace
- Use: transactional data, VerneMQ auth backend

### Redis (Custom StatefulSet)
- 6 replicas, cluster mode, 5Gi PVC each
- Pods: `plantsuite-redis-{0..5}`
- Scripts: init-config, init-cluster, redis-healer
- ConfigMap generated from `k8s/base/redis/config/`

## Messaging

### RabbitMQ
- Operator: `k8s/base/rabbitmq/operator/`
- Instance: `plantsuite-rmq` in `rabbitmq` namespace
- Use: async inter-service communication

### VerneMQ (MQTT)
- Helm chart 2.1.1, 3 replicas, 5Gi PVC each
- Auth: PostgreSQL-backed (vmq-diversity plugin, Lua script)
- Ports: 1883 (MQTT), 8883 (MQTTS), 8080 (WebSocket)
- Shared subscription: prefer_local

## IAM
### Keycloak
- Operator: `k8s/base/keycloak/operator-v26.5.1/`
- Instance: `plantsuite-kc` in `keycloak` namespace
- URL: `account.plantsuite.local`

## Observability
### Aspire Dashboard
- `k8s/base/aspire/`
- OTLP endpoint: `http://dashboard.aspire.svc.cluster.local:4317`
- URL: `aspire-dashboard.plantsuite.local`
