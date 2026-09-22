# Module: security
# Azure Key Vault and Managed Identity -- environment-parameterised

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                      = var.key_vault_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  enable_rbac_authorization = true
  purge_protection_enabled  = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

output "key_vault_id" { value = azurerm_key_vault.main.id }
output "key_vault_uri" { value = azurerm_key_vault.main.vault_uri }
