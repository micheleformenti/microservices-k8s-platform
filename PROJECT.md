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
- Argo CD app-of-apps delivery for local, EKS, and AKS
- Terraform-managed EKS cluster
- Container image build and publishing
- Terraform-managed AKS cluster
- EKS storage integration
- EKS ingress, HTTPS, and automated DNS
- EKS pod and node autoscaling
- Prometheus and Grafana observability baseline
- Security hardening

## Repository Structure

```text
.
├── src/
├── protos/
├── manifests/
├── helm/
│   ├── application/
│   ├── observability/
│   └── platform/
│       └── aws/
├── argocd/
│   ├── roots/
│   └── applications/
├── terraform/
│   ├── aws/
│   └── azure/
├── docs/
├── .github/
├── LICENSE
├── PROJECT.md
└── README.md
```

The Helm structure separates the portable workload from provider-specific
platform resources:

- `helm/application/` contains the shared application chart.
- `helm/platform/aws/` contains AWS/EKS-specific platform resources.

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

- [x] Bootstrap encrypted S3 remote state with state locking
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
- [ ] Add project-specific alerts

### 13. Pod and Node Autoscaling

- [x] Add Horizontal Pod Autoscaler
- [x] Add Cluster Autoscaler

### 14. Security Hardening

- [ ] Add workload security defaults
- [ ] Add secret management approach
- [ ] Add security scanning

### 15. AKS Platform

- [x] Bootstrap remote state and GitHub Actions OIDC identities
- [x] Provision a multi-zone, autoscaling AKS environment through Terraform
- [x] Validate pipeline-based creation and teardown
- [ ] Add persistent storage
- [ ] Add ingress, DNS, and HTTPS
- [ ] Document AKS creation and teardown

### 16. Deploy to AKS with GitOps

- [x] Add local, AWS, and Azure app-of-apps roots
- [x] Bootstrap Argo CD manually on AKS
- [x] Deploy the workload and observability to AKS through GitOps
- [x] Validate the frontend through port forwarding
- [ ] Automate Argo CD bootstrap in the Azure deployment workflow
- [ ] Document EKS and AKS differences

### 17. Portfolio Documentation

- [x] Add architecture diagrams
- [ ] Add screenshots
- [ ] Document design decisions and tradeoffs
