# =============================================================================
# Environment: Development
# Description: Dev environment -- auto-deploys on develop branch merge
# =============================================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-infra-dev"
  location = var.location
  tags     = local.tags
}

# Reference shared modules
module "monitoring" {
  source              = "../../modules/monitoring"
  workspace_name      = "law-infra-dev"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = "dev"
  address_space       = var.address_space
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                = local.tags
}

locals {
  tags = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "infrastructure-automation"
  }
}
