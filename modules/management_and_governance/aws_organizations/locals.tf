locals {
  # One-time creation date tag value.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Common tags applied everywhere this module supports tags.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Resolve organization/root from newly created org or existing org data source.
  organization_id = var.create_organization ? aws_organizations_organization.organization[0].id : data.aws_organizations_organization.current[0].id
  root_id         = var.create_organization ? aws_organizations_organization.organization[0].roots[0].id : data.aws_organizations_organization.current[0].roots[0].id

  # Convert lists to maps for stable multi-resource for_each handling.
  # Split OUs into two levels to prevent a for_each self-reference cycle in main.tf.
  organizational_units_l1_map = {
    for ou in var.organizational_units : ou.key => ou if ou.parent_key == "ROOT"
  }
  organizational_units_l2_map = {
    for ou in var.organizational_units : ou.key => ou if ou.parent_key != "ROOT"
  }

  # Merged map of all OU IDs for use in account and policy attachment lookups.
  all_ou_ids = merge(
    { for k, v in aws_organizations_organizational_unit.organizational_unit_l1 : k => v.id },
    { for k, v in aws_organizations_organizational_unit.organizational_unit_l2 : k => v.id }
  )

  # Convert accounts and policies lists to maps for for_each.
  accounts_map = {
    for a in var.accounts : a.key => a
  }

  # Policy content can be set inline or loaded from a file in policies/<key>.json.
  # This allows large policies to be maintained separately from the Terraform code.
  policies_map = {
    for p in var.policies : p.key => p
  }

  # Preload policy content from file when not set inline, so main.tf can reference it without a cycle.
  policy_attachments_map = {
    for a in var.policy_attachments : a.key => a
  }
}
