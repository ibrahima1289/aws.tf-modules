module "iam" {
  source = "../../modules/security_identity_compliance/aws_iam"

  region                   = var.region
  users                    = var.users
  groups                   = var.groups
  user_group_memberships   = var.user_group_memberships
  policies                 = var.policies
  group_policy_attachments = var.group_policy_attachments
  tags                     = merge(var.tags, { created_date = local.created_date })
}
