locals {
  github_oidc_issuer   = "https://token.actions.githubusercontent.com"
  github_oidc_audience = "api://AzureADTokenExchange"

  github_plan_subject  = "repo:${var.github_repository}:pull_request"
  github_apply_subject = "repo:${var.github_repository}:environment:${var.github_apply_environment}"
}

resource "azuread_application" "terraform_plan" {
  display_name = "gh-${var.project_name}-tf-plan"
  description  = "GitHub Actions identity for Terraform plans."
}

resource "azuread_service_principal" "terraform_plan" {
  client_id = azuread_application.terraform_plan.client_id
}

resource "azuread_application_federated_identity_credential" "terraform_plan" {
  application_id = azuread_application.terraform_plan.id
  display_name   = "github-pull-request"
  description    = "Trust pull requests from ${var.github_repository}."
  audiences      = [local.github_oidc_audience]
  issuer         = local.github_oidc_issuer
  subject        = local.github_plan_subject
}

resource "azuread_application" "terraform_apply" {
  display_name = "gh-${var.project_name}-tf-apply"
  description  = "GitHub Actions identity for approved Terraform applies."
}

resource "azuread_service_principal" "terraform_apply" {
  client_id = azuread_application.terraform_apply.client_id
}

resource "azuread_application_federated_identity_credential" "terraform_apply" {
  application_id = azuread_application.terraform_apply.id
  display_name   = "github-environment"
  description    = "Trust the ${var.github_apply_environment} environment in ${var.github_repository}."
  audiences      = [local.github_oidc_audience]
  issuer         = local.github_oidc_issuer
  subject        = local.github_apply_subject
}
