# Pipeline Operational Guide

## New Infrastructure Change Workflow

1. Create feature branch from develop:
   git checkout develop && git pull
   git checkout -b feature/add-storage-account

2. Make Terraform changes in appropriate module or environment
3. Test locally (optional):
   cd environments/dev
   terraform init && terraform plan -var-file=terraform.tfvars

4. Push and open PR to develop:
   git push origin feature/add-storage-account
   Open PR: feature/add-storage-account -> develop

5. PR triggers: Validate stage (tfsec + Checkov + terraform validate)
   Fix any findings before merging

6. Merge to develop:
   Pipeline triggers: Validate -> Plan -> Apply (auto, no approval)
   Dev infrastructure updated

7. Promote to staging:
   git checkout staging && git merge develop && git push
   Pipeline: Validate -> Plan -> Approve (optional) -> Apply

8. Promote to production:
   git checkout main && git merge staging && git push
   Pipeline: Validate -> Plan -> Approve (MANDATORY) -> Apply

## Approval Process

Production approvals:
- Approvers: designated release approvers (Azure DevOps environment approval list)
- Required information for approval:
  - What infrastructure is changing (Terraform plan summary)
  - Why this change is needed (PR description)
  - Risk assessment (who reviewed and when)
- Timeout: 24 hours -- pipeline expires if not approved
- Approval recorded in Azure DevOps pipeline run history

## Pipeline Failure Response

Validate stage failure:
- Fix tfsec/Checkov findings or add justified suppressions to baseline
- Re-push -- pipeline re-triggers automatically

Plan stage failure:
- Review Terraform error in pipeline logs
- Fix in feature branch, re-test locally, re-push

Apply stage failure (partial apply):
- Do NOT re-run pipeline immediately -- state may be inconsistent
- Review pipeline logs to identify last successful resource
- Run terraform plan locally to assess current state vs desired state
- If state lock stuck: run scripts/unlock-terraform-state.sh
- Fix root cause, then re-run pipeline

## Drift Detection

Scheduled pipeline (weekly): runs terraform plan against all environments
Results in Log Analytics -- query for non-empty plan outputs indicating drift

If drift detected:
1. Identify out-of-band resource modification
2. Determine if change was authorised (emergency fix) or unauthorised
3. If authorised: update Terraform code to reflect change (IaC reconciliation)
4. If unauthorised: investigate as potential security incident
5. Apply correct state through pipeline

## Grafana Dashboards

Access: Grafana instance connected to Log Analytics

Available dashboards:
- Infrastructure Health: resource status across all environments
- Deployment Activity: recent pipeline runs, success rates, environment change frequency
- Cost Monitoring: resource spend by environment and tag

KQL query -- recent deployments:
  AzureDevOpsAuditLogs
  | where TimeGenerated > ago(7d)
  | where OperationType == "Release.ApprovalCompleted"
  | project TimeGenerated, ActorDisplayName, Data
  | order by TimeGenerated desc
