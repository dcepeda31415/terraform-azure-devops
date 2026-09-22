#!/bin/bash
# bootstrap-state-backend.sh
# Creates Azure Blob Storage state backends for all environments
# Run once before first Terraform deployment
#
# Usage: ./bootstrap-state-backend.sh <subscription-id> <location>

set -euo pipefail

SUBSCRIPTION_ID="${1:?Subscription ID required}"
LOCATION="${2:-westeurope}"
STATE_RG="rg-tfstate"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

log "=== TERRAFORM STATE BACKEND BOOTSTRAP ==="
log "Subscription: $SUBSCRIPTION_ID | Location: $LOCATION"

az account set --subscription "$SUBSCRIPTION_ID"

# Create state resource group
log "Creating state resource group: $STATE_RG"
az group create --name "$STATE_RG" --location "$LOCATION" --tags managed_by=terraform project=infrastructure-automation environment=shared

for ENV in dev staging prod; do
    STORAGE_ACCOUNT="stgtfstate${ENV}"
    log "Creating state backend for: $ENV ($STORAGE_ACCOUNT)"

    # Create storage account
    az storage account create         --name "$STORAGE_ACCOUNT"         --resource-group "$STATE_RG"         --location "$LOCATION"         --sku Standard_LRS         --kind StorageV2         --min-tls-version TLS1_2         --allow-blob-public-access false         --tags environment="$ENV" managed_by=terraform project=infrastructure-automation

    # Enable versioning for state recovery
    az storage account blob-service-properties update         --account-name "$STORAGE_ACCOUNT"         --resource-group "$STATE_RG"         --enable-versioning true         --enable-delete-retention true         --delete-retention-days 30

    # Create state container
    az storage container create         --name tfstate         --account-name "$STORAGE_ACCOUNT"         --auth-mode login

    log "State backend ready: $STORAGE_ACCOUNT/tfstate"
done

log "=== BOOTSTRAP COMPLETE ==="
log "Configure Azure DevOps service connections with OIDC (Workload Identity Federation)"
log "Grant each SP 'Storage Blob Data Contributor' on its environment storage account only"
