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
```

This validates both the plain Kubernetes manifests and the Kubernetes manifests
rendered from the Helm chart.

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
