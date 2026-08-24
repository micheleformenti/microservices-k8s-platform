resource "azurerm_resource_group" "terraform_state" {
  name     = "rg-${var.project_name}-state"
  location = var.location

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
    Purpose   = "terraform-state"
  }
}

resource "azurerm_resource_group" "project" {
  name     = "rg-${var.project_name}"
  location = var.location

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

resource "azurerm_storage_account" "terraform_state" {
  name                            = "stmicroplatformtf"
  resource_group_name             = azurerm_resource_group.terraform_state.name
  location                        = azurerm_resource_group.terraform_state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
    Purpose   = "terraform-state"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "project_state" {
  name                  = "project-tfstate"
  storage_account_id    = azurerm_storage_account.terraform_state.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "bootstrap_state" {
  name                  = "bootstrap-tfstate"
  storage_account_id    = azurerm_storage_account.terraform_state.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}
