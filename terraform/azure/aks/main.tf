data "azurerm_resource_group" "project" {
  name = "rg-${var.project_name}"
}

data "azurerm_resource_group" "dns" {
  name = var.dns_zone_resource_group_name
}

data "azurerm_dns_zone" "application" {
  name                = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.dns.name
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}
