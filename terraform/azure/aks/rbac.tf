resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_resource_group.project.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}
