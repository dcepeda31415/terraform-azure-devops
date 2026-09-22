# Dev state backend -- isolated from staging and prod
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stgtfstatedev"
    container_name       = "tfstate"
    key                  = "infra-dev.tfstate"
    use_azuread_auth     = true
  }
}
