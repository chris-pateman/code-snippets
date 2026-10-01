#================================================================================================
# Provider Configuration
#================================================================================================
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.59.0"
    }
  }
  backend "local" {
    path = "../terraform.tfstate"
  }
}

provider "azurerm" {
  subscription_id = var.hub_subscription_id
  features {
  }
}

###########################
# HUB Subscription
###########################

data "azurerm_subscription" "hub" {
}

data "external" "hub_sub_tags" {
  program = ["pwsh", "checkTags.ps1", "-tags", jsonencode(data.azurerm_subscription.hub.tags), "-requiredTags", var.required_tags]
}

check "subscription" {

  assert {
    condition     = data.azurerm_subscription.hub.state == "Enabled"
    error_message = "Sub is not enabled"
  }

  assert {
    condition     = data.azurerm_subscription.hub.tenant_id == var.tenant_id
    error_message = "Sub not created in correct tenant"
  }

  # Resources are correctly tagged
  assert {
    condition     = data.external.hub_sub_tags.result["check"] == "OK"
    error_message = "There are missing tags: '${data.external.hub_sub_tags.result["missing_tags"]}'"
  }

  # Service is deployed in DEV/TST or Enterprise

}

###########################
# HUB Storage account
###########################

data "azurerm_storage_account" "hub" {
  name                = format("sa%s%s%sdsh%s01", var.tenant, var.region, var.environment, var.service)
  resource_group_name = format("rg-%s-%s-dsh-%s-infra", var.region, var.environment, var.service)
}

data "external" "soft_delete_status" {
  program = ["pwsh", "runAzQuery.ps1", "-query", "az storage blob service-properties delete-policy show --account-name ${format("sa%s%s%sdsh%s01", var.tenant, var.region, var.environment, var.service)}"]
}

data "external" "hub_sa_cli" {
  program = ["pwsh", "runAzQuery.ps1", "-query", "az storage account show -n ${format("sa%s%s%sdsh%s01", var.tenant, var.region, var.environment, var.service)} --query '{privateLinkServiceConnectionState: privateEndpointConnections[0].privateLinkServiceConnectionState.status, privateEndpointId: privateEndpointConnections[0].privateEndpoint.id, networkDefaultAction: networkRuleSet.defaultAction}'"]
}

data "external" "sa_tags" {
  program = ["pwsh", "checkTags.ps1", "-tags", jsonencode(data.azurerm_storage_account.hub.tags), "-requiredTags", var.required_tags]
}

check "hub_storage_account" {

  # Ensure Infrastructure Encryption has been enabled
  assert {
    condition     = data.azurerm_storage_account.hub.infrastructure_encryption_enabled
    error_message = "Infrastructure Encryption should be enabled but its not"
  }

  # Ensure the Storage Account has replication enabled
  assert {
    condition     = data.azurerm_storage_account.hub.account_replication_type == "GRS"
    error_message = "Replication type is '${data.azurerm_storage_account.hub.account_replication_type}', should be 'GRS'"
  }

  # Ensure stored artifacts are protected
  assert {
    condition     = data.external.soft_delete_status.result["days"] == "10"
    error_message = "Soft delete set to: ${data.external.soft_delete_status.result["days"]}, should be '10'"
  }

  # Resources are correctly tagged
  assert {
    condition     = data.external.sa_tags.result["check"] == "OK"
    error_message = "There are missing tags: '${data.external.sa_tags.result["missing_tags"]}'"
  }

  # Ensure the Private Endpoint and DNS record is in place
  assert {
    condition     = data.external.hub_sa_cli.result["privateLinkServiceConnectionState"] == "Approved"
    error_message = "SA Private endpiont not approved: '${data.external.hub_sa_cli.result["privateLinkServiceConnectionState"]}', should be set to 'Approved'"
  }

  # Ensure the Storage Account has not been exposed publicly
  assert {
    condition     = data.external.hub_sa_cli.result["networkDefaultAction"] == "Deny"
    error_message = "Storage account default action is '${data.external.hub_sa_cli.result["networkDefaultAction"]}', should be set to 'Deny'"
  }

}

###########################
# HUB Firewall
###########################

