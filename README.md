# Microservices Kubernetes Platform

Production-inspired platform engineering project that delivers the same
microservices workload to local Kubernetes, AWS EKS, and Azure AKS.

The project demonstrates the full lifecycle: CI, container publishing,
Infrastructure as Code, GitOps delivery, cloud networking, autoscaling,
persistence, DNS, HTTPS, and environment teardown.

## Platform Status

| Status | Area | Guide |
|--------|------|-------|
| ✅ | CI validation, GHCR publishing, and GitOps image updates | [CI/CD](docs/ci.md) |
| ✅ | AWS EKS: storage, autoscaling, HTTPS, and DNS | [EKS](docs/eks.md) |
| ✅ | Azure AKS: storage, autoscaling, HTTPS, and DNS | [AKS](docs/aks.md) |
| 🚧 | Observability | Roadmap |
| ⏳ | Security hardening | Roadmap |

## Delivery Architecture

```text
Pull request
      ↓
GitHub Actions
  ├── tests and validates application, Helm, Argo CD, and Terraform
  └── publishes immutable images to GHCR
      ↓
Terraform provisions
  ├── EKS through the documented manual workflow
  └── AKS through protected OIDC pipelines
      ↓
Argo CD reconciles
  ├── cloud platform components
  ├── application workload
  └── observability stack
      ↓
Cloud load balancing, DNS, and HTTPS
```

## Platform Highlights

- **Infrastructure:** Terraform-managed, multi-zone EKS and AKS environments
  with private worker nodes and controlled egress.
- **Identity:** Azure pipelines use GitHub Actions OIDC; controllers use AWS
  Pod Identity and Azure Workload Identity.
- **GitOps:** Argo CD app-of-apps delivery, with GitOps Bridge metadata for
  dynamic Azure infrastructure values.
- **Runtime:** persistent storage, Horizontal Pod Autoscaling, and node
  autoscaling.
- **Traffic:** AWS ALB and Azure Application Gateway for Containers, with
  automated DNS and HTTPS.
- **Lifecycle:** protected AKS create/update and destroy workflows support
  disposable environments; the same pipeline model is planned for EKS.

## Documentation

- [Local development and GitOps](docs/local.md)
- [CI/CD and image publishing](docs/ci.md)
- [AWS EKS platform](docs/eks.md)
- [Azure AKS platform](docs/aks.md)
- [Implementation roadmap](PROJECT.md)

## Repository Layout

```text
src/         Microservices source code
helm/        Application, platform, and observability charts
argocd/      App-of-apps roots, Applications, and bootstrap metadata
terraform/   AWS and Azure infrastructure
.github/     CI/CD and infrastructure workflows
docs/        Platform guides and architecture diagrams
```

## Workload

The workload is based on Google's
[Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo),
licensed under Apache 2.0.
