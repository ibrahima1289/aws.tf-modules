# Step 1: Call the reusable AWS Shield Advanced module.
module "shield" {
  source = "../../modules/security_identity_compliance/aws_shield"

  # Step 2: Set region and apply wrapper-level tags merged with created_date.
  # Use us-east-1 when any protected resource is CloudFront or Route 53.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass subscription settings (disabled by default — see variable description).
  enable_subscription     = var.enable_subscription
  subscription_auto_renew = var.subscription_auto_renew

  # Step 4: Pass the list of resource protections to create.
  protections = var.protections

  # Step 5: Pass the list of protection groups.
  protection_groups = var.protection_groups

  # Step 6: Pass optional DRT access configuration.
  drt_role_arn    = var.drt_role_arn
  drt_log_buckets = var.drt_log_buckets

  # Step 7: Pass proactive engagement and emergency contact settings.
  proactive_engagement_enabled = var.proactive_engagement_enabled
  emergency_contacts           = var.emergency_contacts
}
