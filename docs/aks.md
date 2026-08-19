# Azure AKS Platform

The AKS implementation currently provides a repeatable infrastructure and
GitOps baseline. Persistent storage and public HTTPS ingress are not implemented
yet.

## Architecture

Terraform provisions:

- an AKS cluster in West Europe
- a system node pool spread across three availability zones
- cluster autoscaling from one to four nodes
- Azure CNI Overlay networking
- a private node subnet without public node IPs
- a NAT gateway and static public IP for outbound traffic
- a user-assigned managed identity for AKS

AKS manages the Kubernetes control plane, Metrics Server, Azure networking, and
the Azure Disk and Azure Files CSI drivers.

```text
GitHub Actions
    |
    +-- Terraform --> VNet, NAT gateway, AKS
    |
    +-- Helm -------> Argo CD
                         |
                         +-- azure root
                               +-- workload
                               +-- observability
```

## Bootstrap

The bootstrap configuration is applied manually once. It creates:

- the project and Terraform state resource groups
- an LRS storage account and private, versioned state container
- separate GitHub OIDC identities for Terraform plans and applies
- scoped Azure role assignments
- the user-assigned identity used by AKS

```sh
cp terraform/azure/bootstrap/terraform.tfvars.example \
  terraform/azure/bootstrap/terraform.tfvars

terraform -chdir=terraform/azure/bootstrap init
terraform -chdir=terraform/azure/bootstrap apply
terraform/azure/bootstrap/configure-github-secrets.sh
```

The script reads the Terraform outputs and configures these masked GitHub
secrets:

- `AZURE_PLAN_CLIENT_ID`
- `AZURE_APPLY_CLIENT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`

The plan identity can read the project resources. The apply identity can manage
the project resource group. Both can access the remote state container. GitHub
Actions authenticates through OIDC, so no client secret is stored.

## Create or Update

Pull requests that change the AKS Terraform or deployment workflow run a
Terraform plan. A merge to `main` runs the protected apply job.

The deployment workflow then:

1. creates or updates AKS with Terraform;
2. installs the pinned Argo CD Helm chart;
3. applies `argocd/roots/azure.yaml`;
4. waits for the root Application to become Synced.

The root creates the workload and observability Applications. Their reconciliation
continues inside Argo CD; root health does not currently represent child health.

The same workflow can be started manually with either `plan` or `apply`.

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

Until public ingress is added, test the frontend through port forwarding:

```sh
kubectl port-forward service/frontend \
  --namespace microservices-platform \
  8080:80
```

Open `http://localhost:8080`.

## Destroy

Run the **Destroy Azure Environment** workflow from `main` and enter `destroy`
when prompted.

The workflow deletes only the Azure root Application. Git-managed Argo CD
finalizers recursively remove the child Applications and their Kubernetes
resources. The workflow then uninstalls Argo CD and runs Terraform destroy.

The bootstrap resources remain so the pipeline can recreate the environment:

- Terraform state storage
- GitHub OIDC identities and role assignments
- project resource group
- AKS user-assigned identity

## Next Steps

- Enable persistent storage for Redis using Azure Disk.
- Add public ingress, DNS, and HTTPS.
- Document the final EKS and AKS design differences.
