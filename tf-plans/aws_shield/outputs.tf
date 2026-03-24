output "protection_ids" {
  description = "Map of protection key to Shield Advanced protection ID."
  value       = module.shield.protection_ids
}

output "protection_arns" {
  description = "Map of protection key to Shield Advanced protection ARN."
  value       = module.shield.protection_arns
}

output "protection_group_ids" {
  description = "Map of group key to Shield Advanced protection group ID."
  value       = module.shield.protection_group_ids
}

output "subscription_id" {
  description = "Shield Advanced subscription ID, or empty string when not managed."
  value       = module.shield.subscription_id
}
