resource "azurerm_role_assignment" "terraform_plan_state" {
  scope                = azurerm_storage_container.terraform_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.terraform_plan.object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "terraform_apply_state" {
  scope                = azurerm_storage_container.terraform_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.terraform_apply.object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "terraform_plan_project" {
  scope                = azurerm_resource_group.project.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.terraform_plan.object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "terraform_apply_project" {
  scope                = azurerm_resource_group.project.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform_apply.object_id
  principal_type       = "ServicePrincipal"
}
