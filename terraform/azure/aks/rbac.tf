resource "azurerm_role_assignment" "aks_network" {
  scope                = data.azurerm_resource_group.project.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
  principal_type       = "ServicePrincipal"
}

import {
  to = azurerm_role_assignment.aks_network
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-${var.project_name}/providers/Microsoft.Authorization/roleAssignments/470389ab-79a0-e956-c876-59f7c2cdc587"
}
