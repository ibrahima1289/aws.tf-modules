# Expose module outputs at the wrapper level

output "state_machine_arns" {
  value       = module.step_function.state_machine_arns
  description = "Map of state machine key to ARN"
}

output "state_machine_names" {
  value       = module.step_function.state_machine_names
  description = "Map of state machine key to name"
}

output "state_machine_ids" {
  value       = module.step_function.state_machine_ids
  description = "Map of state machine key to ID"
}
