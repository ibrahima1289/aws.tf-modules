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
  description = "Map of user name to access key ID (if created). No longer output; see Secrets Manager."
  value       = null
}

output "access_key_secrets" {
  description = "Map of user name to secret access key (if created, encrypted if pgp_key is set). No longer output; see Secrets Manager."
  value       = null
  sensitive   = true
}

output "access_key_secret_arns" {
  description = "Map of user name to the ARN of the AWS Secrets Manager secret storing the access key secret."
  value       = { for k, v in aws_secretsmanager_secret.access_key_secret : k => v.arn }
}
