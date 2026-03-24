# Outputs for AWS Network Firewall Module

# ─── Rule Groups ─────────────────────────────────────────────────────────────

output "rule_group_arns" {
  description = "Map of rule group key to ARN."
  value       = { for k, v in aws_networkfirewall_rule_group.rule_group : k => v.arn }
}

output "rule_group_ids" {
  description = "Map of rule group key to resource ID (same as ARN)."
  value       = { for k, v in aws_networkfirewall_rule_group.rule_group : k => v.id }
}

# ─── Firewall Policies ───────────────────────────────────────────────────────

output "policy_arns" {
  description = "Map of policy key to firewall policy ARN."
  value       = { for k, v in aws_networkfirewall_firewall_policy.policy : k => v.arn }
}

output "policy_ids" {
  description = "Map of policy key to resource ID."
  value       = { for k, v in aws_networkfirewall_firewall_policy.policy : k => v.id }
}

# ─── Firewalls ───────────────────────────────────────────────────────────────

output "firewall_arns" {
  description = "Map of firewall key to firewall ARN."
  value       = { for k, v in aws_networkfirewall_firewall.firewall : k => v.arn }
}

output "firewall_ids" {
  description = "Map of firewall key to resource ID (same as ARN)."
  value       = { for k, v in aws_networkfirewall_firewall.firewall : k => v.id }
}

# The update_token is required when making in-place policy or subnet changes
# to an already-deployed firewall. Reference this in subsequent firewall updates.
output "firewall_update_tokens" {
  description = "Map of firewall key to update token (required for in-place modifications)."
  value       = { for k, v in aws_networkfirewall_firewall.firewall : k => v.update_token }
}

# ─── Firewall Endpoint IDs ────────────────────────────────────────────────────
# Endpoint IDs are the VPC endpoint identifiers created in each firewall subnet.
# These values must be referenced in VPC route tables to route traffic through
# the firewall. Format: { firewall_key = { "us-east-1a" = "vpce-xxx..." } }

output "firewall_endpoint_ids" {
  description = "Map of firewall key to AZ-keyed map of firewall endpoint IDs. Use these in route table entries to direct traffic through the firewall."
  value = {
    for fw_key, fw in aws_networkfirewall_firewall.firewall : fw_key => {
      for ss in tolist(fw.firewall_status[0].sync_states) :
      ss.availability_zone => ss.attachment[0].endpoint_id
    }
  }
}

# ─── Firewall Status ─────────────────────────────────────────────────────────

output "firewall_statuses" {
  description = "Map of firewall key to AZ-keyed attachment status (READY / CREATING / DELETING / FAILED)."
  value = {
    for fw_key, fw in aws_networkfirewall_firewall.firewall : fw_key => {
      for ss in tolist(fw.firewall_status[0].sync_states) :
      ss.availability_zone => ss.attachment[0].status
    }
  }
}
