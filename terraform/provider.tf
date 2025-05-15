terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "83f82310-d306-4946-b195-dd8b98f4b1f8"
  features {}
}
