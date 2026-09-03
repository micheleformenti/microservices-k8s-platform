output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "terraform_plan_role_arn" {
  description = "IAM role assumed by GitHub Actions Terraform plan jobs."
  value       = aws_iam_role.terraform_plan.arn
}

output "terraform_apply_role_arn" {
  description = "IAM role assumed by approved GitHub Actions Terraform apply jobs."
  value       = aws_iam_role.terraform_apply.arn
}

output "ghcr_secret_arn" {
  description = "ARN of the Secrets Manager secret that stores GHCR pull credentials."
  value       = aws_secretsmanager_secret.ghcr.arn
}
