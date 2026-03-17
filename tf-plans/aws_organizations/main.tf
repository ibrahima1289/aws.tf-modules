# Call the reusable AWS Organizations module.
module "organizations" {
  source = "../../modules/management_and_governance/aws_organizations"

  # Step 1: Set the deployment region.
  region = var.region

  # Step 2: Create a new org or adopt existing org safely.
  create_organization = var.create_organization
  organization        = var.organization

  # Step 3: Apply common tags with wrapper-level created_date stamp.
  tags = merge(var.tags, { created_date = local.created_date })

  # Step 4: Scale out OUs, accounts, policies, and policy attachments.
  organizational_units = var.organizational_units
  accounts             = var.accounts
  # Policy content is loaded from policies/<key>.json when not set inline.
  policies           = local.policies_with_content
  policy_attachments = var.policy_attachments
}
