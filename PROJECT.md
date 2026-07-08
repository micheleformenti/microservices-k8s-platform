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
- Terraform-managed AKS cluster
- Observability and security hardening

## Planned Structure

```text
.
├── src/
├── protos/
├── manifests/
├── helm/
├── gitops/
├── infra/
├── docs/
├── .github/
├── LICENSE
├── PROJECT.md
└── README.md
```

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

- [ ] Install Argo CD on the local cluster
- [ ] Add Argo CD manifests
- [ ] Deploy the workload through GitOps
- [ ] Document the local sync workflow

### 6. EKS Platform

- [ ] Provision an EKS environment
- [ ] Document EKS creation and teardown

### 7. Deploy to EKS with GitOps

- [ ] Bootstrap Argo CD on EKS
- [ ] Deploy the workload to EKS through GitOps
- [ ] Document the EKS sync workflow

### 8. Observability

- [ ] Add metrics and dashboards
- [ ] Add logging approach
- [ ] Document troubleshooting workflow

### 9. Security Hardening

- [ ] Add workload security defaults
- [ ] Add secret management approach
- [ ] Add security scanning

### 10. AKS Platform

- [ ] Provision an AKS environment
- [ ] Document AKS creation and teardown

### 11. Deploy to AKS with GitOps

- [ ] Bootstrap Argo CD on AKS
- [ ] Deploy the workload to AKS through GitOps
- [ ] Document EKS and AKS differences

### 12. Portfolio Documentation

- [ ] Add architecture diagrams
- [ ] Add screenshots
- [ ] Document design decisions and tradeoffs
