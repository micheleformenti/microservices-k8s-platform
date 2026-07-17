# Platform Helm Charts

This directory contains provider-specific platform charts.

The application workload is kept separately in `helm/application/` so it can be
deployed to multiple Kubernetes environments with provider-specific values.

## Current Structure

```text
helm/platform/
└── aws/
    └── EKS-specific platform resources
```

The AWS chart currently manages EKS platform resources such as the `gp3`
`StorageClass`.

## Planned Structure

```text
helm/platform/
├── aws/
└── azure/
```

The Azure chart will be added during the AKS milestone when there are concrete
AKS-specific resources to manage.

Provider-specific resources stay in these charts instead of the application
chart. Examples include cloud storage classes, cloud load balancer integrations,
and provider-specific identity or controller configuration.
