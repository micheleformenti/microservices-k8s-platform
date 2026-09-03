output "project_resource_group_name" {
  description = "Resource group managed by the Terraform delivery identities."
  value       = azurerm_resource_group.project.name
}

output "key_vault_name" {
  description = "Name of the persistent Key Vault used for application secrets."
  value       = azurerm_key_vault.secrets.name
}

output "key_vault_uri" {
  description = "URI of the persistent Key Vault used for application secrets."
  value       = azurerm_key_vault.secrets.vault_uri
}

output "terraform_plan_client_id" {
  description = "Client ID used by GitHub Actions Terraform plan jobs."
  value       = azuread_application.terraform_plan.client_id
}

output "terraform_apply_client_id" {
  description = "Client ID used by GitHub Actions Terraform apply jobs."
  value       = azuread_application.terraform_apply.client_id
}
