# ---------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. Licensed under the MIT license.
# ---------------------------------------------------------------------

############################################################
# Durable Infrastructure Data Sources
#
# Looks up pre-created infrastructure from Pool 1
# (foundry_basic_private test infrastructure)
#
# Uses data sources (command = plan) for fast, read-only
# lookups instead of resource creation (command = apply)
############################################################

terraform {
  required_version = ">= 1.13, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}

# Resource Group containing all durable infrastructure
data "azurerm_resource_group" "this" {
  name = var.fbp_resource_group_name
}

# Virtual Network (172.16.0.0/16)
data "azurerm_virtual_network" "this" {
  name                = var.fbp_vnet_name
  resource_group_name = data.azurerm_resource_group.this.name
}

# Connections Subnet (for AI Foundry private endpoints)
data "azurerm_subnet" "connection" {
  name                 = var.connection_subnet_name
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = data.azurerm_virtual_network.this.name
}

# Private DNS Zone for Cognitive Services
data "azurerm_private_dns_zone" "cognitive" {
  name                = var.cognitive_dns_zone_name
  resource_group_name = data.azurerm_resource_group.this.name
}

# Private DNS Zone for AI Services
data "azurerm_private_dns_zone" "ai_services" {
  name                = var.ai_services_dns_zone_name
  resource_group_name = data.azurerm_resource_group.this.name
}

# Private DNS Zone for OpenAI
data "azurerm_private_dns_zone" "openai" {
  name                = var.openai_dns_zone_name
  resource_group_name = data.azurerm_resource_group.this.name
}

