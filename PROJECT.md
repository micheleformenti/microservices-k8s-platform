# Project Plan

This file tracks the project direction and milestone progress. Details will be
added incrementally as each milestone starts.

## Objective

Build a Kubernetes platform around a realistic microservices workload, with the
focus on deployment, GitOps, infrastructure as code, observability, and security.

## Current Scope

- Local Kubernetes deployment
- Custom Helm packaging
- CI validation
- Argo CD GitOps delivery, starting locally
- Terraform-managed EKS cluster
- Container image build and publishing
- Terraform-managed AKS cluster
- EKS storage integration
- Observability and security hardening

## Planned Structure

```text
.
├── src/
├── protos/
├── manifests/
├── helm/
│   ├── application/
│   └── platform/
│       └── aws/
├── argocd/
│   └── applications/
├── terraform/
│   └── aws/
├── docs/
├── .github/
├── LICENSE
├── PROJECT.md
└── README.md
```

The Helm structure separates the portable workload from provider-specific
platform resources:

- `helm/application/` contains the cloud-neutral application chart.
- `helm/platform/aws/` contains AWS/EKS-specific platform resources.
- `helm/platform/azure/` is planned for the later AKS milestone.

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
- [x] Validate Kubernetes manifests
- [x] Add Dependabot for GitHub Actions update PRs

### 5. Local GitOps Delivery

- [x] Install Argo CD on the local cluster
- [x] Add Argo CD manifests
- [x] Deploy the workload through GitOps
- [x] Verify automated self-healing
- [x] Document the local sync workflow

### 6. AWS EKS Infrastructure

- [x] Add Terraform code for the EKS environment
- [x] Use private worker subnets with NAT egress
- [x] Pin Terraform module versions
- [x] Add Terraform formatting and validation to CI
- [x] Run Terraform plan against AWS
- [x] Provision an EKS environment
- [x] Verify kubectl access to the EKS cluster
- [x] Document EKS creation and teardown

### 7. Container Image Build and Publishing

- [x] Add GitHub Actions workflow for service image builds
- [x] Verify service image builds in GitHub Actions
- [x] Publish images to GitHub Container Registry
- [x] Tag images with commit SHAs
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

### 11. Observability

- [ ] Add metrics and dashboards
- [ ] Add logging approach
- [ ] Document troubleshooting workflow

### 12. Security Hardening

- [ ] Add workload security defaults
- [ ] Add secret management approach
- [ ] Add security scanning

### 13. AKS Platform

- [ ] Provision an AKS environment
- [ ] Document AKS creation and teardown

### 14. Deploy to AKS with GitOps

- [ ] Bootstrap Argo CD on AKS
- [ ] Deploy the workload to AKS through GitOps
- [ ] Document EKS and AKS differences

### 15. Portfolio Documentation

- [ ] Add architecture diagrams
- [ ] Add screenshots
- [ ] Document design decisions and tradeoffs
