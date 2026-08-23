# Local Kubernetes and GitOps

This guide covers the local delivery paths used by the project:

```text
Helm chart -> Argo CD reconciliation
```

The workflow was tested with Rancher Desktop and its Docker runtime.

## Prerequisites

- a local Kubernetes cluster
- Docker, kubectl, and Helm
- public service images in GHCR for the Helm and Argo CD paths

Confirm that Docker and kubectl target the intended local environment:

```sh
docker context use rancher-desktop
kubectl get nodes
```

## Helm Deployment

`helm/application` packages the same workload with configurable images,
resources, service exposure, and Redis persistence.

Validate the chart:

```sh
helm lint ./helm/application
helm template microservices-platform ./helm/application
```

Install it with the published GHCR images:

```sh
helm upgrade --install microservices-platform ./helm/application \
  --namespace microservices-platform \
  --create-namespace \
  -f helm/application/values.yaml \
  -f helm/application/values-local.yaml
```

Helm applies value files from left to right, so `values-local.yaml` overrides
matching base values while inheriting everything else.

```sh
helm list -n microservices-platform
kubectl get pods -n microservices-platform
```

Before switching ownership to Argo CD, uninstall the manual release:

```sh
helm uninstall microservices-platform -n microservices-platform
```

## Local GitOps with Argo CD

```text
GitHub main -> local root -> workload + observability
```

Install Argo CD with Helm:

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace
```

The local root creates workload and observability child Applications. Both
track `main` with automated sync, pruning, and self-healing.

```sh
kubectl apply -f argocd/roots/local.yaml
kubectl get applications -n argocd -w
```

Argo CD now owns the workload; lasting changes should be committed to Git rather
than applied with `kubectl edit`, `kubectl scale`, or `helm upgrade`.

### Verify self-healing

Create drift by changing the frontend replica count:

```sh
kubectl scale deployment/frontend -n microservices-platform --replicas=3
kubectl get deployment/frontend -n microservices-platform -w
```

Argo CD restores the Helm value of one replica, demonstrating that Git remains
the source of truth.

### Argo CD UI

```sh
kubectl port-forward service/argocd-server -n argocd 8080:443
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 --decode
```

Open `https://localhost:8080` and sign in as `admin`.

## Teardown

Delete the root first so it cannot recreate its children, then remove the child
Applications and Argo CD:

```sh
kubectl delete -f argocd/roots/local.yaml
argocd app delete local-observability --cascade --yes
argocd app delete local-workload --cascade --yes
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```
