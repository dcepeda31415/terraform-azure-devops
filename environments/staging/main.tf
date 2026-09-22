# =============================================================================
# Environment: Staging
# Description: Staging -- deploys on staging branch merge, optional reviewer
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
  name     = "rg-infra-staging"
  location = var.location
  tags     = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  workspace_name      = "law-infra-staging"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = "staging"
  address_space       = var.address_space
  log_analytics_workspace_id = module.monitoring.workspace_id
  tags                = local.tags
}

locals {
  tags = {
    environment = "staging"
    managed_by  = "terraform"
    project     = "infrastructure-automation"
  }
}
