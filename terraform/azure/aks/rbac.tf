resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_resource_group.project.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "application_gateway_controller_configuration" {
  scope                            = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_kubernetes_cluster.platform.node_resource_group}"
  role_definition_name             = "AppGw for Containers Configuration Manager"
  principal_id                     = azurerm_user_assigned_identity.application_gateway_controller.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "application_gateway_controller_network" {
  scope                            = azurerm_subnet.application_gateway.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.application_gateway_controller.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "application_gateway_controller_reader" {
  scope                            = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_kubernetes_cluster.platform.node_resource_group}"
  role_definition_name             = "Reader"
  principal_id                     = azurerm_user_assigned_identity.application_gateway_controller.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "external_dns_zone" {
  scope                            = data.azurerm_dns_zone.application.id
  role_definition_name             = "DNS Zone Contributor"
  principal_id                     = azurerm_user_assigned_identity.external_dns.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "external_dns_resource_group_reader" {
  scope                            = data.azurerm_resource_group.dns.id
  role_definition_name             = "Reader"
  principal_id                     = azurerm_user_assigned_identity.external_dns.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "external_secrets_key_vault" {
  scope                            = data.azurerm_key_vault.secrets.id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = azurerm_user_assigned_identity.external_secrets.principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
