#!/usr/bin/env bash
set -euo pipefail

context="rancher-desktop"
namespace="microservices-platform"
github_username="$(gh api user --jq '.login')"

read -r -s -p "GHCR token: " ghcr_token
echo

if [[ -z "$ghcr_token" ]]; then
  echo "GHCR token must not be empty." >&2
  exit 1
fi

kubectl --context "$context" create namespace "$namespace" \
  --dry-run=client \
  --output yaml \
  | kubectl --context "$context" apply -f -

printf '%s\n%s\n' "$github_username" "$ghcr_token" \
  | jq -Rn '
      [inputs] as $credentials
      | {auths: {"ghcr.io": {
          username: $credentials[0],
          password: $credentials[1],
          auth: ($credentials | join(":") | @base64)
        }}}
    ' \
  | kubectl --context "$context" create secret generic ghcr-pull \
  --namespace "$namespace" \
  --type kubernetes.io/dockerconfigjson \
  --from-file=.dockerconfigjson=/dev/stdin \
  --dry-run=client \
  --output yaml \
  | kubectl --context "$context" apply -f -

unset ghcr_token

echo "Configured GHCR pull secret in $context/$namespace."
