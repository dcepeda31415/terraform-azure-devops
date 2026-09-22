# Module: compute
# VMSS and Load Balancer -- environment-parameterised

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Placeholder -- extend with VMSS and LB resources per environment requirements
# See: multi-tier-cloud-infrastructure repo for full VMSS module implementation

output "placeholder" {
  value = "compute module -- extend per workload requirements"
}
