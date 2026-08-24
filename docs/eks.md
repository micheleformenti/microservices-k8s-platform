# AWS EKS Platform

The EKS environment is reproducible, delivered through GitOps, and safe to
create and destroy from protected GitHub Actions workflows.

## Architecture

![EKS platform architecture](diagrams/eks-platform-architecture.svg)

```text
GitHub Actions
  ├── applies Terraform
  │     ├── Network: public and private subnets, NAT gateway
  │     ├── Cluster: multi-zone EKS with node autoscaling
  │     ├── Identities: EKS and platform controllers
  │     └── Edge: ACM certificate and Route 53 validation
  └── installs Argo CD
      ↓
Argo CD app-of-apps
  ├── AWS platform controllers and storage
  ├── Application workload
  └── observability stack
      ↓
Ingress → Application Load Balancer → frontend Service
```

The Spot node group spans two Availability Zones and scales from one to three
`t3.large` instances. Nodes run in private subnets and use one NAT gateway for
egress.

## Bootstrap

The manual bootstrap creates isolated remote state, GitHub OIDC roles, and an
EKS administrator variable.

```text
Manual bootstrap
  ├── encrypted S3 state and native lockfiles
  └── GitHub plan/apply roles
                ↓
configure-github-variables.sh
                ↓
Protected pipelines authenticate with OIDC
```

```sh
cp terraform/aws/bootstrap/backend.hcl.example \
  terraform/aws/bootstrap/backend.hcl
terraform -chdir=terraform/aws/bootstrap init -backend-config=backend.hcl
terraform -chdir=terraform/aws/bootstrap apply
terraform/aws/bootstrap/configure-github-variables.sh
```

## Create or Update

```text
Pull request or manual plan
              ↓
Terraform plan
              ↓
Merge to main or approved manual apply
              ↓
Terraform apply
              ↓
Argo CD bootstrap
              ↓
GitOps reconciliation
```

## Verify

Configure local access:

```sh
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name microservices-platform-eks \
  --alias eks
```

Check the platform:

```sh
kubectl --context eks get nodes -L topology.kubernetes.io/zone
kubectl --context eks get applications -n argocd
kubectl --context eks get pods -n kube-system
kubectl --context eks get pods,pvc,hpa -n microservices-platform
```

Check DNS and HTTPS:

```sh
kubectl --context eks get ingress frontend -n microservices-platform
dig eks-demo.aws.micheleformenti.com
curl -I http://eks-demo.aws.micheleformenti.com
curl -I https://eks-demo.aws.micheleformenti.com
```

HTTP redirects to HTTPS. ExternalDNS manages the Route 53 alias, while ACM
provides the certificate attached by the AWS Load Balancer Controller.

## Destroy

Run **Destroy AWS Environment** from `main` and enter `destroy` when prompted.

```text
Delete the Argo CD root Application
              ↓
Argo finalizers remove Kubernetes and controller-managed AWS resources
              ↓
Uninstall Argo CD
              ↓
Terraform destroys the EKS environment
```

The state bucket and existing Route 53 zone remain for the next environment.

## Design Choices

- **Private Spot nodes:** reduce cost; a production environment would use more
  resilient capacity and NAT topology.
- **Controller-owned cloud resources:** Kubernetes controllers manage ALBs,
  DNS records, and EBS volumes discovered at runtime.
- **EKS Pod Identity:** gives controllers scoped AWS access without static
  credentials.
- **Persistent Redis:** demonstrates EBS-backed persistence, not highly
  available Redis.
- **Shared DNS zone:** `aws.micheleformenti.com` remains outside the disposable
  project environment.

## Next Steps

- Document the final EKS and AKS design differences.
