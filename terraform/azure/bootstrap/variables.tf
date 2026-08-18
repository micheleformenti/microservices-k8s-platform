variable "subscription_id" {
  description = "Azure subscription in which to create resources."
  type        = string
}

variable "location" {
  description = "Azure region in which to create resources."
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Project name used for resource names and tags."
  type        = string
  default     = "microservices-platform"
}

variable "github_repository" {
  description = "GitHub repository allowed to authenticate through OIDC, in owner/name format."
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must use owner/name format."
  }
}

variable "github_apply_environment" {
  description = "Protected GitHub Environment used for Terraform applies."
  type        = string
  default     = "azure-apply"
}
