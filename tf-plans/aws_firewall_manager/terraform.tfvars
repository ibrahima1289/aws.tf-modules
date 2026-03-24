# ─────────────────────────────────────────────────────────────────────────────
# AWS Firewall Manager — example terraform.tfvars
# ⚠️  Prerequisites:
#   1. AWS Organizations must be enabled.
#   2. This plan must be applied from the management account or a delegated
#      administrator account.
#   3. Each active policy costs $100/month per region — review scope carefully.
# ─────────────────────────────────────────────────────────────────────────────

region = "us-east-1"

# Set to true ONLY when you want to register this account as the FMS administrator.
# Leave false if the admin account was already configured (e.g., via the console).
enable_admin_account = false

# Omit (null) to use the current caller account, or specify a member account ID
# that has been delegated FMS admin privileges.
admin_account_id = null

tags = {
  Environment = "production"
  Project     = "security-baseline"
  Owner       = "security-team"
  ManagedBy   = "terraform"
}

# managed_service_data for each policy is loaded from policies/<name>.json via locals.tf.
# Edit the JSON files directly to adjust rule groups, response actions, or thresholds.
policies = [
  # ── Policy 1: Shield Advanced ─────────────────────────────────────────────
  # Protects ALBs, CloudFront distributions, and Elastic IPs across the
  # entire organization with Shield Advanced automatic DDoS response.
  {
    name        = "shield-advanced-global"
    description = "Shield Advanced protection for ALBs, CloudFront, and EIPs org-wide."

    # Auto-remediate: attach Shield protections to any unprotected resource.
    remediation_enabled                = true
    delete_unused_fm_managed_resources = true
    exclude_resource_tags              = false

    # Scope: protect three resource types in every member account.
    resource_type_list = [
      "AWS::ElasticLoadBalancingV2::LoadBalancer",
      "AWS::CloudFront::Distribution",
      "AWS::EC2::EIP"
    ]

    security_service_type = "SHIELD_ADVANCED"
    # managed_service_data → policies/shield-advanced-global.json

    # No include/exclude maps → policy applies to the entire organization.

    tags = { PolicyType = "shield" }
  },

  # ── Policy 2: WAFv2 with AWS Managed Rules ────────────────────────────────
  # Attaches a WAFv2 Web ACL containing the AWS Managed Rules Common Rule Set
  # to all Application Load Balancers in the listed production accounts.
  {
    name        = "wafv2-alb-managed-rules"
    description = "WAFv2 AWS Managed Rules (Core Rule Set) applied to all ALBs in prod accounts."

    remediation_enabled                = true
    delete_unused_fm_managed_resources = true
    exclude_resource_tags              = false

    # Scope: ALBs only.
    resource_type_list = ["AWS::ElasticLoadBalancingV2::LoadBalancer"]

    security_service_type = "WAFV2"
    # managed_service_data → policies/wafv2-alb-managed-rules.json

    # Scope to specific production account IDs only.
    include_map_accounts = ["123456789012", "234567890123"]

    tags = { PolicyType = "waf" }
  },

  # ── Policy 3: Network Firewall ────────────────────────────────────────────
  # Deploys AWS Network Firewall endpoints into all VPCs in the production OU.
  # Replace the rule_group_arn value with your own stateful rule group ARN.
  {
    name        = "network-firewall-prod-ou"
    description = "Network Firewall stateful inspection for all VPCs in the production OU."

    remediation_enabled                = true
    delete_unused_fm_managed_resources = true
    exclude_resource_tags              = false

    # Scope: VPCs only (Network Firewall policies require AWS::EC2::VPC).
    resource_type = "AWS::EC2::VPC"

    security_service_type = "NETWORK_FIREWALL"
    # managed_service_data → policies/network-firewall-prod-ou.json

    # Scope to production OU only.
    include_map_orgunits = ["ou-xxxx-yyyyyyyy"]

    tags = { PolicyType = "network-firewall" }
  }
]
