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
  └── creates the cluster metadata Secret from Terraform outputs
        ├── Azure and cluster identifiers
        ├── controller identity client IDs
        ├── Application Gateway subnet ID
        ├── DNS zone metadata
        └── Key Vault URI
      ↓
Argo CD app-of-apps
  ├── ApplicationSets read the metadata
  │     ├── Azure platform controllers
  │     └── Application workload and secret synchronization
  └── observability stack
      ↓
Gateway and HTTPRoute configure Application Gateway for Containers
  → frontend Service
```

### Network Topology

```text
Internet users
      ↓
HTTPS ingress
      ↓
Application Gateway for Containers (delegated association subnet)
      ↓
AKS nodes (AKS subnet across three zones, no public IPs)
      ↓
Outbound egress
      ↓
NAT Gateway → Internet services
```

The system node pool spans three availability zones and scales from one to
four nodes. Pods use Azure CNI Overlay; nodes have no public IPs and use a
static NAT gateway for egress.

## Bootstrap

The manual MFA bootstrap creates isolated remote state, GitHub OIDC identities,
an RBAC-enabled Key Vault, and scoped Azure permissions. State and Key Vault
secret management are limited to the bootstrap operators Entra group.

```text
Manual bootstrap
  ├── Terraform state storage
  ├── GitHub plan/apply identities and RBAC
  └── Azure Key Vault
                    ↓
Helper scripts
  ├── configure GitHub Actions secrets
  └── store the GHCR credential in Key Vault
```

Create a classic GitHub personal access token with `read:packages`, then run:

```sh
cp terraform/azure/bootstrap/terraform.tfvars.example \
  terraform/azure/bootstrap/terraform.tfvars

terraform -chdir=terraform/azure/bootstrap init
terraform -chdir=terraform/azure/bootstrap apply
terraform/azure/bootstrap/configure-github-secrets.sh
terraform/azure/bootstrap/configure-ghcr-secret.sh
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
kubectl get pods -n aks-platform
kubectl get pods,pvc,hpa -n microservices-platform
```

Check secret synchronization without displaying the credential:

```sh
kubectl get secretstore,externalsecret -n microservices-platform
kubectl get secret ghcr-pull -n microservices-platform
```

The `ExternalSecret` should report ready, and the generated `ghcr-pull` Secret
should have type `kubernetes.io/dockerconfigjson`.

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
- **External Secrets:** synchronizes GHCR credentials from Azure Key Vault into
  the workload namespace without storing credentials in Git.
- **Cilium:** enforces NetworkPolicies on the Azure CNI Overlay data plane.
- **Shared DNS zone:** `azure.micheleformenti.com` lives outside the disposable
  project environment.
