locals {
  project_state_lock_key = "project-tfstate/terraform.tfstate.tflock"
}

data "aws_iam_policy_document" "plan_state_lock" {
  statement {
    sid = "ManageProjectStateLock"
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.terraform_state.arn}/${local.project_state_lock_key}"]
  }
}

resource "aws_iam_policy" "plan_state_lock" {
  name        = "${var.project_name}-terraform-plan-state-lock"
  description = "Allow Terraform plans to manage the project state lockfile."
  policy      = data.aws_iam_policy_document.plan_state_lock.json
}

resource "aws_iam_role_policy_attachment" "plan_read_only" {
  role       = aws_iam_role.terraform_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "plan_state_lock" {
  role       = aws_iam_role.terraform_plan.name
  policy_arn = aws_iam_policy.plan_state_lock.arn
}

resource "aws_iam_role_policy_attachment" "apply_administrator" {
  role       = aws_iam_role.terraform_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
