# Azure AKS Platform

The AKS environment is reproducible, delivered through GitOps, and safe to
create and destroy from protected GitHub Actions workflows.

## Architecture

```text
GitHub Actions
  ├── applies Terraform
  │     ├── Network: VNet, AKS and gateway subnets, NAT gateway
  │     ├── Cluster: multi-zone AKS with node autoscaling
  │     └── Identities: AKS and platform controllers
  ├── installs Argo CD
  └── creates the cluster metadata Secret
        ├── Azure and cluster identifiers
        ├── controller identity client IDs
        ├── Application Gateway subnet ID
        └── DNS zone metadata
      ↓
ApplicationSet reads the metadata Secret
  ├── Azure platform
  │     ├── ALB Controller and Application Gateway
  │     ├── ExternalDNS
  │     └── cert-manager
  ├── Application workload
  └── observability stack
      ↓
Gateway API routes HTTPS traffic to the frontend Service
```

The system node pool spans three availability zones and scales from one to
four nodes. Pods use Azure CNI Overlay; nodes have no public IPs and use a
static NAT gateway for egress.

## Bootstrap

The manual MFA bootstrap creates isolated remote state, GitHub OIDC identities,
and scoped Azure permissions. State access is limited to the bootstrap
operators Entra group.

```text
Manual bootstrap
  ├── Terraform state storage
  └── GitHub plan/apply identities and RBAC
                ↓
configure-github-secrets.sh
                ↓
Protected pipelines authenticate with OIDC
```

```sh
cp terraform/azure/bootstrap/terraform.tfvars.example \
  terraform/azure/bootstrap/terraform.tfvars

terraform -chdir=terraform/azure/bootstrap init
terraform -chdir=terraform/azure/bootstrap apply
terraform/azure/bootstrap/configure-github-secrets.sh
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

Infrastructure metadata such as identity client IDs and subnet IDs is passed
to Argo CD through the GitOps Bridge pattern rather than committed to Git.

## Verify

Configure local access:

```sh
az aks get-credentials \
  --resource-group rg-microservices-platform \
  --name aks-microservices-platform \
  --admin \
  --overwrite-existing
```

Check the platform:

```sh
kubectl get nodes -L topology.kubernetes.io/zone
kubectl get applications,applicationsets -n argocd
kubectl get pods -n azure-alb-system
kubectl get pods -n microservices-platform
kubectl get pvc -n microservices-platform
kubectl get hpa -n microservices-platform
```

Check routing, DNS, and HTTPS:

```sh
kubectl get gateway,httproute -n microservices-platform
dig aks-demo.azure.micheleformenti.com
curl -I http://aks-demo.azure.micheleformenti.com
curl -I https://aks-demo.azure.micheleformenti.com
```

HTTP redirects to HTTPS. ExternalDNS manages the Azure DNS record, while
cert-manager obtains and renews the Let's Encrypt certificate.

## Destroy

Run **Destroy Azure Environment** from `main` and enter `destroy` when
prompted.

```text
Delete the Argo CD root Application
              ↓
Argo finalizers remove Kubernetes and controller-managed Azure resources
              ↓
Uninstall Argo CD
              ↓
Terraform destroys the AKS environment
```

The state storage, pipeline identities, project resource group, and shared DNS
zone remain available for the next environment creation.

## Design Choices

- **Application Gateway for Containers:** managed through Gateway API rather
  than legacy Ingress resources.
- **GitOps Bridge:** passes dynamic Azure metadata to Argo CD without Git
  mutation or hardcoded identifiers.
- **Workload Identity:** gives Kubernetes controllers narrowly scoped Azure
  access without client secrets.
- **Shared DNS zone:** `azure.micheleformenti.com` lives outside the disposable
  project environment.

## Next Steps

- Add Argo CD sync waves and child Application health aggregation.
- Document the final EKS and AKS design differences.
