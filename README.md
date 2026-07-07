# Microservices Kubernetes Platform

Production-style Kubernetes platform project for deploying a microservices
workload.

The focus is the platform layer: Kubernetes, Helm, GitOps, Terraform,
observability, and security. The application is used as a realistic workload.

## Stack

- Kubernetes
- Helm
- Argo CD
- Terraform
- EKS
- AKS
- CI/CD
- Observability
- Kubernetes security hardening

## Workload

The workload is based on Google's Online Boutique demo application.

```text
src/      Microservices source code
protos/   gRPC API contracts
```

## Roadmap

Project scope, planned structure, and milestone checklist are tracked in
[PROJECT.md](PROJECT.md).

## Documentation

- [Local Kubernetes deployment](docs/local-deployment.md)
- [Helm deployment](docs/helm-deployment.md)

## Attribution

Application source code is based on Google's
[Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo)
project, licensed under Apache 2.0.
