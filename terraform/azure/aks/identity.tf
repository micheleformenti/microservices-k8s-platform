data "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.project_name}-aks"
  resource_group_name = data.azurerm_resource_group.project.name
}
