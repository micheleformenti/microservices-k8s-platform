#!/usr/bin/env bash

set -euo pipefail

bootstrap_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository="$(
  cd "$bootstrap_dir"
  gh repo view --json nameWithOwner --jq '.nameWithOwner'
)"

gh variable set AZURE_PLAN_CLIENT_ID \
  --repo "$repository" \
  --body "$(terraform -chdir="$bootstrap_dir" output -raw terraform_plan_client_id)"

gh variable set AZURE_APPLY_CLIENT_ID \
  --repo "$repository" \
  --body "$(terraform -chdir="$bootstrap_dir" output -raw terraform_apply_client_id)"

gh variable set AZURE_SUBSCRIPTION_ID \
  --repo "$repository" \
  --body "$(az account show --query id --output tsv)"

gh variable set AZURE_TENANT_ID \
  --repo "$repository" \
  --body "$(az account show --query tenantId --output tsv)"

echo "Configured Azure GitHub variables for $repository."
