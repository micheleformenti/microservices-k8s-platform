resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.project_name}-aks"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tags = local.common_tags
}

resource "azurerm_user_assigned_identity" "application_gateway_controller" {
  name                = "id-${var.project_name}-appgateway-controller"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tags = local.common_tags
}

resource "azurerm_federated_identity_credential" "application_gateway_controller" {
  name                = "fic-${var.project_name}-appgateway-controller"
  resource_group_name = data.azurerm_resource_group.project.name
  parent_id           = azurerm_user_assigned_identity.application_gateway_controller.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.platform.oidc_issuer_url
  subject             = "system:serviceaccount:azure-alb-system:alb-controller-sa"
}

resource "azurerm_user_assigned_identity" "external_dns" {
  name                = "id-${var.project_name}-external-dns"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tags = local.common_tags
}

resource "azurerm_federated_identity_credential" "external_dns" {
  name                = "fic-${var.project_name}-external-dns"
  resource_group_name = data.azurerm_resource_group.project.name
  parent_id           = azurerm_user_assigned_identity.external_dns.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.platform.oidc_issuer_url
  subject             = "system:serviceaccount:azure-alb-system:external-dns"
}
