# Security scanning

Trivy `v0.74.0` scans repository dependencies, secrets, Terraform, and
Dockerfiles in `security.yml`. It scans affected service images in `ci.yml`
before they are published.

```text
Pull request or main push
            ↓
      ├── Repository scan
      │     ├── dependencies
      │     ├── secrets
      │     ├── Terraform configuration
      │     └── Dockerfiles
      └── Image build
            └── image scan
            ↓
       Merge is gated
```

Repository scanning also runs weekly. Actionable `CRITICAL` vulnerabilities and
misconfigurations, and detected secrets fail their jobs. Unfixed vulnerabilities
are ignored.

Rendered Kubernetes scanning is deferred until workload security hardening.
