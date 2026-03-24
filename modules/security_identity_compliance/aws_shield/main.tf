# Terraform AWS Shield Advanced Module
# This module manages AWS Shield Advanced protections, protection groups,
# DRT (DDoS Response Team) access, and proactive engagement.
# Shield Standard is free and automatic — no Terraform resources are needed for it.
# This module exclusively manages Shield ADVANCED resources.
#
# ⚠️  COST WARNING: aws_shield_subscription incurs a $3,000/month minimum commitment
#     with a 1-year term. enable_subscription is false by default as a safety gate.
#     Only set enable_subscription = true if you intentionally want to enable Shield Advanced.

# Step 1: Optionally create or manage the Shield Advanced subscription.
# Set enable_subscription = true ONLY when you are ready for the $3,000/month commitment.
# Most teams enable Shield Advanced via the console or AWS Organizations and leave
# enable_subscription = false here, managing only protections and groups via Terraform.
resource "aws_shield_subscription" "subscription" {
  count      = var.enable_subscription ? 1 : 0
  auto_renew = var.subscription_auto_renew
}

# Step 2: Create Shield Advanced protection for each AWS resource in the protections list.
# Each protection ties a specific resource ARN (ALB, CloudFront, EIP, Route53, etc.)
# to Shield Advanced monitoring and mitigation.
resource "aws_shield_protection" "protection" {
  for_each     = local.protections_map
  name         = each.value.name
  resource_arn = each.value.resource_arn

  # Step 3: Merge common tags, per-protection tags, and a Name tag.
  tags = merge(local.common_tags, each.value.tags != null ? each.value.tags : {}, {
    Name = each.value.name
  })
}

# Step 4: Optionally group protections for aggregate detection, reporting, and management.
# Supports three patterns: ALL (entire account), BY_RESOURCE_TYPE, or ARBITRARY (explicit list).
resource "aws_shield_protection_group" "group" {
  for_each            = local.protection_groups_map
  protection_group_id = each.value.protection_group_id
  aggregation         = each.value.aggregation
  pattern             = each.value.pattern

  # Step 5: Set resource_type only when pattern = BY_RESOURCE_TYPE.
  resource_type = each.value.pattern == "BY_RESOURCE_TYPE" ? each.value.resource_type : null

  # Step 6: Resolve member_keys to Shield protection ARNs only when pattern = ARBITRARY.
  # member_keys must match keys defined in var.protections.
  members = each.value.pattern == "ARBITRARY" ? [
    for k in coalesce(each.value.member_keys, []) : aws_shield_protection.protection[k].arn
  ] : null

  tags = merge(local.common_tags, each.value.tags != null ? each.value.tags : {}, {
    Name = each.value.protection_group_id
  })
}

# Step 7: Optionally associate an IAM role so the DRT can act on your behalf during attacks.
# The role must trust the Shield service principal: shield.amazonaws.com
resource "aws_shield_drt_access_role_arn_association" "drt_role" {
  count    = var.drt_role_arn != null ? 1 : 0
  role_arn = var.drt_role_arn
}

# Step 8: Optionally grant the DRT read access to S3 log buckets for attack analysis.
# One resource is created per bucket in drt_log_buckets.
# Requires the DRT role association to be in place first.
resource "aws_shield_drt_access_log_bucket_association" "drt_logs" {
  for_each                = var.drt_role_arn != null ? toset(var.drt_log_buckets) : toset([])
  log_bucket              = each.value
  role_arn_association_id = one(aws_shield_drt_access_role_arn_association.drt_role[*].id)
  depends_on              = [aws_shield_drt_access_role_arn_association.drt_role]
}

# Step 9: Optionally enable proactive engagement so the DRT contacts you automatically
# when an attack is detected. Requires at least one emergency contact.
resource "aws_shield_proactive_engagement" "proactive" {
  count   = length(var.emergency_contacts) > 0 ? 1 : 0
  enabled = var.proactive_engagement_enabled

  dynamic "emergency_contact" {
    for_each = var.emergency_contacts
    content {
      email_address = emergency_contact.value.email_address
      phone_number  = emergency_contact.value.phone_number != null ? emergency_contact.value.phone_number : null
      contact_notes = emergency_contact.value.contact_notes != null ? emergency_contact.value.contact_notes : null
    }
  }
}
