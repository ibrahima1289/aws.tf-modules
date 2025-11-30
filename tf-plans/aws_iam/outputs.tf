output "user_names" {
  description = "List of created IAM user names."
  value       = module.iam.user_names
}

output "group_names" {
  description = "List of created IAM group names."
  value       = module.iam.group_names
}

output "policy_arns" {
  description = "List of created IAM policy ARNs."
  value       = module.iam.policy_arns
}

output "access_key_ids" {
  description = "Map of user name to access key ID (if created)."
  value       = module.iam.access_key_ids
}

output "access_key_secrets" {
  description = "Map of user name to secret access key (if created, encrypted if pgp_key is set)."
  value       = module.iam.access_key_secrets
  sensitive   = true
}

output "console_passwords" {
  description = "Map of user name to encrypted console password (if console access is enabled and pgp_key is set)."
  value       = module.iam.console_passwords
  sensitive   = true
}
