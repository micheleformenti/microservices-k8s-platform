data "azurerm_resource_group" "project" {
  name = "rg-${var.project_name}"
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}
