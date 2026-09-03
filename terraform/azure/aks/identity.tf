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
  name                      = "fic-${var.project_name}-appgateway-controller"
  user_assigned_identity_id = azurerm_user_assigned_identity.application_gateway_controller.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = azurerm_kubernetes_cluster.platform.oidc_issuer_url
  subject                   = "system:serviceaccount:aks-platform:alb-controller-sa"
}

resource "azurerm_user_assigned_identity" "external_dns" {
  name                = "id-${var.project_name}-external-dns"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tags = local.common_tags
}

resource "azurerm_federated_identity_credential" "external_dns" {
  name                      = "fic-${var.project_name}-external-dns"
  user_assigned_identity_id = azurerm_user_assigned_identity.external_dns.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = azurerm_kubernetes_cluster.platform.oidc_issuer_url
  subject                   = "system:serviceaccount:aks-platform:external-dns"
}

resource "azurerm_user_assigned_identity" "external_secrets" {
  name                = "id-${var.project_name}-external-secrets"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name

  tags = local.common_tags
}

resource "azurerm_federated_identity_credential" "external_secrets" {
  name                      = "fic-${var.project_name}-external-secrets"
  user_assigned_identity_id = azurerm_user_assigned_identity.external_secrets.id
  audience                  = ["api://AzureADTokenExchange"]
  issuer                    = azurerm_kubernetes_cluster.platform.oidc_issuer_url
  subject                   = "system:serviceaccount:aks-platform:external-secrets"
}
