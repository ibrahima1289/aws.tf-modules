# Outputs for the aws_network_firewall wrapper plan.
# All values are forwarded from the root module outputs.

# ─── Rule Groups ─────────────────────────────────────────────────────────────
output "rule_group_arns" {
  description = "Map of rule group key to ARN."
  value       = module.aws_network_firewall.rule_group_arns
}

output "rule_group_ids" {
  description = "Map of rule group key to resource ID."
  value       = module.aws_network_firewall.rule_group_ids
}

# ─── Firewall Policies ───────────────────────────────────────────────────────
output "policy_arns" {
  description = "Map of policy key to firewall policy ARN."
  value       = module.aws_network_firewall.policy_arns
}

output "policy_ids" {
  description = "Map of policy key to resource ID."
  value       = module.aws_network_firewall.policy_ids
}

# ─── Firewalls ───────────────────────────────────────────────────────────────
output "firewall_arns" {
  description = "Map of firewall key to ARN."
  value       = module.aws_network_firewall.firewall_arns
}

output "firewall_ids" {
  description = "Map of firewall key to resource ID."
  value       = module.aws_network_firewall.firewall_ids
}

# ─── Endpoint IDs ────────────────────────────────────────────────────────────
# Use these vpce-xxx values as route targets in your VPC route tables.
# Format: { firewall_key = { "us-east-1a" = "vpce-xxx", "us-east-1b" = "vpce-yyy" } }
output "firewall_endpoint_ids" {
  description = "AZ-keyed firewall endpoint IDs for route table entries."
  value       = module.aws_network_firewall.firewall_endpoint_ids
}

output "firewall_update_tokens" {
  description = "Map of firewall key to update token (required for in-place modifications)."
  value       = module.aws_network_firewall.firewall_update_tokens
}

output "firewall_statuses" {
  description = "Map of firewall key to configuration sync state."
  value       = module.aws_network_firewall.firewall_statuses
}
