# Module: monitoring
# Log Analytics Workspace -- consistent across all environments

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = var.tags
}

output "workspace_id" { value = azurerm_log_analytics_workspace.main.id }
output "workspace_resource_id" { value = azurerm_log_analytics_workspace.main.id }
