# Security scanning

Trivy `v0.74.0` scans repository dependencies and secrets in `security.yml`.
It scans affected service images in `ci.yml` before they are published.

```text
Pull request or main push
            ↓
      ├── Repository scan
      │     ├── dependencies
      │     └── secrets
      └── Image build
            └── image scan
            ↓
       Merge is gated
```

Repository scanning also runs weekly. Actionable `CRITICAL` vulnerabilities and
detected secrets fail their jobs; unfixed vulnerabilities are ignored.

Terraform, Dockerfile, and rendered Kubernetes scans are next steps.
