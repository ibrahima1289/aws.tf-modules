output "admin_account_id" {
  description = "The AWS account ID registered as the Firewall Manager administrator (populated only when enable_admin_account = true)."
  value       = module.firewall_manager.admin_account_id
}

output "policy_ids" {
  description = "Map of policy name → Firewall Manager policy ID."
  value       = module.firewall_manager.policy_ids
}

output "policy_arns" {
  description = "Map of policy name → Firewall Manager policy ARN."
  value       = module.firewall_manager.policy_arns
}

output "policy_names" {
  description = "List of all created Firewall Manager policy names."
  value       = module.firewall_manager.policy_names
}
