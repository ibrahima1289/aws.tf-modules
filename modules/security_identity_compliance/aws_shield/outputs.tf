# Outputs for AWS Shield Advanced Module

output "protection_ids" {
  description = "Map of protection key to Shield Advanced protection resource ID."
  value       = { for k, v in aws_shield_protection.protection : k => v.id }
}

output "protection_arns" {
  description = "Map of protection key to Shield Advanced protection ARN."
  value       = { for k, v in aws_shield_protection.protection : k => v.arn }
}

output "protection_group_ids" {
  description = "Map of protection group key to protection group ID."
  value       = { for k, v in aws_shield_protection_group.group : k => v.protection_group_id }
}

output "subscription_id" {
  description = "Shield Advanced subscription resource ID. Null when enable_subscription = false."
  value       = var.enable_subscription ? aws_shield_subscription.subscription[0].id : null
}
