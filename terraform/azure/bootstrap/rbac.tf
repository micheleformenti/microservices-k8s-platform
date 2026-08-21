data "azurerm_role_definition" "application_gateway_configuration_manager" {
  name  = "AppGw for Containers Configuration Manager"
  scope = "/subscriptions/${var.subscription_id}"
}

data "azurerm_role_definition" "network_contributor" {
  name  = "Network Contributor"
  scope = "/subscriptions/${var.subscription_id}"
}

data "azurerm_role_definition" "reader" {
  name  = "Reader"
  scope = "/subscriptions/${var.subscription_id}"
}

locals {
  terraform_apply_assignable_role_ids = join(", ", [
    basename(data.azurerm_role_definition.application_gateway_configuration_manager.role_definition_id),
    basename(data.azurerm_role_definition.network_contributor.role_definition_id),
    basename(data.azurerm_role_definition.reader.role_definition_id),
  ])
}

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

resource "azurerm_role_assignment" "terraform_plan_aks_user" {
  scope                = azurerm_resource_group.project.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_service_principal.terraform_plan.object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "terraform_apply_project" {
  scope                = azurerm_resource_group.project.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.terraform_apply.object_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "terraform_apply_network_rbac" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Role Based Access Control Administrator"
  principal_id         = azuread_service_principal.terraform_apply.object_id
  principal_type       = "ServicePrincipal"
  condition_version    = "2.0"
  condition            = <<-CONDITION
    ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})) OR
      (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.terraform_apply_assignable_role_ids}} AND
      @Request[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal'}))
    AND
    ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR
      (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${local.terraform_apply_assignable_role_ids}} AND
      @Resource[Microsoft.Authorization/roleAssignments:PrincipalType] ForAnyOfAnyValues:StringEqualsIgnoreCase {'ServicePrincipal'}))
  CONDITION
}
