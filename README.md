# Microservices Kubernetes Platform

> **Project status:** Active development.
> Completed and planned work is tracked in [PROJECT.md](PROJECT.md).

Production-inspired platform engineering project focused on Kubernetes, GitOps, Infrastructure as Code, observability, and security. The microservices application serves as a realistic workload.

## Current Progress

| Status | Component | Documentation |
|---------|-----------|---------------|
| ✅ | Local Kubernetes deployment | [Guide](docs/local-deployment.md) |
| ✅ | Helm deployment | [Guide](docs/helm-deployment.md) |
| ✅ | CI validation | [Guide](docs/ci-validation.md) |
| ✅ | Local GitOps with Argo CD | [Guide](docs/argocd-local-gitops.md) |
| 🚧 | Terraform-managed EKS | Coming soon |
| 🚧 | GitOps on EKS | Coming soon |
| ⏳ | Observability | Planned |
| ⏳ | Security hardening | Planned |
| ⏳ | AKS deployment | Planned |

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
- [CI validation](docs/ci-validation.md)
- [Local GitOps delivery with Argo CD](docs/argocd-local-gitops.md)

## Attribution

Application source code is based on Google's
[Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo)
project, licensed under Apache 2.0.
