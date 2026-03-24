# ── Web ACL IDs ────────────────────────────────────────────────────────────────

output "web_acl_ids" {
  description = "Map of Web ACL key to Web ACL resource ID."
  value       = module.waf.web_acl_ids
}

output "web_acl_arns" {
  description = "Map of Web ACL key to Web ACL ARN. Use for aws_cloudfront_distribution.web_acl_id (CLOUDFRONT scope)."
  value       = module.waf.web_acl_arns
}

output "web_acl_capacity" {
  description = "Map of Web ACL key to WCU (Web ACL Capacity Units) consumed. Maximum default is 1500 WCU per Web ACL."
  value       = module.waf.web_acl_capacity
}

# ── IP Set Outputs ──────────────────────────────────────────────────────────────

output "ip_set_ids" {
  description = "Map of IP set key to IP set resource ID."
  value       = module.waf.ip_set_ids
}

output "ip_set_arns" {
  description = "Map of IP set key to IP set ARN."
  value       = module.waf.ip_set_arns
}

# ── Regex Pattern Set Outputs ──────────────────────────────────────────────────

output "regex_pattern_set_ids" {
  description = "Map of regex pattern set key to resource ID."
  value       = module.waf.regex_pattern_set_ids
}

output "regex_pattern_set_arns" {
  description = "Map of regex pattern set key to resource ARN."
  value       = module.waf.regex_pattern_set_arns
}
