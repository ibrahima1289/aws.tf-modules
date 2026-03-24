output "budget_ids" {
  description = "Map of budget key to AWS budget resource ID."
  value       = module.budget.budget_ids
}

output "budget_names" {
  description = "Map of budget key to budget display name."
  value       = module.budget.budget_names
}

output "budget_types" {
  description = "Map of budget key to budget type."
  value       = module.budget.budget_types
}

output "budget_limits" {
  description = "Map of budget key to limit_amount."
  value       = module.budget.budget_limits
}

output "budget_action_ids" {
  description = "Map of '<budget_key>_<action_key>' to budget action ID."
  value       = module.budget.budget_action_ids
}
