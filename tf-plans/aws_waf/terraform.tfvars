# ─────────────────────────────────────────────────────────────────────────────
# NOTE: For CLOUDFRONT-scoped Web ACLs, the region below MUST be "us-east-1".
#       This is an AWS requirement — CloudFront reads WAF rules from us-east-1 only.
#       For REGIONAL-only deployments, set this to your target region.
# ─────────────────────────────────────────────────────────────────────────────
region = "us-east-1"

tags = {
  Environment = "production"
  Project     = "platform"
  Team        = "security"
}

# ─────────────────────────────────────────────────────────────────────────────
# IP Sets — define reusable address lists here; reference them in Web ACL rules
# using ip_set_reference_rules { ip_set_key = "<key>" }.
# ─────────────────────────────────────────────────────────────────────────────
ip_sets = [
  # IPv4 blocklist: known malicious IPs and scanners.
  # Replace TEST-NET CIDRs (RFC 5737) with actual threat intelligence feeds.
  {
    key                = "known-bad-ips"
    name               = "prod-known-bad-ips"
    scope              = "REGIONAL"
    description        = "Known malicious IPv4 addresses — blocked across all regional Web ACLs"
    ip_address_version = "IPV4"
    addresses = [
      "192.0.2.0/24",    # TEST-NET-1 (RFC 5737) — replace with real threat IPs
      "198.51.100.0/24", # TEST-NET-2 (RFC 5737) — replace with real threat IPs
    ]
    tags = { Purpose = "security-blocklist" }
  },

  # IPv4 allowlist: internal monitoring and health-check IPs (bypasses all rules).
  {
    key                = "internal-allowlist"
    name               = "prod-internal-allowlist"
    scope              = "REGIONAL"
    description        = "Internal monitoring and health-check IPs — always allowed"
    ip_address_version = "IPV4"
    addresses = [
      "10.0.0.0/8", # Internal RFC 1918 range — restrict further in production
    ]
    tags = { Purpose = "internal-access" }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Regex Pattern Sets — PCRE patterns used for custom rule matching.
# (Not directly referenced in this tfvars example, shown for completeness.)
# ─────────────────────────────────────────────────────────────────────────────
regex_pattern_sets = [
  {
    key         = "malicious-user-agents"
    name        = "prod-malicious-user-agents"
    scope       = "REGIONAL"
    description = "PCRE patterns matching known scanner and exploit tool user-agent strings"
    regular_expressions = [
      "(?i)^(nikto|sqlmap|nmap|masscan|zgrab|dirbuster)", # common scanner tools
      "(?i)python-requests/[0-9]",                        # raw Python HTTP scripts
    ]
    tags = { Purpose = "bot-detection" }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Web ACLs — each entry provisions one aws_wafv2_web_acl.
# Rules within a Web ACL are evaluated in ascending priority order.
# Lower priority number = evaluated first. Rule names must be unique per ACL.
# ─────────────────────────────────────────────────────────────────────────────
web_acls = [

  # ── Pattern 1: REGIONAL Web ACL — production ALB ─────────────────────────
  # Attaches to an Application Load Balancer via association_resource_arns.
  # Combines AWS managed rule groups, IP blocklist, allowlist, and rate limiting.
  {
    key            = "prod-alb-waf"
    name           = "prod-alb-web-acl"
    scope          = "REGIONAL"
    default_action = "allow"
    description    = "Production WAF protecting the application ALB — managed rules, rate limiting, IP lists"

    # ── Managed rule groups (evaluated in priority order 10, 20, 30, 40) ──
    managed_rule_group_rules = [
      {
        # Priority 10: AWS Common Rule Set — blocks OWASP Top 10 patterns.
        # SizeRestrictions_QUERYSTRING is overridden to COUNT to avoid blocking
        # legitimate large API query strings in this application.
        name            = "CommonRuleSet"
        priority        = 10
        rule_group_name = "AWSManagedRulesCommonRuleSet"
        override_action = "none"
        excluded_rules  = ["SizeRestrictions_QUERYSTRING"]
      },
      {
        # Priority 20: SQL Injection Rule Set — blocks SQLi attack patterns.
        name            = "SQLiRuleSet"
        priority        = 20
        rule_group_name = "AWSManagedRulesSQLiRuleSet"
        override_action = "none"
        excluded_rules  = []
      },
      {
        # Priority 30: Known Bad Inputs — blocks exploit payloads and log4j patterns.
        name            = "KnownBadInputsRuleSet"
        priority        = 30
        rule_group_name = "AWSManagedRulesKnownBadInputsRuleSet"
        override_action = "none"
        excluded_rules  = []
      },
      {
        # Priority 40: Amazon IP Reputation List — blocks IPs in Amazon threat intel.
        # Set override_action = "count" to test before enabling blocking.
        name            = "AmazonIpReputationList"
        priority        = 40
        rule_group_name = "AWSManagedRulesAmazonIpReputationList"
        override_action = "none"
        excluded_rules  = []
      }
    ]

    # ── Rate-based rule — evaluated at priority 5 (before managed groups) ──
    rate_based_rules = [
      {
        # Block source IPs exceeding 2000 requests in any 5-minute window.
        name               = "RateLimitPerIP"
        priority           = 5
        limit              = 2000
        aggregate_key_type = "IP"
        action             = "block"
      }
    ]

    # ── IP set rules — evaluated at priority 1 and 2 (highest priority) ───
    ip_set_reference_rules = [
      {
        # Priority 1: Block known bad IPs before any other evaluation.
        name       = "BlockKnownBadIPs"
        priority   = 1
        ip_set_key = "known-bad-ips"
        action     = "block"
      },
      {
        # Priority 2: Allow internal monitoring IPs unconditionally.
        name       = "AllowInternalIPs"
        priority   = 2
        ip_set_key = "internal-allowlist"
        action     = "allow"
      }
    ]

    # ── Logging: send all request logs to Kinesis Firehose → S3 ───────────
    # Replace with the actual Firehose ARN. Stream name must start with "aws-waf-logs-".
    logging_firehose_arn = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-prod-alb"
    # Redact sensitive headers to prevent credentials appearing in log files.
    log_redacted_headers = ["authorization", "cookie", "x-api-key"]

    # ── Associate with the production ALB ─────────────────────────────────
    # Uncomment and replace ARN after the ALB has been created.
    # association_resource_arns = [
    #   "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/prod-alb/abc123def456"
    # ]

    tags = { Scope = "regional", Tier = "production", Resource = "alb" }
  },

  # ── Pattern 2: CLOUDFRONT-scoped Web ACL — global edge protection ────────
  # MUST be deployed in us-east-1 (set region = "us-east-1" above).
  # Associate via aws_cloudfront_distribution.web_acl_id using the ARN output:
  #   web_acl_id = module.waf.web_acl_arns["prod-cf-waf"]
  {
    key            = "prod-cf-waf"
    name           = "prod-cloudfront-web-acl"
    scope          = "CLOUDFRONT"
    default_action = "allow"
    description    = "Global WAF for CloudFront — managed rules, geo-blocking, and rate limiting at the edge"

    managed_rule_group_rules = [
      {
        # Common Rule Set for Layer 7 exploit protection at the CDN edge.
        name            = "CommonRuleSet"
        priority        = 10
        rule_group_name = "AWSManagedRulesCommonRuleSet"
        override_action = "none"
        excluded_rules  = []
      },
      {
        # Amazon IP Reputation List: blocks IPs associated with bots, scanners, and DDoS.
        name            = "AmazonIpReputationList"
        priority        = 20
        rule_group_name = "AWSManagedRulesAmazonIpReputationList"
        override_action = "none"
        excluded_rules  = []
      }
    ]

    # Block traffic originating from OFAC-sanctioned countries at the edge.
    geo_match_rules = [
      {
        name          = "BlockSanctionedCountries"
        priority      = 5
        country_codes = ["KP", "CU", "IR", "SY"] # North Korea, Cuba, Iran, Syria
        action        = "block"
      }
    ]

    # Edge-level rate limiting — higher threshold than ALB to account for CDN caching.
    rate_based_rules = [
      {
        name               = "GlobalRateLimitPerIP"
        priority           = 3
        limit              = 5000
        aggregate_key_type = "IP"
        action             = "block"
      }
    ]

    # CLOUDFRONT associations are managed in the distribution resource, not here.
    association_resource_arns = []

    tags = { Scope = "cloudfront", Tier = "production", Resource = "cdn" }
  }
]
