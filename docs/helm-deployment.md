# Helm Deployment

This document describes how to deploy the local microservices workload with the
custom Helm chart in `helm/`.

## Validate

Render the chart locally:

```sh
helm template microservices-platform ./helm
```

Run Helm lint:

```sh
helm lint ./helm
```

## Install

If the plain manifests are currently deployed, remove them first:

```sh
kubectl delete -f manifests/
```

Install the chart:

```sh
helm install microservices-platform ./helm
```

The chart creates and deploys into the `microservices-platform` namespace.

## Install with Published GHCR Images

Use `helm/values-local.yaml` to test the service images published to GitHub
Container Registry:

```sh
helm upgrade --install microservices-platform ./helm \
  --namespace microservices-platform \
  --create-namespace \
  -f helm/values.yaml \
  -f helm/values-local.yaml
```

This keeps the base chart values unchanged and overrides only the custom
service image repositories, tags, and pull policies.

## Install on EKS

Use `helm/values-eks.yaml` for the first EKS smoke test:

```sh
helm upgrade --install microservices-platform ./helm \
  --namespace microservices-platform \
  --create-namespace \
  -f helm/values.yaml \
  -f helm/values-eks.yaml
```

The EKS values file uses public GHCR images and keeps the frontend service as
`ClusterIP`. Frontend access is verified with port forwarding until an ingress
layer is added.

## Verify

Check the Helm release:

```sh
helm list -n microservices-platform
```

Check workloads:

```sh
kubectl get pods -n microservices-platform
```

Check services:

```sh
kubectl get svc -n microservices-platform
```

With the default local values, the frontend is exposed through NodePort:

```text
http://localhost:30010
```

With the EKS values file, use port forwarding:

```sh
kubectl port-forward -n microservices-platform svc/frontend 8080:80
```

Open:

```text
http://localhost:8080
```

## Upgrade

After changing chart templates or values:

```sh
helm upgrade microservices-platform ./helm
```

## Uninstall

Remove the Helm release:

```sh
helm uninstall microservices-platform -n microservices-platform
```
