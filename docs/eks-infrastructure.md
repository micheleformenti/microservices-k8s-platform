# EKS Infrastructure

The AWS Terraform configuration is split into two independent roots:

- `terraform/aws/bootstrap/` creates the S3 remote-state bucket.
- `terraform/aws/eks/` creates the EKS environment and supporting resources.

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
  - EKS Pod Identity Agent
  - EBS CSI driver
- IAM roles and policy attachments for the cluster and worker nodes
- Pod Identity roles for the EBS CSI driver and AWS Load Balancer Controller
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

## Bootstrap Remote State

The bootstrap root creates a dedicated S3 bucket before the EKS root is
initialized. The bucket has versioning and server-side encryption enabled, and
all public access is blocked. Terraform's native S3 lockfile prevents
concurrent state writes.

Initialize and create the backend bucket once:

```sh
terraform -chdir=terraform/aws/bootstrap init
terraform -chdir=terraform/aws/bootstrap plan
terraform -chdir=terraform/aws/bootstrap apply
```

Get the generated bucket name:

```sh
terraform -chdir=terraform/aws/bootstrap output -raw state_bucket_name
```

Create the local EKS backend configuration:

```sh
cp terraform/aws/eks/backend.hcl.example terraform/aws/eks/backend.hcl
```

Replace `ACCOUNT_ID` in `backend.hcl` with the account ID shown in the bucket
name, then initialize the EKS root:

```sh
terraform -chdir=terraform/aws/eks init \
  -backend-config=backend.hcl \
  -migrate-state
```

The backend configuration stores EKS state at
`microservices-platform/eks/terraform.tfstate` and enables S3 state locking
with `use_lockfile = true`.

The bootstrap root intentionally keeps local state because it creates the
remote backend itself. Its bucket has `prevent_destroy` enabled and should be
retained when temporary EKS environments are destroyed. The account-specific
`backend.hcl` file is ignored by Git.

## Configure

Create a local Terraform variables file:

```sh
cp terraform/aws/eks/terraform.tfvars.example terraform/aws/eks/terraform.tfvars
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
terraform -chdir=terraform/aws/bootstrap init -backend=false
terraform -chdir=terraform/aws/bootstrap validate
terraform -chdir=terraform/aws/eks init -backend=false
terraform -chdir=terraform/aws/eks validate
```

CI runs the same validation with `terraform init -backend=false` so it does not
need remote state or AWS credentials.

## Plan

Review the resources before creating anything:

```sh
terraform -chdir=terraform/aws/eks plan
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
terraform -chdir=terraform/aws/eks apply
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
terraform -chdir=terraform/aws/eks destroy
```

After destroy, verify that cost-sensitive resources such as NAT Gateways,
worker nodes, and load balancers are gone. Keep the bootstrap state bucket; it
stores the empty EKS state and is reused the next time the environment is
created.

## Current Status

Tested successfully:

- S3 remote state, versioning, and state locking were verified
- Terraform apply completed
- kubeconfig was configured with AWS CLI
- `kubectl` connected to the EKS cluster
- Terraform destroy completed successfully
