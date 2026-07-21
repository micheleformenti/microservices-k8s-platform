# CI Validation

The GitHub Actions workflow is defined in `.github/workflows/ci.yml`.

It runs on:

- Pull requests
- Pushes to `main`

## Kubernetes and Helm

The validation job checks deployment configuration without connecting to a
cluster.

It runs:

```sh
kubeconform -strict -summary manifests
helm lint ./helm/application
helm template microservices-platform ./helm/application --namespace microservices-platform > rendered-application.yaml
kubeconform -strict -summary rendered-application.yaml
helm lint ./helm/platform/aws
helm template aws-platform ./helm/platform/aws --namespace kube-system > rendered-aws-platform.yaml
kubeconform -strict -summary rendered-aws-platform.yaml
kubeconform \
  -strict \
  -summary \
  -schema-location default \
  -schema-location \
  'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  argocd/applications
```

This validates the plain Kubernetes manifests, the Kubernetes manifests
rendered from the application and AWS platform Helm charts, and the Argo CD
`Application` resources against their custom resource schema.

## Terraform

The Terraform validation job checks the AWS infrastructure code without
creating cloud resources.

It runs:

```sh
terraform fmt -check -recursive terraform/aws
terraform -chdir=terraform/aws init -backend=false
terraform -chdir=terraform/aws validate
```

The backend is disabled during CI initialization so the workflow validates the
configuration without requiring remote state or AWS credentials.

## Go Services

The Go test job runs against each Go service with a matrix:

```text
src/checkoutservice
src/frontend
src/productcatalogservice
src/shippingservice
```

For each service, CI runs:

```sh
go test ./...
```

This runs unit tests where `_test.go` files exist and also compiles the Go
packages, which catches broken imports, syntax errors, and dependency issues.

## .NET Service

Cartservice includes an xUnit test project, so CI runs:

```sh
dotnet test cartservice.sln
```

## Build Container Images

The build container images job runs after the validation and test jobs complete
successfully.

For pull requests, it builds the service images to validate the Dockerfiles but
does not publish them. For pushes to `main`, it publishes the images to GitHub
Container Registry.

The image build job is skipped when a change does not touch deployed service
source directories or the CI workflow itself. When one service changes, only
that service image is included in the build matrix. Changes to the CI workflow
build all service images.

After publishing images from `main`, CI updates the EKS and local GHCR Helm
values with the new immutable commit SHA tags and opens an automated pull
request.

Image naming, tagging, and registry behavior are documented in
[Container Images](container-images.md).

## Other Services

Other service checks are not included yet:

- Node services have placeholder `npm test` scripts
- Python services do not currently include test files
- Java adservice does not currently include test files
