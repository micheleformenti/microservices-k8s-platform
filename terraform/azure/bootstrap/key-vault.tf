data "azurerm_client_config" "current" {}

# Public network access allows administrators and AKS workloads to reach the
# vault without a private endpoint. Azure RBAC controls data-plane access.
#trivy:ignore:AZU-0013
resource "azurerm_key_vault" "secrets" {
  name                          = var.key_vault_name
  location                      = azurerm_resource_group.project.location
  resource_group_name           = azurerm_resource_group.project.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled    = true
  public_network_access_enabled = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
    Purpose   = "application-secrets"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "bootstrap_operators_key_vault_secrets" {
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_group.bootstrap_operators.object_id
  principal_type       = "Group"
}
