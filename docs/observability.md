# Observability

The platform deploys a pinned `kube-prometheus-stack` release through Argo CD
on local Kubernetes, EKS, and AKS.

## Architecture

```text
Nodes and Kubernetes resources
            ↓
node-exporter + kube-state-metrics
            ↓
Prometheus
  ├── standard Kubernetes alerts
  └── application availability alerts
            ↓
       Alertmanager

Prometheus → Grafana dashboards
```

Prometheus retains metrics for 24 hours. This is sufficient for disposable
portfolio environments; persistent monitoring storage is outside the current
scope.

## Project Alerts

| Alert | Condition | Severity |
|-------|-----------|----------|
| `ApplicationDeploymentUnavailable` | A customer-serving Deployment has no available replicas for 2 minutes | Critical |
| `ApplicationStatefulSetUnavailable` | Redis has no ready replicas for 2 minutes | Critical |

The Deployment alert excludes the non-customer-facing load generator.

## Access

Prometheus:

```sh
kubectl port-forward \
  --namespace monitoring \
  service/observability-kube-prometh-prometheus \
  9090:9090
```

Grafana:

```sh
kubectl port-forward \
  --namespace monitoring \
  service/observability-grafana \
  3000:80
```

Retrieve the generated Grafana administrator password:

```sh
kubectl get secret observability-grafana \
  --namespace monitoring \
  --output jsonpath='{.data.admin-password}' | base64 --decode
echo
```

Alertmanager:

```sh
kubectl port-forward \
  --namespace monitoring \
  service/observability-kube-prometh-alertmanager \
  9093:9093
```

## Verification

Confirm that Kubernetes and Prometheus discovered the rules:

```sh
kubectl get prometheusrule microservices-platform --namespace monitoring

curl --silent http://localhost:9090/api/v1/rules |
  jq '.data.groups[] | select(.name == "microservices-platform.rules")'
```

Inspect active application alerts with:

```sh
curl --silent http://localhost:9090/api/v1/alerts |
  jq '.data.alerts[] | select(.labels.alertname | startswith("Application"))'
```

## Scope

This milestone covers Kubernetes infrastructure metrics, default Grafana
dashboards, and project-specific Prometheus alerts. Centralized logging,
distributed tracing, application metrics, external notification receivers,
and persistent monitoring storage are possible future improvements.
