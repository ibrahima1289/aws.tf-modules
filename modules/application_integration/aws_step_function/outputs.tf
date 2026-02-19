// Outputs for AWS Step Functions module

output "state_machine_arns" {
  description = "Map of state machine keys to their ARNs."
  value       = { for k, sm in aws_sfn_state_machine.step_function : k => sm.arn }
}

output "state_machine_names" {
  description = "Map of state machine keys to their names."
  value       = { for k, sm in aws_sfn_state_machine.step_function : k => sm.name }
}

output "state_machine_ids" {
  description = "Map of state machine keys to their IDs."
  value       = { for k, sm in aws_sfn_state_machine.step_function : k => sm.id }
}
