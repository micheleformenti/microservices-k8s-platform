# Azure AKS Platform

The AKS implementation provides repeatable infrastructure, GitOps delivery,
Azure Disk persistence, and the foundation for public ingress. DNS and HTTPS
are not implemented yet.

## Architecture

Terraform provisions:

- multi-zone AKS with autoscaling from one to four nodes
- private Azure CNI Overlay networking with static NAT egress
- managed identities and a dedicated Application Gateway subnet

AKS provides the managed control plane, Metrics Server, and Azure storage
drivers.

```text
Terraform provisions Azure infrastructure
    ├── VNet and NAT gateway
    ├── AKS
    └── managed identities
              ↓
GitHub Actions installs Argo CD
              ↓
Terraform outputs
    ├── ALB Controller client ID
    └── Application Gateway subnet ID
              ↓
Pipeline creates Argo cluster metadata Secret
              ↓
ApplicationSet reads metadata
    ├── installs ALB Controller
    └── installs helm/platform/azure
              ↓
Argo CD owns the platform, workload, and observability resources
```

## Bootstrap

The one-time manual bootstrap creates the remote state backend and separate
GitHub OIDC identities with scoped plan and apply permissions.

```text
Manual Terraform apply
    ├── remote state storage
    └── GitHub OIDC identities and RBAC
              ↓
Script configures the required GitHub secrets
              ↓
Pipelines authenticate to Azure with OIDC
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
Pull request (or manual plan)
      ↓
Terraform plan
      ↓
Merge to main (or manual apply)
      ↓
Protected Terraform apply
      ↓
Install Argo CD
      ↓
Publish Azure metadata
      ↓
Apply argocd/roots/azure.yaml
      ↓
Argo CD reconciles the child applications
```

## Verify

Configure local access after the cluster is running:

```sh
az aks get-credentials \
  --resource-group rg-microservices-platform \
  --name aks-microservices-platform \
  --admin \
  --overwrite-existing

kubectl get nodes -L topology.kubernetes.io/zone
kubectl get applications -n argocd
kubectl get pods -n microservices-platform
kubectl get pods -n monitoring
```

Until public routing is added, test the frontend through port forwarding:

```sh
kubectl port-forward service/frontend \
  --namespace microservices-platform \
  8080:80
```

Open `http://localhost:8080`.

## Destroy

Run the **Destroy Azure Environment** workflow from `main` and enter `destroy`
when prompted.

```text
Clear active Argo operations
      ↓
Delete the Azure root Application
      ↓
Argo finalizers remove child applications and Kubernetes resources
      ↓
Wait for Azure to delete Application Gateway for Containers
      ↓
Uninstall Argo CD
      ↓
Terraform destroy
```

The bootstrap resources remain so the pipeline can recreate the environment:

- Terraform state storage
- GitHub OIDC identities and role assignments
- project resource group

## Next Steps

- Add Gateway API routing to the frontend.
- Add DNS and HTTPS.
- Document the final EKS and AKS design differences.
