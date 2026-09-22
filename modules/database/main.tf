# Module: database
# Azure SQL with private endpoint -- environment-parameterised

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Placeholder -- extend with Azure SQL resources per environment requirements
# See: multi-tier-cloud-infrastructure repo for full database module implementation

output "placeholder" {
  value = "database module -- extend per workload requirements"
}
