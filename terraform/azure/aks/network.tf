data "azurerm_resource_group" "project" {
  name = "rg-${var.project_name}"
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

resource "azurerm_virtual_network" "project" {
  name                = "vnet-${var.project_name}"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name
  address_space       = var.vnet_address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "aks_nodes" {
  name                            = "snet-aks"
  resource_group_name             = data.azurerm_resource_group.project.name
  virtual_network_name            = azurerm_virtual_network.project.name
  address_prefixes                = var.aks_subnet_address_prefixes
  default_outbound_access_enabled = false
}

resource "azurerm_public_ip" "egress" {
  name                = "pip-${var.project_name}-nat"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]

  tags = local.common_tags
}

resource "azurerm_nat_gateway" "egress" {
  name                = "nat-${var.project_name}"
  location            = data.azurerm_resource_group.project.location
  resource_group_name = data.azurerm_resource_group.project.name
  sku_name            = "Standard"

  tags = local.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "egress" {
  nat_gateway_id       = azurerm_nat_gateway.egress.id
  public_ip_address_id = azurerm_public_ip.egress.id
}

resource "azurerm_subnet_nat_gateway_association" "egress" {
  subnet_id      = azurerm_subnet.aks_nodes.id
  nat_gateway_id = azurerm_nat_gateway.egress.id
}
