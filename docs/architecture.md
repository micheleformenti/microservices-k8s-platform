# Platform Architecture Flows

These five flows explain how application code, cloud infrastructure, dynamic
configuration, credentials, and user traffic move through the platform.

## 1. Application Delivery

```mermaid
flowchart LR
    code["Code change"] --> ci["CI and security gates"]
    ci --> images["Private GHCR images<br/>immutable SHA tags"]
    images --> pr["Automated image-tag PR"]
    pr --> merge["Reviewed merge"]
    merge --> argo["Argo CD reconciliation"]
    argo --> workloads["EKS and AKS workloads"]

    classDef source fill:#f3f4f6,stroke:#4b5563,color:#111827
    classDef delivery fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef artifact fill:#ede9fe,stroke:#7c3aed,color:#111827
    classDef review fill:#fef3c7,stroke:#d97706,color:#111827
    classDef runtime fill:#dcfce7,stroke:#16a34a,color:#111827
    class code source
    class ci,argo delivery
    class images artifact
    class pr,merge review
    class workloads runtime
```

Pull requests run validation without publishing images. After a change reaches
`main`, the workflow publishes the affected images and opens a separate,
reviewable Helm image-tag pull request. Argo CD deploys only after that pull
request is merged.

## 2. Infrastructure Provisioning

```mermaid
flowchart LR
    actions["GitHub Actions"] -->|runs with OIDC| terraform["Terraform"]
    terraform -->|provisions| cloud["EKS or AKS"]
    cloud -->|GitHub Actions installs| argo["Argo CD"]

    classDef source fill:#f3f4f6,stroke:#4b5563,color:#111827
    classDef infra fill:#ede9fe,stroke:#7c3aed,color:#111827
    classDef cloud fill:#dcfce7,stroke:#16a34a,color:#111827
    classDef delivery fill:#dbeafe,stroke:#2563eb,color:#111827
    class actions source
    class terraform infra
    class cloud cloud
    class argo delivery
```

GitHub Actions authenticates to each cloud without stored cloud credentials.
Terraform provisions the network, cluster, identities, and edge resources. The
workflow then bootstraps Argo CD. The cloud CLI configures administrator access
to the resulting cluster when operational inspection is needed.

## 3. GitOps Bridge

```mermaid
flowchart LR
    terraform["Terraform outputs<br/>cloud resource values"] -->|GitHub Actions writes| metadata["Argo CD cluster Secret<br/>metadata annotations"]
    metadata -->|Argo CD reads| appset["ApplicationSet<br/>maps metadata to Helm values"]
    appset -->|renders Helm charts| resources["Kubernetes<br/>platform and application resources"]

    classDef infra fill:#ede9fe,stroke:#7c3aed,color:#111827
    classDef bridge fill:#fef3c7,stroke:#d97706,color:#111827
    classDef delivery fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef runtime fill:#dcfce7,stroke:#16a34a,color:#111827
    class terraform infra
    class metadata bridge
    class appset delivery
    class resources runtime
```

Terraform exposes values that can only be known after provisioning, such as
identity IDs, subnet IDs, DNS metadata, certificate references, and the Key
Vault URI. GitHub Actions writes those outputs into the environment's Argo CD
cluster Secret as metadata annotations.

The Argo CD ApplicationSet maps those annotations to Helm parameters. Argo CD
then renders the charts and reconciles the resulting platform and application
resources without committing environment-specific values to Git.

## 4. Secret Delivery

### AWS

```mermaid
flowchart LR
    token["GHCR credentials"] --> store["AWS Secrets Manager"]
    store -->|read using EKS Pod Identity| eso["External Secrets Operator"]
    eso --> secret["Kubernetes<br/>image pull Secret"]
    secret --> kubelet["kubelet"]
    kubelet -->|authenticates| ghcr["Private GHCR"]
    pod["Pod specification"] -. references .-> secret

    classDef credential fill:#fef3c7,stroke:#d97706,color:#111827
    classDef cloud fill:#ede9fe,stroke:#7c3aed,color:#111827
    classDef delivery fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef runtime fill:#dcfce7,stroke:#16a34a,color:#111827
    class token,secret credential
    class store,ghcr cloud
    class eso delivery
    class pod,kubelet runtime
```

### Azure

```mermaid
flowchart LR
    token["GHCR credentials"] --> store["Azure Key Vault"]
    store -->|read using Azure Workload Identity| eso["External Secrets Operator"]
    eso --> secret["Kubernetes<br/>image pull Secret"]
    secret --> kubelet["kubelet"]
    kubelet -->|authenticates| ghcr["Private GHCR"]
    pod["Pod specification"] -. references .-> secret

    classDef credential fill:#fef3c7,stroke:#d97706,color:#111827
    classDef cloud fill:#ede9fe,stroke:#7c3aed,color:#111827
    classDef delivery fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef runtime fill:#dcfce7,stroke:#16a34a,color:#111827
    class token,secret credential
    class store,ghcr cloud
    class eso delivery
    class pod,kubelet runtime
```

In both clouds, the credential stays outside Git and Terraform state. External
Secrets Operator uses the environment's workload identity to read it and create
a Docker registry Secret. The Secret is not mounted into the application
container; kubelet uses it to authenticate when pulling the private image.

## 5. Request Path

### AWS

```mermaid
flowchart LR
    user["User"] --> route53["Route 53"] --> alb["Application Load Balancer"] --> service["frontend Service"] --> pods["frontend Pods"]
    ingress["Ingress"] -. watched by AWS Load Balancer Controller .-> alb

    classDef source fill:#f3f4f6,stroke:#4b5563,color:#111827
    classDef dns fill:#ede9fe,stroke:#7c3aed,color:#111827
    classDef edge fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef config fill:#fef3c7,stroke:#d97706,color:#111827
    classDef runtime fill:#dcfce7,stroke:#16a34a,color:#111827
    class user source
    class route53 dns
    class alb edge
    class ingress config
    class service,pods runtime
```

### Azure

```mermaid
flowchart LR
    user["User"] --> dns["Azure DNS"] --> appGateway["Application Gateway<br/>for Containers"] --> service["frontend Service"] --> pods["frontend Pods"]
    gateway["Gateway and HTTPRoute"] -. watched by ALB Controller .-> appGateway

    classDef source fill:#f3f4f6,stroke:#4b5563,color:#111827
    classDef dns fill:#ede9fe,stroke:#7c3aed,color:#111827
    classDef edge fill:#dbeafe,stroke:#2563eb,color:#111827
    classDef config fill:#fef3c7,stroke:#d97706,color:#111827
    classDef runtime fill:#dcfce7,stroke:#16a34a,color:#111827
    class user source
    class dns dns
    class appGateway edge
    class gateway config
    class service,pods runtime
```

The solid lines show the request path. The dashed lines show the Kubernetes
resources that controllers reconcile into cloud load-balancing configuration.
Both environments terminate HTTPS at the managed edge and route traffic to the
frontend Service.