data "azurerm_firewall" "hub_firewall" {
  name                = format("afw-%s-%s-dsh-%s-01", var.region, var.environment, var.service)
  resource_group_name = format("rg-%s-%s-dsh-%s-vnet", var.region, var.environment, var.service)
}

data "external" "fw_tags" {
  program = ["pwsh", "checkTags.ps1", "-tags", jsonencode(data.azurerm_firewall.hub_firewall.tags), "-requiredTags", var.required_tags]
}

data "azurerm_public_ip" "fw_pip" {
  name                = format("pip-%s-%s-dsh-%s-afw-01", var.region, var.environment, var.service)
  resource_group_name = format("rg-%s-%s-dsh-%s-vnet", var.region, var.environment, var.service)
}

data "external" "fw_diag" {
  program = ["pwsh", "checkDiagnostics.ps1", "-resource_id", data.azurerm_firewall.hub_firewall.id]
}

check "firewall" {

  # Ensure Azure Firewall is provisioned in the correct subscription
  assert {
    condition     = startswith(data.azurerm_firewall.hub_firewall.id, format("/subscriptions/%s/", var.hub_subscription_id))
    error_message = "Firewall is in wrong subscription"
  }

  # An IP has been assigned to the Azure Firewall
  assert {
    condition     = data.azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address == var.hub_firewall_ip
    error_message = "Firewall prite IP is '${data.azurerm_firewall.hub_firewall.ip_configuration[0].private_ip_address}', should be '${var.hub_firewall_ip}'"
  }

  assert {
    condition     = endswith(data.azurerm_firewall.hub_firewall.ip_configuration[0].public_ip_address_id, format("pip-%s-%s-dsh-%s-afw-01", var.region, var.environment, var.service))
    error_message = "Firewall prite IP is '${data.azurerm_firewall.hub_firewall.ip_configuration[0].public_ip_address_id}', should be '${format("pip-%s-%s-dsh-%s-afw-01", var.region, var.environment, var.service)}'"
  }

  # Ensure diagnostics are enabled on the Azure Firewall
  assert {
    condition     = data.external.fw_diag.result["exists"] == "OK"
    error_message = "No diagnostic settings were found for the Firewall"
  }

  # Ensure diagnostics are being sent to the Log Analytics workspace
  assert {
    condition     = data.external.fw_diag.result["law"] == var.laws_workspace_resource_id
    error_message = "Incorrect LAW set up in diagnostics"
  }

  assert {
    condition     = data.external.fw_diag.result["logAnalyticsDestinationType"] == "Dedicated"
    error_message = "LAW type is '${data.external.fw_diag.result["logAnalyticsDestinationType"]}', should be 'Dedicated'"
  }

  # DDoS Protection enabled
  assert {
    condition     = data.azurerm_public_ip.fw_pip.ddos_protection_mode == "Enabled"
    error_message = "FW PIP DDOS status is: '${data.azurerm_public_ip.fw_pip.ddos_protection_mode}', should be 'Enabled'"
  }

  # Resources are correctly tagged
  assert {
    condition     = data.external.fw_tags.result["check"] == "OK"
    error_message = "There are missing tags: '${data.external.fw_tags.result["missing_tags"]}'"
  }

  # Ensure Threat Intelligence is enabled
  assert {
    condition     = data.azurerm_firewall.hub_firewall.threat_intel_mode == "Deny"
    error_message = "Firewall TI is '${data.azurerm_firewall.hub_firewall.threat_intel_mode}', should be 'Deny'"
  }

}

###########################
# HUB Firewall Policy
###########################

data "azurerm_firewall_policy" "hub_firewall_policy" {
  name                = format("afwp-%s-%s-dsh-%s-01", var.region, var.environment, var.service)
  resource_group_name = format("rg-%s-%s-dsh-%s-vnet", var.region, var.environment, var.service)
}

data "external" "fwp_tags" {
  program = ["pwsh", "checkTags.ps1", "-tags", jsonencode(data.azurerm_firewall_policy.hub_firewall_policy.tags), "-requiredTags", var.required_tags]
}

