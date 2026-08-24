# AWS EKS Platform

The EKS environment is reproducible, delivered through GitOps, and designed to
be destroyed when it is not being demonstrated.

## Architecture

![EKS platform architecture](diagrams/eks-platform-architecture.svg)

```text
Terraform
  ├── Network: public and private subnets across two Availability Zones
  ├── Cluster: EKS, Spot node group and managed addons
  ├── Identities: EKS Pod Identity roles for platform controllers
  └── Edge: ACM certificate and Route 53 validation
      ↓
Argo CD app-of-apps
  ├── AWS platform controllers and storage
  ├── Application workload
  └── observability stack
      ↓
Ingress → Application Load Balancer → frontend Service
```

Nodes run in private subnets and use one NAT Gateway for egress. The public EKS
API is restricted to configured CIDRs. The node group scales from one to four
`t3.medium` Spot instances.

## Bootstrap

The manual bootstrap creates an encrypted, versioned S3 bucket with public
access blocked. Bootstrap and project states use separate prefixes and native
S3 lockfiles.

```text
S3 state bucket
├── bootstrap-tfstate/terraform.tfstate
└── project-tfstate/terraform.tfstate
```

Copy each ignored backend configuration and replace `ACCOUNT_ID`.

```sh
cp terraform/aws/bootstrap/backend.hcl.example \
  terraform/aws/bootstrap/backend.hcl
terraform -chdir=terraform/aws/bootstrap init -backend-config=backend.hcl
terraform -chdir=terraform/aws/bootstrap apply

cp terraform/aws/eks/backend.hcl.example terraform/aws/eks/backend.hcl
terraform -chdir=terraform/aws/eks init -backend-config=backend.hcl
```

## Create and Deploy

Create `terraform.tfvars` from its example, configure the hosted zone and
domain, and restrict API access to your public IP.

```hcl
cluster_endpoint_public_access_cidrs = ["YOUR_PUBLIC_IP/32"]
```

```sh
terraform -chdir=terraform/aws/eks plan
terraform -chdir=terraform/aws/eks apply

aws eks update-kubeconfig \
  --region eu-central-1 \
  --name microservices-platform-eks

helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --wait

kubectl apply -f argocd/roots/aws.yaml
```

## Verify

Check the cluster and GitOps applications:

```sh
kubectl get nodes
kubectl get applications -n argocd
kubectl get pods -n kube-system
kubectl get pods,pvc,hpa -n microservices-platform
```

Check DNS and HTTPS:

```sh
kubectl get ingress frontend -n microservices-platform
dig eks-demo.aws.micheleformenti.com
curl -I http://eks-demo.aws.micheleformenti.com
curl -I https://eks-demo.aws.micheleformenti.com
```

HTTP redirects to HTTPS. ExternalDNS manages the Route 53 alias, while ACM
provides the certificate attached by the AWS Load Balancer Controller.

## Test Autoscaling

Generate frontend load and request more CPU than the current nodes can
schedule:

```sh
LOAD_IMAGE=$(kubectl get deployment loadgenerator \
  -n microservices-platform \
  -o jsonpath='{.spec.template.spec.containers[0].image}')

kubectl run hpa-load-test \
  -n microservices-platform \
  --image="$LOAD_IMAGE" \
  --restart=Never \
  --env=FRONTEND_ADDR=frontend:80 \
  --env=USERS=200 \
  --env=RATE=10

kubectl create deployment node-scale-test \
  -n microservices-platform \
  --image=registry.k8s.io/pause:3.10 \
  --replicas=4

kubectl set resources deployment/node-scale-test \
  -n microservices-platform \
  --requests=cpu=1,memory=128Mi \
  --limits=cpu=1,memory=128Mi
```

```sh
kubectl get hpa frontend -n microservices-platform --watch
kubectl get nodes --watch
```

Clean up and allow the HPA and node group to scale down:

```sh
kubectl delete pod hpa-load-test -n microservices-platform
kubectl delete deployment node-scale-test -n microservices-platform
```

## Destroy

Remove GitOps resources while their controllers can still delete the ALB, DNS
records, and EBS volumes. Then destroy the cluster.

```sh
kubectl delete -f argocd/roots/aws.yaml
argocd app delete aws-observability --cascade --yes
argocd app delete aws-workload --cascade --yes
argocd app delete aws-platform --cascade --yes

helm uninstall argocd -n argocd
kubectl delete namespace argocd
terraform -chdir=terraform/aws/eks destroy
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

## Next Steps

- Add protected OIDC create/update and destroy pipelines.
- Add Argo CD finalizers, sync waves, and child health aggregation.
- Document the final EKS and AKS design differences.
