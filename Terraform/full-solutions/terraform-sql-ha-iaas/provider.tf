terraform {
  #backend "azurerm" {}

  required_version = ">= 1.0.9"
  required_providers {
    azurerm = {
      version = ">=2.8.0"
    }
  }
}

provider "azurerm" {
  features {}
}