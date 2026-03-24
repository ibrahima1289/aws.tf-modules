# Terraform AWS Firewall Manager Module
# Manages FMS administrator-account designation and security policies across an AWS Organization.
# Firewall Manager requires AWS Organizations and must be operated from the management account
# or a delegated administrator account.
#
# ⚠️  COST WARNING: Each active FMS policy costs $100/month per region, per policy.
#     enable_admin_account is false by default as a safety gate.
#     Only set enable_admin_account = true when you are ready to assume FMS administration.

# Step 1: Optionally designate the Firewall Manager administrator account.
# This should be configured only once per organization — either here or via the console.
# Requires the AWS Organizations management account (or a delegated administrator).
resource "aws_fms_admin_account" "admin" {
  count      = var.enable_admin_account ? 1 : 0
  account_id = var.admin_account_id # null → defaults to the current caller account
}

# Step 2: Build a name-keyed map from the policies list to drive for_each creation.
# Using for_each (over count) allows individual policies to be added, updated,
# or deleted without disturbing sibling policies in the same plan/apply cycle.

# Step 3: Create each Firewall Manager security policy declared in var.policies.
# Supported policy types: WAF, WAFV2, SHIELD_ADVANCED, SECURITY_GROUPS_COMMON,
# SECURITY_GROUPS_AUDIT, NETWORK_FIREWALL, DNS_FIREWALL, THIRD_PARTY_FIREWALL,
# NETWORK_ACL_COMMON.
resource "aws_fms_policy" "policy" {
  for_each = local.policies_map

  # Step 4: Core identity and enforcement flags.
  name                               = each.value.name
  description                        = each.value.description
  exclude_resource_tags              = each.value.exclude_resource_tags
  remediation_enabled                = each.value.remediation_enabled
  delete_unused_fm_managed_resources = each.value.delete_unused_fm_managed_resources

  # Step 5: Define the resource types this policy manages.
  # Use resource_type for single-type policies (e.g., AWS::EC2::VPC for Network Firewall /
  # DNS Firewall), or resource_type_list for multi-type policies (e.g., Shield Advanced
  # spanning ALBs + EIPs + CloudFront distributions). Both fields are mutually exclusive.
  resource_type      = each.value.resource_type
  resource_type_list = each.value.resource_type_list

  # Step 6: Optionally scope the policy to resources bearing specific tags.
  # When exclude_resource_tags = false, only tagged resources are in scope;
  # when true, tagged resources are excluded from scope.
  resource_tags = each.value.resource_tags

  # Step 7: Define the security service type and its JSON-encoded configuration payload.
  # managed_service_data carries the full rule/ACL/rule-group definition for the chosen type
  # (e.g., WAFv2 preProcessRuleGroups, Shield Advanced automatic-response settings).
  security_service_policy_data {
    type                 = each.value.security_service_type
    managed_service_data = each.value.managed_service_data
  }

  # Step 8: Optionally restrict the policy scope to specific AWS accounts or OUs to INCLUDE.
  # The dynamic block is omitted entirely when both lists are empty, keeping the API payload clean.
  dynamic "include_map" {
    for_each = (
      length(coalesce(each.value.include_map_accounts, [])) > 0 ||
      length(coalesce(each.value.include_map_orgunits, [])) > 0
    ) ? [1] : []
    content {
      account = length(coalesce(each.value.include_map_accounts, [])) > 0 ? each.value.include_map_accounts : null
      orgunit = length(coalesce(each.value.include_map_orgunits, [])) > 0 ? each.value.include_map_orgunits : null
    }
  }

  # Step 9: Optionally exempt specific AWS accounts or OUs from this policy's scope (EXCLUDE).
  # The dynamic block is omitted entirely when both lists are empty.
  dynamic "exclude_map" {
    for_each = (
      length(coalesce(each.value.exclude_map_accounts, [])) > 0 ||
      length(coalesce(each.value.exclude_map_orgunits, [])) > 0
    ) ? [1] : []
    content {
      account = length(coalesce(each.value.exclude_map_accounts, [])) > 0 ? each.value.exclude_map_accounts : null
      orgunit = length(coalesce(each.value.exclude_map_orgunits, [])) > 0 ? each.value.exclude_map_orgunits : null
    }
  }

  # Step 10: Tag every policy with per-policy tags merged with common_tags and a Name tag.
  tags = merge(local.common_tags, each.value.tags != null ? each.value.tags : {}, {
    Name = each.value.name
  })

  # Step 11: Ensure the FMS admin account registration completes before any policy is created.
  depends_on = [aws_fms_admin_account.admin]
}
