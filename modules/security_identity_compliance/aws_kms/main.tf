# Terraform AWS KMS Module
# This module creates AWS KMS keys with comprehensive configuration and tagging.
# It supports:
# - Symmetric and asymmetric keys
# - Key rotation (for symmetric keys)
# - Custom key policies
# - Aliases
# - Grants
# - Multi-region keys
# - Importing key material (placeholders for advanced workflows)

# Data source example (optional): current account context
# data "aws_caller_identity" "current" {}

# Create one or more KMS keys based on user input
# Each entry in var.keys defines a key and its settings
resource "aws_kms_key" "key" {
  for_each                           = { for k in var.keys : k.name => k }
  description                        = lookup(each.value, "description", "Managed by Terraform")
  key_usage                          = lookup(each.value, "key_usage", "ENCRYPT_DECRYPT")
  customer_master_key_spec           = lookup(each.value, "key_spec", "SYMMETRIC_DEFAULT")
  policy                             = lookup(each.value, "policy_json", null)
  deletion_window_in_days            = lookup(each.value, "deletion_window_in_days", 10)
  enable_key_rotation                = lookup(each.value, "enable_key_rotation", false)
  is_enabled                         = lookup(each.value, "is_enabled", true)
  multi_region                       = lookup(each.value, "multi_region", false)
  bypass_policy_lockout_safety_check = lookup(each.value, "bypass_policy_lockout_safety_check", false)
  tags = merge(var.tags, lookup(each.value, "tags", {}), {
    created_date = local.created_date,
    Name         = each.value.name
  })
}

# Optional aliases for keys
resource "aws_kms_alias" "alias" {
  for_each      = { for k in var.keys : k.name => k if contains(keys(k), "aliases") && length(k.aliases) > 0 }
  name          = format("alias/%s", each.value.aliases[0])
  target_key_id = aws_kms_key.key[each.key].key_id
}

# Optional: multiple aliases per key (if provided)
# We create additional alias resources beyond the first alias above
resource "aws_kms_alias" "alias_additional" {
  # Build a map of additional aliases (beyond the first) keyed by "key_name|alias"
  for_each = {
    for pair in flatten([
      for k in var.keys : [
        for a in slice(lookup(k, "aliases", []), 1, length(lookup(k, "aliases", []))) : {
          key_name = k.name
          alias    = a
        }
      ]
      if contains(keys(k), "aliases") && length(k.aliases) > 1
    ]) : format("%s|%s", pair.key_name, pair.alias) => pair
  }
  name          = format("alias/%s", each.value.alias)
  target_key_id = aws_kms_key.key[each.value.key_name].key_id
  depends_on    = [aws_kms_alias.alias]
}

# Optional grants to principals for specific operations
resource "aws_kms_grant" "grant" {
  for_each          = { for g in var.grants : format("%s|%s", g.key_name, g.name) => g }
  name              = each.value.name
  key_id            = aws_kms_key.key[each.value.key_name].key_id
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations
  constraints {
    encryption_context_equals = lookup(each.value, "encryption_context_equals", null)
    encryption_context_subset = lookup(each.value, "encryption_context_subset", null)
  }
  retiring_principal = lookup(each.value, "retiring_principal", null)
}
