#!/bin/bash
# unlock-terraform-state.sh
# Manually unlocks a stuck Terraform state lock in Azure Blob Storage
#
# Use when: pipeline fails mid-apply and leaves a state lock
# that prevents subsequent pipeline runs from acquiring the lock.
#
# Usage: ./unlock-terraform-state.sh <environment> <storage-account>

set -euo pipefail

ENVIRONMENT="${1:?Environment required: dev, staging, prod}"
STORAGE_ACCOUNT="${2:?Storage account name required}"
CONTAINER="tfstate"
BLOB="infra-${ENVIRONMENT}.tfstate"
LOCK_BLOB="${BLOB}.lock"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

log "=== TERRAFORM STATE LOCK RECOVERY ==="
log "Environment: $ENVIRONMENT | Storage: $STORAGE_ACCOUNT"

# Check if lock exists
LOCK_EXISTS=$(az storage blob exists     --account-name "$STORAGE_ACCOUNT"     --container-name "$CONTAINER"     --name "$LOCK_BLOB"     --auth-mode login     --query exists -o tsv 2>/dev/null || echo "false")

if [ "$LOCK_EXISTS" = "true" ]; then
    log "Lock found: $LOCK_BLOB"

    # Show lock content for investigation
    az storage blob download         --account-name "$STORAGE_ACCOUNT"         --container-name "$CONTAINER"         --name "$LOCK_BLOB"         --file /tmp/tf-lock-info.json         --auth-mode login 2>/dev/null

    log "Lock info:"
    cat /tmp/tf-lock-info.json 2>/dev/null || log "Could not read lock info"

    # Prompt before deletion
    echo ""
    echo "WARNING: Only delete this lock if you are certain no Terraform operation is active."
    read -p "Delete state lock for $ENVIRONMENT? (yes/no): " CONFIRM

    if [ "$CONFIRM" = "yes" ]; then
        az storage blob delete             --account-name "$STORAGE_ACCOUNT"             --container-name "$CONTAINER"             --name "$LOCK_BLOB"             --auth-mode login

        log "State lock deleted for $ENVIRONMENT"
        log "Re-run the pipeline to retry the deployment"
    else
        log "Lock deletion cancelled"
    fi
else
    log "No state lock found for $ENVIRONMENT -- state is not locked"
fi
