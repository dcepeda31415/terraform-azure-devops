# Module: network
# Shared network module -- parameterised per environment

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = "snet-main-${var.environment}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [cidrsubnet(var.address_space[0], 4, 0)]
}

resource "azurerm_monitor_diagnostic_setting" "vnet" {
  name                       = "diag-vnet-${var.environment}"
  target_resource_id         = azurerm_virtual_network.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "VMProtectionAlerts" }
}

output "vnet_id" { value = azurerm_virtual_network.main.id }
output "subnet_id" { value = azurerm_subnet.main.id }
