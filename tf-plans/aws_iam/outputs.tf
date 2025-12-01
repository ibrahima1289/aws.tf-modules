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
  value       = null // Removed from output, now stored in Secrets Manager only
}

output "access_key_secrets" {
  description = "Map of user name to secret access key (if created, encrypted if pgp_key is set)."
  value       = null // Removed from output, now stored in Secrets Manager only
  sensitive   = true
}
