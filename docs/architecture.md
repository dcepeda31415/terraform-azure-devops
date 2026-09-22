# Architecture Notes -- Terraform & Azure DevOps IaC Platform

## Repository Structure

Environment directories (not Workspaces):
- environments/dev/   -- dev state, dev service connection, dev variables
- environments/staging/ -- staging state, staging service connection
- environments/prod/  -- prod state, prod service connection (pipeline only)

Modules directory:
- modules/ -- shared, parameterised modules consumed by all environments
- Module versioning: environments reference modules via relative path (local dev)
  In production: pin to Git tags for version stability

## Service Connection Configuration (Workload Identity Federation)

Each environment requires a dedicated Azure DevOps service connection configured with OIDC.

Configuration steps per environment:
1. Azure portal > Entra ID > App Registrations > New registration
2. Add federated credential: Azure DevOps pipeline (OIDC)
   - Issuer: https://vstoken.dev.azure.com/<org>
   - Subject: sc://<org>/<project>/<service-connection-name>
3. Azure RBAC: assign Contributor on environment resource group
4. Azure Blob Storage: assign Storage Blob Data Contributor on environment state account
5. Azure DevOps: create service connection using App Registration + OIDC

No client secrets stored anywhere -- all authentication via short-lived OIDC tokens.

## Variable Groups

Each environment has a corresponding Azure DevOps variable group:
- dev-variables: non-sensitive dev configuration
- staging-variables: non-sensitive staging configuration
- prod-variables: non-sensitive prod configuration

Sensitive values (passwords, API keys) stored in Key Vault:
- Azure DevOps Key Vault variable group links to Key Vault
- Pipeline retrieves secrets at runtime -- never stored in pipeline variables
- Key Vault access: pipeline service connection Managed Identity has Get/List secrets

## Pipeline Plan Artifact Governance

Why plan artifacts matter:
- terraform plan at Time T produces output X
- Between T and apply execution, infrastructure state may change
- Generating new plan at apply time may produce output Y != X
- Reviewer approved X but Y is applied -- approval bypass

Solution: publish plan as artifact at Plan stage, download at Apply stage.
The apply stage MUST use the published artifact -- never generate a new plan.

Verify in pipeline YAML:
  Apply stage: download artifact from Plan stage
  Apply command: terraform apply <artifact-path>/tfplan
  NOT: terraform plan && terraform apply

## Security Scanning Configuration

tfsec false positive suppression:
  Create .tfsec/config.yml to define rule ignores for known false positives.
  Example:
    exclude:
      - AVD-AZU-0012  # Reason: accepted risk for this specific resource

Checkov baseline:
  Run: checkov -d . --framework terraform --create-baseline
  Creates: .checkov.baseline file with current false positive set
  Commit baseline file -- future runs only alert on new findings

Review baseline quarterly -- remove suppressed items that are now fixed.

## State Backend Security

Storage account access controls:
- Default action: Deny (no anonymous access)
- Bypass: AzureServices (required for some platform operations)
- RBAC: each environment SP has Storage Blob Data Contributor on its own account only
- No cross-environment state access possible

State versioning: enabled -- previous state versions recoverable if current state corrupted
Soft delete: enabled -- deleted state blobs recoverable within 30-day retention window

## Azure Policy Assignment

Deploy policies from policies/ directory via Azure CLI or Terraform:

  az policy definition create \
    --name "require-tls12" \
    --rules @policies/require-tls12.json \
    --subscription <sub-id>

  az policy assignment create \
    --name "require-tls12-assignment" \
    --policy "require-tls12" \
    --scope /subscriptions/<sub-id>

Policy effects:
- Deny: blocks deployment of non-compliant resources immediately
- DeployIfNotExists: deploys required configurations after resource creation (async)
- Audit: logs non-compliance without blocking (use for initial assessment)

Note: DeployIfNotExists has async remediation timing -- Terraform apply may complete before
policy remediation runs. Explicitly configure required settings in Terraform rather than
relying on Policy remediation for Terraform-managed resources.
