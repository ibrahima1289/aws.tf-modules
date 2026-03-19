# Step 1: Expose NACL IDs created by the module.
output "nacl_ids" {
  description = "Map of NACL key to NACL ID"
  value       = module.nacl.nacl_ids
}

# Step 2: Expose NACL ARNs created by the module.
output "nacl_arns" {
  description = "Map of NACL key to NACL ARN"
  value       = module.nacl.nacl_arns
}

# Step 3: Expose subnet association IDs.
output "association_ids" {
  description = "Map of association key to association ID"
  value       = module.nacl.association_ids
}

# Step 4: Expose rule keys for verification.
output "ingress_rule_keys" {
  description = "List of ingress rule keys"
  value       = module.nacl.ingress_rule_keys
}

output "egress_rule_keys" {
  description = "List of egress rule keys"
  value       = module.nacl.egress_rule_keys
}
