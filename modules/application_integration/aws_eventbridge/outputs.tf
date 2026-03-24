# Outputs for AWS EventBridge Module

output "event_bus_arns" {
  description = "Map of bus key to custom event bus ARN."
  value       = { for k, v in aws_cloudwatch_event_bus.bus : k => v.arn }
}

output "event_bus_names" {
  description = "Map of bus key to custom event bus name."
  value       = { for k, v in aws_cloudwatch_event_bus.bus : k => v.name }
}

output "rule_arns" {
  description = "Map of rule key to EventBridge rule ARN."
  value       = { for k, v in aws_cloudwatch_event_rule.rule : k => v.arn }
}

output "rule_names" {
  description = "Map of rule key to EventBridge rule name."
  value       = { for k, v in aws_cloudwatch_event_rule.rule : k => v.name }
}

output "rule_states" {
  description = "Map of rule key to rule state (ENABLED or DISABLED)."
  value       = { for k, v in aws_cloudwatch_event_rule.rule : k => v.state }
}

output "target_ids" {
  description = "Map of '<rule_key>_<target_key>' to EventBridge target ID."
  value       = { for k, v in aws_cloudwatch_event_target.target : k => v.target_id }
}

output "archive_arns" {
  description = "Map of archive key to event archive ARN."
  value       = { for k, v in aws_cloudwatch_event_archive.archive : k => v.arn }
}
