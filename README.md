# Microservices Kubernetes Platform

Production-inspired platform engineering project that delivers the same
microservices workload to local Kubernetes, AWS EKS, and Azure AKS.

The project demonstrates the full lifecycle: CI, container publishing,
Infrastructure as Code, GitOps delivery, cloud networking, autoscaling,
persistence, DNS, HTTPS, and environment teardown.

## Platform Highlights

- **Infrastructure:** Terraform-managed, multi-zone EKS and AKS environments
  with private worker nodes and controlled egress.
- **Identity:** Cloud pipelines use GitHub Actions OIDC; controllers use AWS Pod
  Identity and Azure Workload Identity.
- **GitOps:** Argo CD app-of-apps delivery, with GitOps Bridge metadata for
  dynamic cloud infrastructure values.
- **Runtime:** persistent storage, Horizontal Pod Autoscaling, and node
  autoscaling.
- **Traffic:** AWS ALB and Azure Application Gateway for Containers, with
  automated DNS and HTTPS.
- **Lifecycle:** protected create/update and destroy workflows support
  disposable EKS and AKS environments.

## Delivery Architecture

```text
Pull request
      ↓
GitHub Actions
  ├── tests and validates application, Helm, and Argo CD
  └── scans and publishes immutable images to GHCR
      ↓
Terraform provisions
  └── EKS and AKS through protected OIDC pipelines
      ↓
Argo CD reconciles
  ├── cloud platform components
  ├── application workload
  └── observability stack
      ↓
Cloud load balancing, DNS, and HTTPS
```

## Repository Layout

```text
src/                 Microservices source code
helm/                Application, platform, and observability charts
argocd/              App-of-apps roots, Applications, and bootstrap metadata
terraform/           AWS and Azure infrastructure
.github/workflows/   Application CI and protected cloud lifecycle pipelines
docs/                Platform guides and architecture diagrams
```

## Platform Status

| Status | Area | Guide |
|--------|------|-------|
| ✅ | CI validation, GHCR publishing, and GitOps image updates | [CI/CD](docs/ci.md) |
| ✅ | AWS EKS: storage, autoscaling, HTTPS, and DNS | [EKS](docs/eks.md) |
| ✅ | Azure AKS: storage, autoscaling, HTTPS, and DNS | [AKS](docs/aks.md) |
| ✅ | Prometheus, Grafana, and project alerts | [Observability](docs/observability.md) |
| ✅ | Trivy dependency, secret, image, and Terraform scanning | [Security](docs/security.md) |
| ⏳ | Security hardening | Roadmap |

## Documentation

- [Local development and GitOps](docs/local.md)
- [CI/CD and image publishing](docs/ci.md)
- [AWS EKS platform](docs/eks.md)
- [Azure AKS platform](docs/aks.md)
- [Observability](docs/observability.md)
- [Security scanning](docs/security.md)
- [Implementation roadmap](PROJECT.md)

## Workload

The workload is based on Google's
[Online Boutique](https://github.com/GoogleCloudPlatform/microservices-demo),
licensed under Apache 2.0.
