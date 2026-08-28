# Security scanning

`security.yml` runs on pull requests, pushes to `main`, and on a weekly schedule. Trivy
`v0.74.0` scans dependencies and secrets; actionable critical findings and
detected secrets fail the check.

```text
Pull request or main push
            ↓
      Repository scan
        ├── dependencies
        └── secrets
            ↓
       Merge is gated
```

CI already builds and publishes immutable images. Image scanning, Terraform,
Dockerfile, and rendered Kubernetes scans are next steps.

Findings without a fix are currently ignored.
