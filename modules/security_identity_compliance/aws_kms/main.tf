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
  for_each                           = local.resolved_keys
  description                        = each.value.description != null ? each.value.description : "Managed by Terraform"
  key_usage                          = each.value.key_usage
  customer_master_key_spec           = each.value.key_spec
  policy                             = each.value.policy_json
  deletion_window_in_days            = each.value.deletion_window_in_days != null ? each.value.deletion_window_in_days : 10
  enable_key_rotation                = each.value.enable_key_rotation
  is_enabled                         = each.value.is_enabled != null ? each.value.is_enabled : true
  multi_region                       = each.value.multi_region != null ? each.value.multi_region : false
  bypass_policy_lockout_safety_check = each.value.bypass_policy_lockout_safety_check != null ? each.value.bypass_policy_lockout_safety_check : false
  tags = merge(var.tags, each.value.tags != null ? each.value.tags : {}, {
    created_date = local.created_date,
    Name         = each.value.name
  })
}

# Optional aliases for keys
resource "aws_kms_alias" "alias" {
  for_each      = { for k, v in local.resolved_keys : k => v if v.aliases != null && length(v.aliases) > 0 }
  name          = format("alias/%s", each.value.aliases[0])
  target_key_id = aws_kms_key.key[each.key].key_id
}

# Optional: multiple aliases per key (if provided)
# We create additional alias resources beyond the first alias above
resource "aws_kms_alias" "alias_additional" {
  # Build a map of additional aliases (beyond the first) keyed by "key_name|alias"
  for_each = {
    for pair in flatten([
      for k, v in local.resolved_keys : [
        for a in slice(v.aliases, 1, length(v.aliases)) : {
          key_name = k
          alias    = a
        }
      ]
      if v.aliases != null && length(v.aliases) > 1
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
