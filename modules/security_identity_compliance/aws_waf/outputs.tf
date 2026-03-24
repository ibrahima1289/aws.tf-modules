# Outputs for AWS WAF v2 Module

output "web_acl_ids" {
  description = "Map of Web ACL key to Web ACL resource ID."
  value       = { for k, v in aws_wafv2_web_acl.web_acl : k => v.id }
}

output "web_acl_arns" {
  description = "Map of Web ACL key to Web ACL ARN. Use this to set web_acl_id on aws_cloudfront_distribution for CLOUDFRONT-scoped ACLs."
  value       = { for k, v in aws_wafv2_web_acl.web_acl : k => v.arn }
}

output "web_acl_capacity" {
  description = "Map of Web ACL key to WCU (Web ACL Capacity Units) consumed. Maximum default quota is 1500 WCU per Web ACL."
  value       = { for k, v in aws_wafv2_web_acl.web_acl : k => v.capacity }
}

output "ip_set_ids" {
  description = "Map of IP set key to IP set resource ID."
  value       = { for k, v in aws_wafv2_ip_set.ip_set : k => v.id }
}

output "ip_set_arns" {
  description = "Map of IP set key to IP set ARN."
  value       = { for k, v in aws_wafv2_ip_set.ip_set : k => v.arn }
}

output "regex_pattern_set_ids" {
  description = "Map of regex pattern set key to resource ID."
  value       = { for k, v in aws_wafv2_regex_pattern_set.regex_pattern_set : k => v.id }
}

output "regex_pattern_set_arns" {
  description = "Map of regex pattern set key to resource ARN."
  value       = { for k, v in aws_wafv2_regex_pattern_set.regex_pattern_set : k => v.arn }
}
