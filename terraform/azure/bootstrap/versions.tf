terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    storage_account_name = "stmicroplatformtf"
    container_name       = "bootstrap-tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}
