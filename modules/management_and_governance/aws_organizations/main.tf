# Fetch an existing organization when create_organization is false.
data "aws_organizations_organization" "current" {
  count = var.create_organization ? 0 : 1
}

# Create the AWS Organization (management account only) when requested.
resource "aws_organizations_organization" "organization" {
  count = var.create_organization ? 1 : 0

  feature_set                   = var.organization.feature_set
  aws_service_access_principals = var.organization.aws_service_access_principals
  enabled_policy_types          = var.organization.enabled_policy_types
}

# Level-1 OUs: attached directly under the organization root.
resource "aws_organizations_organizational_unit" "organizational_unit_l1" {
  for_each = local.organizational_units_l1_map

  name      = each.value.name
  parent_id = local.root_id

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# Level-2 OUs: nested under a level-1 OU.
# Kept in a separate resource block to avoid a for_each self-reference cycle.
resource "aws_organizations_organizational_unit" "organizational_unit_l2" {
  for_each = local.organizational_units_l2_map

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.organizational_unit_l1[each.value.parent_key].id

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# Create multiple member accounts from var.accounts.
resource "aws_organizations_account" "account" {
  for_each = local.accounts_map

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = each.value.parent_key == "ROOT" ? local.root_id : local.all_ou_ids[each.value.parent_key]
  role_name                  = each.value.role_name
  iam_user_access_to_billing = each.value.iam_user_access_to_billing
  close_on_deletion          = each.value.close_on_deletion

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# Create multiple organization policies (SCP/Tag/Backup/AI opt-out, etc.).
resource "aws_organizations_policy" "policy" {
  for_each = local.policies_map

  name        = each.value.name
  description = each.value.description
  type        = each.value.type
  content     = each.value.content

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# Attach policies to ROOT, OU, or ACCOUNT targets.
resource "aws_organizations_policy_attachment" "policy_attachment" {
  for_each = local.policy_attachments_map

  policy_id = aws_organizations_policy.policy[each.value.policy_key].id
  target_id = each.value.target_type == "ROOT" ? local.root_id : (
    each.value.target_type == "OU" ? local.all_ou_ids[each.value.target_key] :
    aws_organizations_account.account[each.value.target_key].id
  )
}
