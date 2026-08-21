resource "azurerm_user_assigned_identity" "aks_imported" {
  name                = "id-${var.project_name}-aks"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tags = local.common_tags
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.project_name}-aks"
  resource_group_name = data.azurerm_resource_group.project.name
}

import {
  to = azurerm_user_assigned_identity.aks_imported
  id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-${var.project_name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-${var.project_name}-aks"
}
