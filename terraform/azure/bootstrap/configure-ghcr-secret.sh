#!/usr/bin/env bash

set -euo pipefail

bootstrap_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
key_vault_name="$(terraform -chdir="$bootstrap_dir" output -raw key_vault_name)"
github_username="$(gh api user --jq '.login')"

read -r -s -p "GHCR token: " ghcr_token
echo

if [[ -z "$ghcr_token" ]]; then
  echo "GHCR token must not be empty." >&2
  exit 1
fi

printf '%s\n%s\n' "$github_username" "$ghcr_token" \
  | jq -Rn '[inputs] | {username: .[0], token: .[1]}' \
  | az keyvault secret set \
    --vault-name "$key_vault_name" \
    --name ghcr \
    --file /dev/stdin \
    --encoding utf-8 \
    --content-type application/json \
    --output none

unset ghcr_token

echo "Updated GHCR credentials in Key Vault."
