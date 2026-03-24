output "admin_account_id" {
  description = "The AWS account ID registered as the Firewall Manager administrator (populated only when enable_admin_account = true)."
  value       = var.enable_admin_account ? aws_fms_admin_account.admin[0].id : null
}

output "policy_ids" {
  description = "Map of policy name → Firewall Manager policy ID."
  value       = { for k, v in aws_fms_policy.policy : k => v.id }
}

output "policy_arns" {
  description = "Map of policy name → Firewall Manager policy ARN."
  value       = { for k, v in aws_fms_policy.policy : k => v.arn }
}

output "policy_names" {
  description = "List of all created Firewall Manager policy names."
  value       = [for k, v in aws_fms_policy.policy : v.name]
}