check "firewall_policy" {

  # Ensure Threat Intelligence is enabled
  assert {
    condition     = data.azurerm_firewall_policy.hub_firewall_policy.threat_intelligence_mode == "Deny"
    error_message = "Firewall Policy TIM is '${data.azurerm_firewall_policy.hub_firewall_policy.threat_intelligence_mode}', should be 'Deny'"
  }

  # Resources are correctly tagged
  assert {
    condition     = data.external.fwp_tags.result["check"] == "OK"
    error_message = "There are missing tags: '${data.external.fw_tags.result["missing_tags"]}'"
  }

  # Ensure Domain Name System (DNS) proxy is set and enabled
  assert {
    condition     = data.azurerm_firewall_policy.hub_firewall_policy.dns[0].proxy_enabled
    error_message = "DNS Proxy should be enabled"
  }

}

###########################
# HUB Hub Keyvault
###########################

data "azurerm_key_vault" "hub_akv" {
  name                = format("kv-%s-%s-%s-dsh-%s-01", var.tenant, var.region, var.environment, var.service)
  resource_group_name = format("rg-%s-%s-dsh-%s-infra", var.region, var.environment, var.service)
}

data "external" "hub_akv_tags" {
  program = ["pwsh", "checkTags.ps1", "-tags", jsonencode(data.azurerm_key_vault.hub_akv.tags), "-requiredTags", var.required_tags]
}

data "external" "hub_akv_diag" {
  program = ["pwsh", "checkDiagnostics.ps1", "-resource_id", data.azurerm_key_vault.hub_akv.id]
}

data "external" "hub_akv_cli" {
  program = ["pwsh", "runAzQuery.ps1", "-query", "az keyvault show -n  ${format("kv-%s-%s-%s-dsh-%s-01", var.tenant, var.region, var.environment, var.service)} --query '{privateLinkServiceConnectionState: properties.privateEndpointConnections[0].privateLinkServiceConnectionState.status, softDeleteRetentionInDays: properties.enableSoftDelete, defaultAction: properties.networkAcls.defaultAction}'"]
}


check "hub_keyvault" {

  # Azure KeyVault has been provisioned within the correct subscription
  assert {
    condition     = startswith(data.azurerm_key_vault.hub_akv.id, format("/subscriptions/%s/", var.hub_subscription_id))
    error_message = "Keyvault is in wrong subscription"
  }

  # Ensure the KeyVault has purge protection
  assert {
    condition     = data.azurerm_key_vault.hub_akv.purge_protection_enabled
    error_message = "Purge protection should be enabled on the AKV"
  }

  # Ensure Soft Delete retention has been set
  assert {
    condition     = data.external.hub_akv_cli.result["softDeleteRetentionInDays"] == "True"
    error_message = "Soft delete should be enabled on the AKV"
  }
  # Ensure diagnostics are enabled on the Key Vault
  assert {
    condition     = data.external.hub_akv_diag.result["exists"] == "OK"
    error_message = "No diagnostic settings were found for the Firewall"
  }

  # Ensure diagnostics are being sent to the Log Analytics workspace
  assert {
    condition     = data.external.hub_akv_diag.result["law"] == var.laws_workspace_resource_id
    error_message = "Incorrect LAW set up in diagnostics"
  }

  assert {
    condition     = data.external.hub_akv_diag.result["logAnalyticsDestinationType"] == "AzureDiagnostics"
    error_message = "LAW type is '${data.external.hub_akv_diag.result["logAnalyticsDestinationType"]}', should be 'AzureDiagnostics'"
  }

  # Ensure the Private Endpoint and DNS record and are in place
  assert {
    condition     = data.external.hub_akv_cli.result["privateLinkServiceConnectionState"] == "Approved"
    error_message = "AKV Private endpiont not approved: '${data.external.hub_akv_cli.result["privateLinkServiceConnectionState"]}', should be set to 'Approved'"
  }

  # Ensure the Key Vault has not been exposed publicly
  assert {
    condition     = data.external.hub_akv_cli.result["defaultAction"] == "Deny"
    error_message = "KeyVault default action is '${data.external.hub_akv_cli.result["defaultAction"]}', should be set to 'Deny'"
  }

  # Resources are correctly tagged
  assert {
    condition     = data.external.hub_akv_tags.result["check"] == "OK"
    error_message = "There are missing tags: '${data.external.hub_akv_tags.result["missing_tags"]}'"
  }
}

###########################
# HUB Hub VNET
###########################

