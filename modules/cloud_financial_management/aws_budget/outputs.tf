# Outputs for AWS Budgets Module

output "budget_ids" {
  description = "Map of budget key to AWS budget resource ID."
  value       = { for k, v in aws_budgets_budget.budget : k => v.id }
}

output "budget_names" {
  description = "Map of budget key to budget display name."
  value       = { for k, v in aws_budgets_budget.budget : k => v.name }
}

output "budget_types" {
  description = "Map of budget key to budget type (COST, USAGE, RI_UTILIZATION, etc.)."
  value       = { for k, v in aws_budgets_budget.budget : k => v.budget_type }
}

output "budget_limits" {
  description = "Map of budget key to limit_amount (as string)."
  value       = { for k, v in aws_budgets_budget.budget : k => v.limit_amount }
}

output "budget_action_ids" {
  description = "Map of '<budget_key>_<action_key>' to budget action resource ID."
  value       = { for k, v in aws_budgets_budget_action.action : k => v.action_id }
}
