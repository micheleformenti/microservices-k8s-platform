# Security

## Automated security scanning

Trivy `v0.74.0` scans repository dependencies, secrets, Terraform, Dockerfiles,
and rendered Kubernetes manifests in `security.yml`. It scans affected service
images in `ci.yml` before they are published.

```text
Pull request or main push
            ↓
      ├── Repository scan
      │     ├── dependencies
      │     ├── secrets
      │     ├── Terraform configuration
      │     ├── Dockerfiles
      │     └── rendered Kubernetes manifests
      └── Image build
            └── image scan
            ↓
       Merge is gated
```

Repository scanning also runs weekly. Actionable `CRITICAL` vulnerabilities and
misconfigurations, and detected secrets fail their jobs. Unfixed vulnerabilities
are ignored.

## Workload security

- **Security contexts:** run workloads as non-root with restricted privileges,
  runtime-default seccomp, read-only root filesystems, and explicit writable volumes.
- **NetworkPolicies:** deny ingress by default and allow only declared service
  flows. Egress remains unrestricted. EKS uses VPC CNI enforcement; AKS uses Cilium.

## Secret management

Application secrets are stored outside Git and Terraform state. External
Secrets Operator reads them from the cloud secret store using workload identity
and creates the Kubernetes Secrets consumed by the workloads. Application pods
do not receive permission to access the cloud secret store directly.
