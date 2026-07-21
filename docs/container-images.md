# Container Images

This document describes how service images are built and published for cloud
deployments.

## Registry

Custom service images are published to GitHub Container Registry:

```text
ghcr.io/<github-owner>/<service-name>
```

Examples:

```text
ghcr.io/micheleformenti/frontend
ghcr.io/micheleformenti/cartservice
ghcr.io/micheleformenti/productcatalogservice
```

Redis and BusyBox are not built by this project. They continue to use public
upstream images.

## CI Workflow

Image builds run as part of the main CI workflow in `.github/workflows/ci.yml`.

The build container images job depends on the validation and test jobs:

- Kubernetes, Helm, and Argo CD validation
- Go tests
- .NET tests

Pull requests build the images but do not publish them. Pushes to `main` build
and publish the images to GitHub Container Registry.

The workflow detects service-level changes and builds only the affected service
images. Changes to the CI workflow build all service images.

After images are published from `main`, the workflow updates
`helm/application/values-eks.yaml` and `helm/application/values-local.yaml`
with the immutable commit SHA tag for the images that were built. It does not
push that change directly to `main`. Instead, it opens an automated pull
request for review.

The job builds the services currently deployed by the Helm chart:

- adservice
- cartservice
- checkoutservice
- currencyservice
- emailservice
- frontend
- loadgenerator
- paymentservice
- productcatalogservice
- recommendationservice
- shippingservice

`shoppingassistantservice` is not included because it is not currently part of
the Helm deployment and depends on external Google Cloud services, including
Secret Manager, AlloyDB, and Gemini.

## Tags

Every image published from `main` gets an immutable commit SHA tag:

```text
ghcr.io/<github-owner>/<service-name>:<git-sha>
```

Builds from the `main` branch also update a moving `main` tag:

```text
ghcr.io/<github-owner>/<service-name>:main
```

EKS deployments use the commit SHA tag in `helm/application/values-eks.yaml` so
the deployed image version is explicit and reproducible. Local GHCR smoke tests
can use the same immutable tags through `helm/application/values-local.yaml`.

## Visibility

The workflow publishes images with GitHub Actions `GITHUB_TOKEN` and
`packages: write` permission.

The service packages are public, so local Kubernetes and EKS can pull them
without an image pull secret.

Private images are intentionally deferred to a later security milestone.

## Local GHCR Testing

The application Helm chart includes `helm/application/values-local.yaml` for
testing the published GHCR images on a local cluster:

```sh
helm upgrade --install microservices-platform ./helm/application \
  --namespace microservices-platform \
  --create-namespace \
  -f helm/application/values.yaml \
  -f helm/application/values-local.yaml
```

The local values file uses the same immutable service image tags as the EKS
values file after the image tag pull request is merged.
