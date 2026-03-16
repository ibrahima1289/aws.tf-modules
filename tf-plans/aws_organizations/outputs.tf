# Expose organization ID from module.
output "organization_id" {
  description = "AWS Organizations ID"
  value       = module.organizations.organization_id
}

# Expose root ID from module.
output "root_id" {
  description = "Organizations root ID"
  value       = module.organizations.root_id
}

# Expose OU IDs for downstream usage.
output "organizational_unit_ids" {
  description = "Map of OU key to OU ID"
  value       = module.organizations.organizational_unit_ids
}

# Expose account IDs for downstream usage.
output "account_ids" {
  description = "Map of account key to account ID"
  value       = module.organizations.account_ids
}

# Expose account ARNs for downstream usage.
output "account_arns" {
  description = "Map of account key to account ARN"
  value       = module.organizations.account_arns
}

# Expose policy IDs for downstream usage.
output "policy_ids" {
  description = "Map of policy key to policy ID"
  value       = module.organizations.policy_ids
}
