output "user_names" {
  description = "List of created IAM user names."
  value       = [for u in aws_iam_user.user : u.name]
}

output "group_names" {
  description = "List of created IAM group names."
  value       = [for g in aws_iam_group.group : g.name]
}

output "policy_arns" {
  description = "List of created IAM policy ARNs."
  value       = [for p in aws_iam_policy.policy : p.arn]
}

output "access_key_ids" {
  description = "Map of user name to access key ID (if created)."
  value       = { for k, v in aws_iam_access_key.user_key : k => v.id }
}

output "access_key_secrets" {
  description = "Map of user name to secret access key (if created, encrypted if pgp_key is set)."
  value       = { for k, v in aws_iam_access_key.user_key : k => v.secret }
  sensitive   = true
}

output "console_passwords" {
  description = "Map of user name to encrypted console password (if console access is enabled and pgp_key is set)."
  value       = { for k, v in aws_iam_user_login_profile.user_console : k => v.encrypted_password }
  sensitive   = true
}
