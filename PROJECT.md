# Project Plan

This file tracks completed milestones and the remaining project roadmap.

## Objective

Build a portable Kubernetes platform around a realistic microservices workload,
then operate it consistently across local Kubernetes, AWS EKS, and Azure AKS.

## Current Scope

- Portable application, platform, and observability Helm charts
- CI validation, GHCR publishing, and immutable image tag updates
- Argo CD app-of-apps delivery for local Kubernetes, EKS, and AKS
- Terraform-managed, multi-zone EKS and AKS environments
- Cloud-native identity, storage, autoscaling, load balancing, DNS, and HTTPS
- Protected OIDC pipelines for the AKS lifecycle
- Prometheus and Grafana observability baseline
- Security scanning baseline with Trivy

## Repository Structure

```text
.
├── src/
├── protos/
├── helm/
│   ├── application/
│   ├── observability/
│   └── platform/
│       ├── aws/
│       └── azure/
├── argocd/
│   ├── roots/
│   ├── applications/
│   │   ├── local/
│   │   ├── aws/
│   │   └── azure/
│   └── bootstrap/
├── terraform/
│   ├── aws/
│   │   ├── bootstrap/
│   │   └── eks/
│   └── azure/
│       ├── bootstrap/
│       └── aks/
├── docs/
│   └── diagrams/
├── .github/workflows/
├── LICENSE
├── PROJECT.md
└── README.md
```

The repository separates portable workload configuration from cloud-specific
infrastructure and platform components:

- `helm/` contains application, observability, and provider platform charts.
- `argocd/` contains roots, child Applications, and bootstrap metadata.
- `terraform/` separates bootstrap state from disposable EKS and AKS roots.
- `.github/workflows/` contains CI and protected Azure lifecycle workflows.

## Milestones

### 1. Project Foundation

- [x] Keep application source code and gRPC contracts
- [x] Keep upstream license and attribution
- [x] Add README and project plan
- [x] Initialize Git repository

### 2. Local Deployment Baseline

- [x] Create plain Kubernetes manifests for local deployment
- [x] Run the workload locally
- [x] Document local setup and teardown

### 3. Helm Packaging

- [x] Create a custom Helm chart
- [x] Add configurable chart values
- [x] Add chart validation

### 4. CI Validation

- [x] Add validation workflows
- [x] Check service builds and tests where practical
- [x] Validate Helm changes
- [x] Validate rendered Helm resources and Argo CD Applications

### 5. Local GitOps Delivery

- [x] Install Argo CD on the local cluster
- [x] Add Argo CD manifests
- [x] Deploy the workload through GitOps
- [x] Verify automated self-healing
- [x] Document the local sync workflow

### 6. AWS EKS Infrastructure

- [x] Bootstrap encrypted S3 remote state with state locking
- [x] Add Terraform code for the EKS environment
- [x] Use private worker subnets with NAT egress
- [x] Pin Terraform module versions
- [x] Add Terraform formatting and validation to CI
- [x] Run Terraform plan against AWS
- [x] Provision an EKS environment
- [x] Verify kubectl access to the EKS cluster
- [x] Document EKS creation and teardown
- [x] Add protected OIDC create/update and destroy pipelines for EKS

### 7. Container Image Build and Publishing

- [x] Add GitHub Actions workflow for service image builds
- [x] Verify service image builds in GitHub Actions
- [x] Publish images to GitHub Container Registry
- [x] Tag images with commit SHAs
- [x] Open Helm image tag update pull requests for immutable GitOps deployments
- [x] Document image naming, tagging, and registry decisions

### 8. Deploy to EKS with Helm

- [x] Add EKS-specific Helm values
- [x] Deploy the workload to EKS with Helm
- [x] Validate service connectivity on EKS
- [x] Document the EKS Helm deployment workflow

### 9. Deploy to EKS with GitOps

- [x] Bootstrap Argo CD on EKS
- [x] Deploy the workload to EKS through GitOps
- [x] Validate frontend access with port forwarding
- [x] Document the EKS sync workflow

### 10. EKS Storage Layer

- [x] Split EKS platform resources into a provider-specific Helm chart
- [x] Add EKS `gp3` storage class configuration
- [x] Convert Redis cart storage from ephemeral storage to persistent storage
- [x] Install or configure the EBS CSI driver if required
- [x] Validate persistence across pod restarts
- [x] Document the EKS storage tradeoffs

### 11. EKS Ingress, HTTPS, and DNS

- [x] Install the AWS Load Balancer Controller through the AWS platform chart
- [x] Expose the frontend through an internet-facing Application Load Balancer
- [x] Provision and validate an ACM certificate with Terraform
- [x] Redirect HTTP traffic to HTTPS
- [x] Install ExternalDNS with EKS Pod Identity
- [x] Create and reconcile Route 53 records automatically
- [x] Document validation and teardown order

### 12. Observability

- [x] Package a fixed `kube-prometheus-stack` version
- [x] Deploy Prometheus and Grafana through Argo CD
- [x] Validate dashboards and monitoring resource usage
- [x] Add observability Helm chart validation to CI
- [x] Add project-specific alerts

### 13. Pod and Node Autoscaling

- [x] Add Horizontal Pod Autoscaler
- [x] Add Cluster Autoscaler

### 14. Security Hardening

- [x] Add workload security defaults
- [x] Add workload NetworkPolicies
- [ ] Add secret management approach
- [ ] Add dependency update automation
- [x] Add repository dependency and secret scanning
- [x] Scan images before publishing
- [x] Scan Terraform configuration
- [x] Scan Dockerfiles
- [x] Scan rendered Kubernetes configuration

### 15. AKS Platform

- [x] Bootstrap AKS remote state and GitHub Actions OIDC identities
- [x] Provision a multi-zone, autoscaling AKS environment through Terraform
- [x] Validate pipeline-based creation and teardown
- [x] Add persistent storage
- [x] Add Gateway API routing, DNS, and HTTPS
- [x] Document AKS creation and teardown
- [x] Migrate the bootstrap state to an isolated remote backend

### 16. Deploy to AKS with GitOps

- [x] Add local, AWS, and Azure app-of-apps roots
- [x] Bootstrap Argo CD manually on AKS
- [x] Deploy the workload and observability to AKS through GitOps
- [x] Validate the frontend through port forwarding
- [x] Automate Argo CD bootstrap in the Azure deployment workflow
- [x] Pass Azure infrastructure metadata to Argo CD through GitOps Bridge
- [x] Add sync waves across platform, workload, and observability Applications
- [ ] Document EKS and AKS differences

### 17. Portfolio Documentation

- [x] Add architecture diagrams
- [ ] Add screenshots
- [ ] Document design decisions and tradeoffs
