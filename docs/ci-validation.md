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
helm lint ./helm
helm template microservices-platform ./helm --namespace microservices-platform > rendered.yaml
kubeconform -strict -summary rendered.yaml
kubeconform \
  -strict \
  -summary \
  -schema-location default \
  -schema-location \
  'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
  argocd/applications
```

This validates the plain Kubernetes manifests, the Kubernetes manifests
rendered from the Helm chart, and the Argo CD `Application` resources against
their custom resource schema.

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

## Other Services

Other service checks are not included yet:

- Node services have placeholder `npm test` scripts
- Python services do not currently include test files
- Java adservice does not currently include test files
