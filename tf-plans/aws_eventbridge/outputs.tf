# Outputs for AWS EventBridge wrapper
# Pass-through of all module outputs.

output "event_bus_arns" {
  description = "Map of bus key to custom event bus ARN."
  value       = module.eventbridge.event_bus_arns
}

output "event_bus_names" {
  description = "Map of bus key to custom event bus name."
  value       = module.eventbridge.event_bus_names
}

output "rule_arns" {
  description = "Map of rule key to EventBridge rule ARN."
  value       = module.eventbridge.rule_arns
}

output "rule_names" {
  description = "Map of rule key to EventBridge rule name."
  value       = module.eventbridge.rule_names
}

output "rule_states" {
  description = "Map of rule key to rule state (ENABLED or DISABLED)."
  value       = module.eventbridge.rule_states
}

output "target_ids" {
  description = "Map of '<rule_key>_<target_key>' to target ID."
  value       = module.eventbridge.target_ids
}

output "archive_arns" {
  description = "Map of archive key to event archive ARN."
  value       = module.eventbridge.archive_arns
}
