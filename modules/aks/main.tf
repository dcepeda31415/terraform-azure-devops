# Module: aks
# AKS cluster -- environment-parameterised

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Placeholder -- extend with AKS resources per environment requirements
# See: aks-application-factory repo for full AKS module implementation

output "placeholder" {
  value = "aks module -- extend per workload requirements"
}
