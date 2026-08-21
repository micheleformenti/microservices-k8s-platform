# Platform Helm Charts

This directory contains provider-specific platform charts.

The application workload is kept separately in `helm/application/` so it can be
deployed to multiple Kubernetes environments with provider-specific values.

## Current Structure

```text
helm/platform/
├── aws/
│   └── EKS-specific platform resources
└── azure/
    └── AKS-specific platform resources
```

- **AWS**
  - Configures EKS platform components such as Metrics Server, Cluster
    Autoscaler, ExternalDNS and the AWS Load Balancer Controller.
  - Creates the `gp3` `StorageClass`.

- **Azure**
  - Creates the controller-managed Application Gateway for Containers.
  - Receives the Terraform-managed Application Gateway subnet ID from the Azure
    deployment pipeline at install time.

Provider-specific resources stay in these charts instead of the application
chart. Examples include cloud storage classes, cloud load balancer integrations,
and provider-specific identity or controller configuration.
