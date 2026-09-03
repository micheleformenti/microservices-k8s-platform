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

variable "key_vault_name" {
  description = "Globally unique name of the persistent Key Vault used for application secrets."
  type        = string

  validation {
    condition = (
      can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.key_vault_name)) &&
      !strcontains(var.key_vault_name, "--")
    )
    error_message = "key_vault_name must be 3-24 characters, start with a letter, end with a letter or digit, contain only letters, digits, and non-consecutive hyphens."
  }
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

variable "bootstrap_operators_group_name" {
  description = "Entra ID group allowed to manage the bootstrap Terraform state."
  type        = string
  default     = "grp-microservices-platform-bootstrap-operators"
}
