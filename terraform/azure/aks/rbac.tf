resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_resource_group.project.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "application_gateway_controller_configuration" {
  scope                            = data.azurerm_resource_group.project.id
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
