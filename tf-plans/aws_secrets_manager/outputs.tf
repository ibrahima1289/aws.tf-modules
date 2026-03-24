output "secret_ids" {
  description = "Map of secret key to Secrets Manager secret ID."
  value       = module.secrets_manager.secret_ids
}

output "secret_arns" {
  description = "Map of secret key to Secrets Manager secret ARN."
  value       = module.secrets_manager.secret_arns
  sensitive   = true
}

output "secret_names" {
  description = "Map of secret key to Secrets Manager secret name (path)."
  value       = module.secrets_manager.secret_names
}

output "secret_version_ids" {
  description = "Map of secret key to the current version ID (only for secrets with a static string value)."
  value       = module.secrets_manager.secret_version_ids
}

output "rotation_enabled_keys" {
  description = "Sorted list of secret keys that have automatic rotation configured."
  value       = module.secrets_manager.rotation_enabled_keys
}
