# Security Scanning False Positive Management

## Why This Matters

Security scanning tools (tfsec, Checkov) generate false positives -- findings that flag
configurations which are intentional and appropriate for the specific context.

Without active false positive management:
- Engineers begin ignoring ALL scanner findings
- Genuine security issues hidden in noise
- Scanner becomes a rubber stamp rather than a control

Goal: suppress known false positives with justification, keep signal for genuine findings.

## tfsec False Positive Suppression

File: .tfsec/config.yml (commit to repository)

Format:
  exclude:
    - rule_id    # Justification: <reason this is intentional>

Example:
  exclude:
    - AVD-AZU-0012  # Justification: public access intentionally enabled for CDN origin
    - AVD-AZU-0048  # Justification: storage account used for public static website

Per-resource suppression (inline):
  resource "azurerm_storage_account" "public_cdn" {
    # tfsec:ignore:AVD-AZU-0012
    allow_blob_public_access = true
  }

## Checkov False Positive Suppression

Baseline file approach (preferred for bulk suppression):
  checkov -d . --framework terraform --create-baseline
  Generates: .checkov.baseline
  Commit this file -- future runs compare against baseline

Per-resource inline suppression:
  resource "azurerm_storage_account" "public_cdn" {
    # checkov:skip=CKV_AZURE_33:Public access required for CDN origin
    allow_blob_public_access = true
  }

## Quarterly Review Checklist

- [ ] Review all active suppressions -- are they still justified?
- [ ] Remove suppressions for findings that have been fixed
- [ ] Check for new tfsec/Checkov rule releases -- new rules may surface existing issues
- [ ] Review baseline file -- remove items that no longer apply
- [ ] Document changes to suppressions in PR description
- [ ] Validate scanner version is current (outdated scanners miss new vulnerability patterns)
