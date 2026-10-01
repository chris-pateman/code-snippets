terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.15.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.115.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
    semvers = {
      source  = "anapsix/semvers"
      version = "=0.7.1"
    }
  }

  backend "azurerm" {
  }

}

provider "semvers" {}

provider "azapi" {}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

provider "azurerm" {
  subscription_id     = var.subscription_id
  storage_use_azuread = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    machine_learning {
      purge_soft_deleted_workspace_on_destroy = true
    }
    virtual_machine {
      detach_implicit_data_disk_on_deletion = false
      delete_os_disk_on_deletion            = true
      graceful_shutdown                     = false
      skip_shutdown_and_force_delete        = false
    }
  }
}
