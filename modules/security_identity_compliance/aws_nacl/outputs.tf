# Map of NACL keys to NACL IDs.
output "nacl_ids" {
  description = "Map of NACL key to NACL ID"
  value       = { for k, v in aws_network_acl.nacl : k => v.id }
}

# Map of NACL keys to NACL ARNs.
output "nacl_arns" {
  description = "Map of NACL key to NACL ARN"
  value       = { for k, v in aws_network_acl.nacl : k => v.arn }
}

# Map of subnet association keys to association IDs.
output "association_ids" {
  description = "Map of association key to network ACL association ID"
  value       = { for k, v in aws_network_acl_association.association : k => v.id }
}

# Keys for rules created by this module.
output "ingress_rule_keys" {
  description = "Keys for all ingress rules created"
  value       = concat(keys(aws_network_acl_rule.ingress_ipv4), keys(aws_network_acl_rule.ingress_ipv6))
}

output "egress_rule_keys" {
  description = "Keys for all egress rules created"
  value       = concat(keys(aws_network_acl_rule.egress_ipv4), keys(aws_network_acl_rule.egress_ipv6))
}
