# Staging state backend -- isolated from dev and prod
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stgtfstatestaging"
    container_name       = "tfstate"
    key                  = "infra-staging.tfstate"
    use_azuread_auth     = true
  }
}
