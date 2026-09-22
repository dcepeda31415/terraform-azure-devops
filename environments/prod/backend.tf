# Production state backend
# RBAC: only prod-service-connection SP has Storage Blob Data Contributor
# No dev or staging service connections can access this state
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "stgtfstateprod"
    container_name       = "tfstate"
    key                  = "infra-prod.tfstate"
    use_azuread_auth     = true
  }
}
