#!/usr/bin/env bash

set -euo pipefail

bootstrap_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
secret_arn="$(terraform -chdir="$bootstrap_dir" output -raw ghcr_secret_arn)"
github_username="$(gh api user --jq '.login')"

read -r -s -p "GHCR token: " ghcr_token
echo

if [[ -z "$ghcr_token" ]]; then
  echo "GHCR token must not be empty." >&2
  exit 1
fi

printf '%s\n%s\n' "$github_username" "$ghcr_token" \
  | jq -Rn '[inputs] | {username: .[0], token: .[1]}' \
  | aws secretsmanager put-secret-value \
    --secret-id "$secret_arn" \
    --secret-string file:///dev/stdin \
    > /dev/null

unset ghcr_token

echo "Updated GHCR credentials in Secrets Manager."
