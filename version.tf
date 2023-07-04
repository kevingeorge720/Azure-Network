provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name      = "isd-w-infra-rg"
    storage_account_name     = "isdwtfsa"
    container_name           = "kevin"
    key                      = "assignment5"
  }
}