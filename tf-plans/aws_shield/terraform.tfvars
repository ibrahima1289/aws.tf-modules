# ─────────────────────────────────────────────────────────────
# AWS Region
# Shield Advanced subscription and all resources are global,
# but the Terraform AWS provider must target a single region.
# Use us-east-1 when protecting CloudFront distributions or
# Route 53 hosted zones.
# ─────────────────────────────────────────────────────────────
region = "us-east-1"

# ─────────────────────────────────────────────────────────────
# Global Tags
# ─────────────────────────────────────────────────────────────
tags = {
  environment = "production"
  team        = "platform"
  project     = "shield-advanced"
  managed_by  = "terraform"
}

# ─────────────────────────────────────────────────────────────
# Shield Advanced Subscription
# WARNING: Setting enable_subscription = true activates a
# $3,000 / month commitment (billed annually, $36,000/year).
# The subscription is NOT cancelled automatically on destroy
# unless auto_renew is DISABLED before the renewal date.
# ─────────────────────────────────────────────────────────────
enable_subscription     = false
subscription_auto_renew = "DISABLED"

# ─────────────────────────────────────────────────────────────
# Resource Protections
# Each entry creates one aws_shield_protection resource.
# resource_arn must be the full ARN of the resource to protect.
# ─────────────────────────────────────────────────────────────
protections = [
  {
    key          = "alb_prod"
    name         = "prod-alb-shield"
    resource_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/prod-alb/abc123"
    tags = {
      resource_type = "alb"
    }
  },
  {
    key          = "cloudfront_prod"
    name         = "prod-cloudfront-shield"
    resource_arn = "arn:aws:cloudfront::123456789012:distribution/EDFDVBD6EXAMPLE"
    tags = {
      resource_type = "cloudfront"
    }
  },
  {
    key          = "eip_nat"
    name         = "nat-eip-shield"
    resource_arn = "arn:aws:ec2:us-east-1:123456789012:eip-allocation/eipalloc-12345abcde"
    tags = {
      resource_type = "eip"
    }
  }
]

# ─────────────────────────────────────────────────────────────
# Protection Groups
# ALL    – protects every resource of a given type automatically.
# BY_RESOURCE_TYPE – protects all Shield-protected resources of
#          a specific type (specify resource_type).
# ARBITRARY – covers only the resources listed in member_keys,
#          which must match protection keys defined above.
# ─────────────────────────────────────────────────────────────
protection_groups = [
  {
    key                 = "all_resources"
    protection_group_id = "all-resources-group"
    aggregation         = "MAX"
    pattern             = "ALL"
    tags = {
      scope = "global"
    }
  },
  {
    key                 = "web_tier"
    protection_group_id = "web-tier-group"
    aggregation         = "SUM"
    pattern             = "ARBITRARY"
    member_keys         = ["alb_prod", "cloudfront_prod"]
    tags = {
      scope = "web"
    }
  }
]

# ─────────────────────────────────────────────────────────────
# DRT (DDoS Response Team) Access
# The IAM role must have the AWSShieldDRTAccessPolicy managed
# policy attached and trust shield.amazonaws.com.
# Set drt_role_arn = null to skip DRT role association.
# ─────────────────────────────────────────────────────────────
drt_role_arn    = "arn:aws:iam::123456789012:role/shield-drt-role"
drt_log_buckets = ["my-alb-access-logs-bucket"]

# ─────────────────────────────────────────────────────────────
# Proactive Engagement
# Requires at least one emergency contact and active DRT role.
# ─────────────────────────────────────────────────────────────
proactive_engagement_enabled = false

emergency_contacts = [
  {
    email_address = "security-oncall@example.com"
    phone_number  = "+15551234567"
    contact_notes = "Primary on-call — 24/7 availability. Escalate to security-lead if no response in 15 min."
  }
]
