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
  "repos/$repository/environments/aws-apply" \
  -F wait_timer=0 \
  -F prevent_self_review=false \
  -F 'reviewers[][type]=User' \
  -F "reviewers[][id]=$reviewer_id" \
  > /dev/null

gh variable set AWS_PLAN_ROLE_ARN \
  --repo "$repository" \
  --body "$(terraform -chdir="$bootstrap_dir" output -raw terraform_plan_role_arn)"

gh variable set AWS_APPLY_ROLE_ARN \
  --repo "$repository" \
  --body "$(terraform -chdir="$bootstrap_dir" output -raw terraform_apply_role_arn)"

echo "Configured the aws-apply environment and AWS variables for $repository."
