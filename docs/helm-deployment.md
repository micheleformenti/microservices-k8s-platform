# Helm Deployment

This document describes how to deploy the local microservices workload with the
custom application Helm chart in `helm/application/`.

## Validate

Render the application chart locally:

```sh
helm template microservices-platform ./helm/application
```

Run Helm lint for the application chart:

```sh
helm lint ./helm/application
```

For EKS platform resources, validate the AWS platform chart separately:

```sh
helm lint ./helm/platform/aws
helm template aws-platform ./helm/platform/aws --namespace kube-system
```

## Install

If the plain manifests are currently deployed, remove them first:

```sh
kubectl delete -f manifests/
```

Install the chart:

```sh
helm install microservices-platform ./helm/application
```

The chart creates and deploys into the `microservices-platform` namespace.

## Install with Published GHCR Images

Use `helm/application/values-local.yaml` to test the service images published
to GitHub Container Registry:

```sh
helm upgrade --install microservices-platform ./helm/application \
  --namespace microservices-platform \
  --create-namespace \
  -f helm/application/values.yaml \
  -f helm/application/values-local.yaml
```

This keeps the base chart values unchanged and overrides only the custom
service image repositories, tags, and pull policies.

## Install on EKS

Install the AWS platform chart first when testing EKS-specific platform
resources without Argo CD:

```sh
helm upgrade --install aws-platform ./helm/platform/aws \
  --namespace kube-system
```

Use `helm/application/values-eks.yaml` for the first EKS smoke test:

```sh
helm upgrade --install microservices-platform ./helm/application \
  --namespace microservices-platform \
  --create-namespace \
  -f helm/application/values.yaml \
  -f helm/application/values-eks.yaml
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
helm upgrade microservices-platform ./helm/application
```

## Uninstall

Remove the Helm release:

```sh
helm uninstall microservices-platform -n microservices-platform
```
