# Microservices Kubernetes Platform

> **Project status:** Active development.
> Completed and planned work is tracked in [PROJECT.md](PROJECT.md).

Production-inspired platform engineering project focused on Kubernetes, GitOps, Infrastructure as Code, observability, and security. The microservices application serves as a realistic workload.

## Current Progress

| Status | Component | Documentation |
|---------|-----------|---------------|
| ✅ | Local Kubernetes, Helm, and Argo CD delivery | [Guide](docs/local.md) |
| ✅ | CI validation, GHCR publishing, and GitOps image updates | [Guide](docs/ci.md) |
| ✅ | AWS EKS platform: Terraform, GitOps, storage, autoscaling, HTTPS, and DNS | [Guide](docs/eks.md) |
| 🚧 | Observability | In progress |
| ⏳ | Security hardening | Planned |
| ⏳ | AKS deployment | Planned |

## Architecture

<p align="center">
  <img src="docs/diagrams/eks-platform-architecture.svg" alt="EKS platform architecture" width="900">
</p>

The diagram shows the current AWS implementation. See the
[AWS EKS platform guide](docs/eks.md) for deployment details and tradeoffs.

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

## Attribution

Application source code is based on Google's
[Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo)
project, licensed under Apache 2.0.
