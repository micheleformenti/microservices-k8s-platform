#!/usr/bin/env bash

set -euo pipefail

bootstrap_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repository="$(
  cd "$bootstrap_dir"
  gh repo view --json nameWithOwner --jq '.nameWithOwner'
)"
reviewer_id="$(gh api user --jq '.id')"
eks_admin_principal_arn="$(aws sts get-caller-identity --query Arn --output text)"

if [[ "$eks_admin_principal_arn" == arn:aws:sts::* ]]; then
  echo "Use an IAM user or role profile, not an assumed-role session, to configure EKS admin access." >&2
  exit 1
fi

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

gh variable set AWS_EKS_ADMIN_PRINCIPAL_ARN \
  --repo "$repository" \
  --body "$eks_admin_principal_arn"

echo "Configured the aws-apply environment and AWS variables for $repository."
