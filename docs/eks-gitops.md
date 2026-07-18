# EKS GitOps Delivery with Argo CD

This document describes how the workload is deployed to EKS with Argo CD.

The workflow was tested by syncing the Argo CD application on EKS and accessing
the frontend with `kubectl port-forward`.

## Architecture

```text
GitHub repository (main)
        |
        | watches helm/platform/aws/ and helm/application/
        v
Argo CD on EKS
        |
        | renders AWS platform resources and application workload
        v
EKS cluster + microservices-platform namespace
        |
        | pulls public images
        v
GitHub Container Registry
```

The first EKS GitOps deployment keeps the frontend private inside the cluster.
Access is verified with port forwarding. Public ingress with an AWS Application
Load Balancer is planned as a later layer.

## Prerequisites

- EKS cluster provisioned with Terraform
- `kubectl` configured for the EKS cluster
- Helm installed locally
- Public service images published to GitHub Container Registry
- EBS CSI driver installed on the EKS cluster for AWS storage resources
- `helm/platform/aws` pushed to the Git branch watched by Argo CD
- `helm/application/values-eks.yaml` pushed to the Git branch watched by Argo CD

Configure kubeconfig:

```sh
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name microservices-platform-eks
```

Verify cluster access:

```sh
kubectl get nodes
```

## Install Argo CD on EKS

Add the Argo Helm repository:

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

Install Argo CD:

```sh
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace
```

Wait for the Argo CD pods:

```sh
kubectl get pods -n argocd -w
```

## Platform Configuration

The EKS platform Argo CD application is defined in
[`argocd/applications/eks-platform.yaml`](../argocd/applications/eks-platform.yaml).

Important settings:

- Repository: this project's GitHub repository
- Revision: `main`
- Source path: `helm/platform/aws`
- Helm release name: `aws-platform`
- Destination namespace: `kube-system`
- Automated sync: enabled
- Pruning: enabled
- Self-healing: enabled

The AWS platform chart currently manages the `gp3` `StorageClass`. It is kept
separate from the workload chart because it represents cloud-specific cluster
configuration, not application deployment.

The storage design and Redis persistence validation are documented in
[EKS Storage](eks-storage.md).

## Application Configuration

The EKS Argo CD application is defined in
[`argocd/applications/eks-application.yaml`](../argocd/applications/eks-application.yaml).

Important settings:

- Repository: this project's GitHub repository
- Revision: `main`
- Source path: `helm/application`
- Helm release name: `microservices-platform`
- Helm value files:
  - `values.yaml`
  - `values-eks.yaml`
- Destination namespace: `microservices-platform`
- Automated sync: enabled
- Pruning: enabled
- Self-healing: enabled

`values-eks.yaml` uses public GHCR images and sets the frontend service to
`ClusterIP` for the first EKS deployment.

## Create and Sync the Applications

Apply the EKS platform Argo CD application first:

```sh
kubectl apply -f argocd/applications/eks-platform.yaml
```

Watch the platform application:

```sh
kubectl get application eks-platform -n argocd -w
```

Verify the platform resource:

```sh
kubectl get storageclass gp3
```

Apply the EKS Argo CD application:

```sh
kubectl apply -f argocd/applications/eks-application.yaml
```

Watch the application:

```sh
kubectl get application eks-application -n argocd -w
```

Verify the workload:

```sh
kubectl get pods -n microservices-platform
kubectl get services -n microservices-platform
kubectl get statefulset redis-cart -n microservices-platform
kubectl get pvc -n microservices-platform
```

## Access the Frontend

Forward the frontend service locally:

```sh
kubectl port-forward -n microservices-platform svc/frontend 8080:80
```

Open:

```text
http://localhost:8080
```

Port forwarding creates a temporary tunnel through the Kubernetes API server.
The application is not publicly exposed by this step.


## Teardown

Delete the Argo CD application:

```sh
kubectl delete -f argocd/applications/eks-application.yaml
kubectl delete -f argocd/applications/eks-platform.yaml
```

Uninstall Argo CD:

```sh
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

If the EKS environment is no longer needed, destroy it with Terraform:

```sh
terraform -chdir=terraform/aws destroy
```
