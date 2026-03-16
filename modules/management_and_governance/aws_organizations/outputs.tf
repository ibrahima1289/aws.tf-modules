# Organization ID used by this module.
output "organization_id" {
  description = "AWS Organizations ID"
  value       = local.organization_id
}

# Root ID used for top-level OU/account placement and ROOT policy attachments.
output "root_id" {
  description = "AWS Organizations root ID"
  value       = local.root_id
}

# OU IDs keyed by user-provided OU key.
output "organizational_unit_ids" {
  description = "Map of organizational unit key to OU ID"
  value       = local.all_ou_ids
}

# Account IDs keyed by user-provided account key.
output "account_ids" {
  description = "Map of account key to AWS account ID"
  value       = { for k, a in aws_organizations_account.account : k => a.id }
}

# Account ARNs keyed by user-provided account key.
output "account_arns" {
  description = "Map of account key to AWS account ARN"
  value       = { for k, a in aws_organizations_account.account : k => a.arn }
}

# Policy IDs keyed by user-provided policy key.
output "policy_ids" {
  description = "Map of policy key to policy ID"
  value       = { for k, p in aws_organizations_policy.policy : k => p.id }
}
