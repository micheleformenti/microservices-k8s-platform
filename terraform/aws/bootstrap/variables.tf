variable "project_name" {
  description = "Project name used in the Terraform state bucket name and tags."
  type        = string
  default     = "microservices-platform"
}

variable "aws_region" {
  description = "AWS region in which to create the Terraform state bucket."
  type        = string
  default     = "eu-central-1"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the Terraform roles."
  type        = string
  default     = "micheleformenti/microservices-k8s-platform"
}

variable "github_apply_environment" {
  description = "Protected GitHub environment trusted by the Terraform apply role."
  type        = string
  default     = "aws-apply"
}
