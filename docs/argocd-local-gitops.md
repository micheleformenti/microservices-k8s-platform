# Local GitOps Delivery with Argo CD

This document describes how Argo CD deploys the Helm chart to the local
Kubernetes cluster and automatically corrects configuration drift.

## Architecture

```text
GitHub repository (main)
        |
        | watches helm/
        v
Argo CD Application
        |
        | renders and applies the Helm chart
        v
microservices-platform namespace
```

Git is the source of truth. Argo CD reads the chart from `helm/`; changes made
directly in the cluster are not treated as lasting configuration changes.

## Prerequisites

- A running local Kubernetes cluster
- `kubectl` configured for that cluster
- Helm installed
- Public service images published to GitHub Container Registry as described in
  [Container Images](container-images.md)
- The required Helm changes committed and pushed to the `main` branch

Verify cluster access:

```sh
kubectl get nodes
```

## Install Argo CD

Add the Argo Helm repository and update the local chart index:

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

Install Argo CD into its own namespace:

```sh
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace
```

Check Argo CD pods:

```sh
kubectl get pods -n argocd
```

Verify the Helm release:

```sh
helm list -n argocd
helm status argocd -n argocd
```

## Application Configuration

The application is defined in
[`argocd/applications/local.yaml`](../argocd/applications/local.yaml).

Its important settings are:

- Repository: this project's GitHub repository
- Revision: `main`
- Source path: `helm`
- Helm value files: `values.yaml` and `values-local.yaml`
- Destination: the in-cluster Kubernetes API
- Release name: `microservices-platform`
- Automated sync: enabled
- Pruning: enabled, so resources removed from Git are removed from the cluster
- Self-healing: enabled, so manual changes are reverted to the Git state

The Helm chart creates the `microservices-platform` namespace.

## Create and Sync the Application

Apply the declarative Argo CD `Application` resource:

```sh
kubectl apply -f argocd/applications/local.yaml
```

Argo CD automatically renders and syncs the Helm chart. No separate
`helm install` command is required.

Watch the application until it reports `Synced` and `Healthy`:

```sh
kubectl get application microservices-platform-local -n argocd -w
```

Inspect detailed status if synchronization fails:

```sh
kubectl describe application microservices-platform-local -n argocd
```

Verify the deployed workload:

```sh
kubectl get pods -n microservices-platform
kubectl get services -n microservices-platform
```


## Test Self-Healing

The chart declares one frontend replica. Introduce drift by scaling the
Deployment manually:

```sh
kubectl scale deployment/frontend -n microservices-platform --replicas=3
```

Observe the Deployment and the Argo CD application:

```sh
kubectl get deployment/frontend -n microservices-platform -w
kubectl get application microservices-platform-local -n argocd
```

Argo CD detects that the live replica count differs from the chart and restores
it to one. Confirm the result:

```sh
kubectl get deployment/frontend -n microservices-platform \
  -o jsonpath='{.spec.replicas}{"\n"}'
```

Expected output:

```text
1
```

This demonstrates reconciliation: an imperative cluster change is temporary,
and the declared state in Git remains authoritative.

## Make a GitOps Change

For an intentional configuration change:

1. Edit the chart or `helm/values.yaml`.
2. Validate the chart with `helm lint` and `helm template`.
3. Commit and push the change to `main`.
4. Watch Argo CD synchronize the new revision.

```sh
kubectl get application microservices-platform-local -n argocd -w
```

Do not use `kubectl edit`, `kubectl scale`, or `helm upgrade` for lasting
changes to resources managed by this application. Argo CD will reconcile those
changes back to the state stored in Git.

## Access the Argo CD UI

Forward the API server service:

```sh
kubectl port-forward service/argocd-server -n argocd 8080:443
```

Open:

```text
https://localhost:8080
```

The browser may warn about the local self-signed certificate.

Retrieve the initial administrator password if needed:

```sh
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 --decode
echo
```

The initial username is `admin`. For a shared or production environment, rotate
the initial password and configure proper identity and access management.

## Teardown

Delete the application to stop reconciliation:

```sh
kubectl delete -f argocd/applications/local.yaml
```

The current `Application` manifest does not use Argo CD's cascading-deletion
finalizer. Remove the workload namespace explicitly:

```sh
kubectl delete namespace microservices-platform
```

Uninstall the Helm release and remove its namespace:

```sh
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```
