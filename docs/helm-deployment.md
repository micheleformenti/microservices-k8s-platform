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

The frontend is exposed through NodePort:

```text
http://localhost:30010
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

