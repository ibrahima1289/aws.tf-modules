output "key_ids" {
  description = "Map of key name to KMS key ID from module."
  value       = module.aws_kms.key_ids
}

output "key_arns" {
  description = "Map of key name to KMS key ARN from module."
  value       = module.aws_kms.key_arns
}

output "alias_names" {
  description = "Map of key name to primary alias name from module."
  value       = module.aws_kms.alias_names
}

output "all_aliases" {
  description = "Map of key name to all alias names from module."
  value       = module.aws_kms.all_aliases
}
