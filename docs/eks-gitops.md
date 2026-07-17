# EKS GitOps Delivery with Argo CD

This document describes how the workload is deployed to EKS with Argo CD.

The workflow was tested by syncing the Argo CD application on EKS and accessing
the frontend with `kubectl port-forward`.

## Architecture

```text
GitHub repository (main)
        |
        | watches helm/application/
        v
Argo CD on EKS
        |
        | renders Helm chart with values.yaml + values-eks.yaml
        v
microservices-platform namespace
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

## Application Configuration

The EKS Argo CD application is defined in
[`argocd/applications/eks.yaml`](../argocd/applications/eks.yaml).

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

## Create and Sync the Application

Apply the EKS Argo CD application:

```sh
kubectl apply -f argocd/applications/eks.yaml
```

Watch the application:

```sh
kubectl get application microservices-platform-eks -n argocd -w
```

Verify the workload:

```sh
kubectl get pods -n microservices-platform
kubectl get services -n microservices-platform
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
kubectl delete -f argocd/applications/eks.yaml
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
