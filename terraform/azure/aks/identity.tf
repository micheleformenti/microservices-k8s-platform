resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.project_name}-aks"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tags = local.common_tags
}

import {
  to = azurerm_user_assigned_identity.aks
  id = "${data.azurerm_resource_group.project.id}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-${var.project_name}-aks"
}
