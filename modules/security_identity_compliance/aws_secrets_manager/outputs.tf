# Outputs for AWS Secrets Manager Module

output "secret_ids" {
  description = "Map of secret key to Secrets Manager secret ID."
  value       = { for k, v in aws_secretsmanager_secret.secret : k => v.id }
}

output "secret_arns" {
  description = "Map of secret key to Secrets Manager secret ARN."
  value       = { for k, v in aws_secretsmanager_secret.secret : k => v.arn }
  sensitive   = true
}

output "secret_names" {
  description = "Map of secret key to Secrets Manager secret name (path)."
  value       = { for k, v in aws_secretsmanager_secret.secret : k => v.name }
}

output "secret_version_ids" {
  description = "Map of secret key to the current version ID (only for secrets with a static string value)."
  value       = { for k, v in aws_secretsmanager_secret_version.value : k => v.version_id }
}

output "rotation_enabled_keys" {
  description = "Sorted list of secret keys that have automatic rotation configured."
  value       = local.rotation_enabled_keys
}
