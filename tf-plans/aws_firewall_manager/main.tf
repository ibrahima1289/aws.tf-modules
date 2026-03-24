# Firewall Manager wrapper plan
# Calls the root module and passes all variables through.
# This wrapper provides a repeatable plan/apply workflow with example tfvars.
module "firewall_manager" {
  source = "../../modules/security_identity_compliance/aws_firwall_manager"

  # Identity and region configuration.
  region               = var.region
  enable_admin_account = var.enable_admin_account
  admin_account_id     = var.admin_account_id

  # Security policy definitions — managed_service_data loaded from policies/*.json via locals.tf.
  policies = local.policies_with_data

  # Merge wrapper-level tags with the auto-generated created_date from locals.tf.
  tags = merge(var.tags, { created_date = local.created_date })
}
