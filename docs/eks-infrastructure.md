# EKS Infrastructure

This document describes the AWS EKS infrastructure defined in `terraform/aws/`.

The infrastructure was tested by applying the Terraform configuration,
connecting to the cluster with `kubectl`, and tearing the environment down
after verification.

## Architecture

The Terraform configuration creates a demo EKS environment in AWS:

```text
Internet
  |
Internet Gateway
  |
Public subnets
  |
NAT Gateway
  |
Private subnets
  |
EKS worker nodes
  |
Pods
```

The EKS API endpoint is public but restricted to the configured CIDR block.
Worker nodes run in private subnets and use NAT egress for outbound internet
access.

## Terraform Modules

The AWS layer uses pinned community Terraform modules:

- `terraform-aws-modules/vpc/aws`
- `terraform-aws-modules/eks/aws`

The VPC module is used to avoid low-value networking boilerplate. The EKS
module creates the EKS control plane, IAM roles, security groups, managed node
group, addons, access entries, and OIDC provider.

This is a deliberate tradeoff: the project keeps AWS infrastructure
reproducible while keeping the main focus on Kubernetes platform delivery,
Helm, GitOps, CI, and cloud deployment.

## Resources Created

Main resource groups:

- VPC with DNS support enabled
- Two public subnets
- Two private subnets
- Internet Gateway
- NAT Gateway and Elastic IP
- Public and private route tables
- EKS control plane
- EKS managed node group
- EKS addons:
  - CoreDNS
  - kube-proxy
  - VPC CNI
- IAM roles and policy attachments for the cluster and worker nodes
- EKS access entry for the cluster creator
- OIDC provider for IAM Roles for Service Accounts
- Security groups and rules for cluster-to-node and node-to-node traffic

## Cost-sensitive Resources

The main cost drivers are:

- EKS control plane
- NAT Gateway
- EC2 worker nodes
- EBS root volumes for worker nodes

The default node group uses Spot capacity:

```hcl
node_capacity_type  = "SPOT"
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
```

The configuration uses one NAT Gateway by default to reduce demo cost:

```hcl
single_nat_gateway = true
```

This is cheaper than one NAT Gateway per availability zone, but it is less
resilient. For a longer-lived or production-like environment, this tradeoff
should be revisited.

## Prerequisites

Required local tools:

- AWS CLI
- Terraform
- kubectl

Verify AWS credentials before planning or applying:

```sh
aws sts get-caller-identity
```

## Configure

Create a local Terraform variables file:

```sh
cp terraform/aws/terraform.tfvars.example terraform/aws/terraform.tfvars
```

Restrict the public EKS API endpoint to your own public IP:

```hcl
cluster_endpoint_public_access_cidrs = ["YOUR_PUBLIC_IP/32"]
```

Do not commit `terraform.tfvars`; it is ignored by Git.

## Validate

Format and validate the Terraform configuration:

```sh
terraform fmt -check -recursive terraform/aws
terraform -chdir=terraform/aws init
terraform -chdir=terraform/aws validate
```

CI runs the same validation with `terraform init -backend=false` so it does not
need remote state or AWS credentials.

## Plan

Review the resources before creating anything:

```sh
terraform -chdir=terraform/aws plan
```

The plan should be reviewed by category:

- VPC and networking
- EKS control plane
- IAM roles and policies
- Worker node group
- Security groups
- Addons
- Access entries

## Apply

Create the environment:

```sh
terraform -chdir=terraform/aws apply
```

## Connect with kubectl

After apply, configure kubeconfig:

```sh
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name microservices-platform-eks
```

Verify access:

```sh
kubectl get nodes
kubectl get pods -A
```

## Teardown

Destroy the environment when the demo is complete:

```sh
terraform -chdir=terraform/aws destroy
```

After destroy, verify that cost-sensitive resources such as NAT Gateways,
worker nodes, and load balancers are gone.

## Current Status

Tested successfully:

- Terraform apply completed
- kubeconfig was configured with AWS CLI
- `kubectl` connected to the EKS cluster
- teardown was started after verification
