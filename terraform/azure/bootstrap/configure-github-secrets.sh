#!/usr/bin/env bash

set -euo pipefail

bootstrap_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository="$(
  cd "$bootstrap_dir"
  gh repo view --json nameWithOwner --jq '.nameWithOwner'
)"
reviewer_id="$(gh api user --jq '.id')"

gh api \
  --method PUT \
  "repos/$repository/environments/azure-apply" \
  -F wait_timer=0 \
  -F prevent_self_review=false \
  -F 'reviewers[][type]=User' \
  -F "reviewers[][id]=$reviewer_id" \
  > /dev/null

gh secret set AZURE_PLAN_CLIENT_ID \
  --repo "$repository" \
  --body "$(terraform -chdir="$bootstrap_dir" output -raw terraform_plan_client_id)"

gh secret set AZURE_APPLY_CLIENT_ID \
  --repo "$repository" \
  --body "$(terraform -chdir="$bootstrap_dir" output -raw terraform_apply_client_id)"

gh secret set AZURE_SUBSCRIPTION_ID \
  --repo "$repository" \
  --body "$(az account show --query id --output tsv)"

gh secret set AZURE_TENANT_ID \
  --repo "$repository" \
  --body "$(az account show --query tenantId --output tsv)"

gh secret set AZURE_KEY_VAULT_NAME \
  --repo "$repository" \
  --body "$(terraform -chdir="$bootstrap_dir" output -raw key_vault_name)"

echo "Configured the azure-apply environment and masked Azure secrets for $repository."