data "azurerm_virtual_network" "hub_vnet" {
  name                = format("vnet-%s-%s-dsh-%s-01", var.region, var.environment, var.service)
  resource_group_name = format("rg-%s-%s-dsh-%s-vnet", var.region, var.environment, var.service)
}

data "external" "hub_vnet_tags" {
  program = ["pwsh", "checkTags.ps1", "-tags", jsonencode(data.azurerm_virtual_network.hub_vnet.tags), "-requiredTags", var.required_tags]
}

data "external" "hub_vnet_diag" {
  program = ["pwsh", "checkDiagnostics.ps1", "-resource_id", data.azurerm_virtual_network.hub_vnet.id]
}

data "external" "hub_vnet_nsg" {
  program = ["pwsh", "checkNSGs.ps1", "-subnets", join(",", data.azurerm_virtual_network.hub_vnet.subnets), "-vnet", data.azurerm_virtual_network.hub_vnet.name, "-rg", data.azurerm_virtual_network.hub_vnet.resource_group_name]
}

data "azurerm_subnet" "hub_vnet_endpoint_subnet" {
  name                 = format("sn-%s-%s-dsh-%s-endpoint", var.region, var.environment, var.service)
  virtual_network_name = data.azurerm_virtual_network.hub_vnet.name
  resource_group_name  = data.azurerm_virtual_network.hub_vnet.resource_group_name
}

data "azurerm_route_table" "example" {
  name                = format("udr-%s-%s-dsh-%s-azurefirewallsubnet", var.region, var.environment, var.service)
  resource_group_name = data.azurerm_virtual_network.hub_vnet.resource_group_name
}

locals {
  required_service_endpoints = ["Microsoft.KeyVault", "Microsoft.AzureActiveDirectory", "Microsoft.Storage"]
  addresses_appliance        = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
}

check "hub_vnet" {

  # Ensure the CIDR range is correct 
  assert {
    condition     = data.azurerm_virtual_network.hub_vnet.address_space[0] == var.hub_vnet_address_space
    error_message = "VNET address space is '${data.azurerm_virtual_network.hub_vnet.address_space[0]}', should be '${var.hub_vnet_address_space}"
  }

  # Ensure the Effective Routes are assigned and, with the correct route-table entries
  assert {
    condition     = alltrue([for v in data.azurerm_route_table.example.route : v.next_hop_type == "VirtualAppliance" && v.next_hop_in_ip_address == var.corehub_azfw_ip if contains(local.addresses_appliance, v.address_prefix)])
    error_message = "Check ranges that should be pointing to '10.129.0.4' as a virtual appliance"
  }
  assert {
    condition     = alltrue([for v in data.azurerm_route_table.example.route : v.next_hop_type == "Internet" if v.address_prefix == "0.0.0.0/0"])
    error_message = "Range '' should have next hop type of 'Internet'"
  }

  # Ensure the appropriate Service Endpoints are facilitated
  assert {
    condition     = alltrue([for v in local.required_service_endpoints : contains(data.azurerm_subnet.hub_vnet_endpoint_subnet.service_endpoints, v)])
    error_message = "The following service endpointsshould be enabled in ${format("sn-%s-%s-dsh-%s-endpoint", var.region, var.environment, var.service)}: '${join(", ", local.required_service_endpoints)}'"
  }

  # Ensure diagnostics are enabled on the T-TOC vNet
  assert {
    condition     = data.external.hub_vnet_diag.result["exists"] == "OK"
    error_message = "No diagnostic settings were found for the Firewall"
  }

  # Ensure diagnostics are being sent to the Log Analytics workspace
  assert {
    condition     = data.external.hub_vnet_diag.result["law"] == var.laws_workspace_resource_id
    error_message = "Incorrect LAW set up in diagnostics"
  }

  # Ensure NSG's area applied to all subnets
  assert {
    condition     = data.external.hub_vnet_nsg.result["check"] == "OK"
    error_message = "The follwing subnets are missing an NSG: '${data.external.hub_vnet_nsg.result["missingNSG"]}'"
  }

  # Resources are correctly tagged
  assert {
    condition     = data.external.hub_vnet_tags.result["check"] == "OK"
    error_message = "There are missing tags: '${data.external.hub_vnet_tags.result["missing_tags"]}'"
  }

}
