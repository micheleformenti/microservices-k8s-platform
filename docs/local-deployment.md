# Local Kubernetes Deployment

This document describes how to run the microservices workload on a local
Kubernetes cluster using the plain manifests in `manifests/`.

The current local setup was tested with Rancher Desktop using Docker engine.

## Prerequisites

- Rancher Desktop with Kubernetes enabled
- Docker CLI using the Rancher Desktop context
- `kubectl` configured for the local cluster

Check the active Docker context:

```sh
docker context ls
```

If needed, switch to Rancher Desktop:

```sh
docker context use rancher-desktop
```

Check cluster access:

```sh
kubectl get nodes
```

## Build Images

The local manifests use simple image names and `imagePullPolicy: IfNotPresent`,
so the images must exist in the local container runtime.

```sh
docker build -t frontend ./src/frontend
docker build -t productcatalogservice ./src/productcatalogservice
docker build -t currencyservice ./src/currencyservice
docker build -t cartservice ./src/cartservice/src
docker build -t recommendationservice ./src/recommendationservice
docker build -t shippingservice ./src/shippingservice
docker build -t adservice ./src/adservice
docker build -t checkoutservice ./src/checkoutservice
docker build -t paymentservice ./src/paymentservice
docker build -t emailservice ./src/emailservice
docker build -t loadgenerator ./src/loadgenerator
```

## Deploy

Apply all local manifests:

```sh
kubectl apply -f manifests/
```

The resources are deployed to the `microservices-platform` namespace.

## Verify

Check workloads:

```sh
kubectl get pods -n microservices-platform
```

Check services:

```sh
kubectl get svc -n microservices-platform
```

The frontend is exposed through a local NodePort:

```text
http://localhost:30010
```

If NodePort access does not work in another local Kubernetes environment, use
port forwarding:

```sh
kubectl port-forward -n microservices-platform svc/frontend 8080:80
```

Then open:

```text
http://localhost:8080
```

## Load Generator

The load generator runs as a Kubernetes Deployment and sends traffic to the
frontend service.

## Restart After Rebuild

After rebuilding one or more images, restart the corresponding deployments:

```sh
kubectl rollout restart deployment -n microservices-platform
```

For a single service:

```sh
kubectl rollout restart deployment/frontend -n microservices-platform
```

## Teardown

Remove the local deployment:

```sh
kubectl delete -f manifests/
```
