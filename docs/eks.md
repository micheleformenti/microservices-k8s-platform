# AWS EKS Platform

The EKS environment is reproducible, delivered through GitOps, and safe to
create and destroy from protected GitHub Actions workflows.

## Architecture

```text
GitHub Actions
  ├── applies Terraform
  │     ├── Network: public and private subnets, NAT gateway
  │     ├── Cluster: multi-zone EKS with node autoscaling
  │     ├── Identities: EKS and platform controllers
  │     └── Edge: ACM certificate and Route 53 validation
  ├── installs Argo CD
  └── creates the cluster metadata Secret from Terraform outputs
        ├── cluster name, region, DNS zone, and GHCR secret name
        └── application hostname and ACM certificate ARN
      ↓
Argo CD app-of-apps
  ├── ApplicationSets read the metadata
  │     ├── AWS platform controllers, secrets, and storage
  │     └── Application workload
  └── observability stack
      ↓
Ingress configures the Application Load Balancer → frontend Service
```

### Network Topology

```text
Internet users
      ↓
HTTPS ingress
      ↓
Application Load Balancer (public subnets)
      ↓
EKS worker nodes (private subnets across two Availability Zones)
      ↓
Outbound egress
      ↓
NAT Gateway (public subnet) → Internet services
```

The Spot node group spans two Availability Zones and scales from one to three
`t3.large` instances. Nodes run in private subnets and use one NAT gateway for
egress.

## Bootstrap

The manual bootstrap creates isolated remote state, GitHub OIDC roles, and a
persistent AWS Secrets Manager container for the GHCR credential. The helper
scripts configure the GitHub Actions variables and load the credential value.

```text
Manual bootstrap
  ├── encrypted S3 state and native lockfiles
  ├── GitHub plan/apply roles
  └── AWS Secrets Manager GHCR credential container
                      ↓
Helper scripts
  ├── configure GitHub Actions variables
  └── set the GHCR credential value in Secrets manager
```

Create a classic GitHub personal access token with `read:packages`, then run:

```sh
cp terraform/aws/bootstrap/backend.hcl.example \
  terraform/aws/bootstrap/backend.hcl
terraform -chdir=terraform/aws/bootstrap init -backend-config=backend.hcl
terraform -chdir=terraform/aws/bootstrap apply
terraform/aws/bootstrap/configure-github-variables.sh
terraform/aws/bootstrap/configure-ghcr-secret.sh
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
kubectl --context eks get secretstore,externalsecret -n microservices-platform
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
- **GitOps Bridge:** passes Terraform-derived AWS metadata to Argo CD without
  duplicating it in Helm values.
- **EKS Pod Identity:** gives controllers scoped AWS access without static
  credentials.
- **External Secrets Operator:** reads the persistent GHCR credential and
  maintains the workload image pull secret.
- **VPC CNI NetworkPolicy:** enforces the workload's isolation rules.
- **Persistent Redis:** demonstrates EBS-backed persistence, not highly
  available Redis.
- **Shared DNS zone:** `aws.micheleformenti.com` remains outside the disposable
  project environment.
