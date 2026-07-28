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
