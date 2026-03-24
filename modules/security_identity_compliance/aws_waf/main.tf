# Terraform AWS WAF v2 Module
# Manages WAFv2 IP sets, regex pattern sets, Web ACLs (REGIONAL and CLOUDFRONT),
# Web ACL resource associations, and logging configurations.
#
# Scope notes:
#   REGIONAL  — protects ALB, API Gateway (REST/HTTP), AppSync, App Runner, Cognito, Verified Access.
#   CLOUDFRONT — must be deployed in us-east-1; associate via aws_cloudfront_distribution.web_acl_id.

# ─────────────────────────────────────────────────────────────────────────────
# Step 1: Create IP sets — reusable IPv4/IPv6 address lists for allow/deny rules.
# Multiple Web ACLs can reference the same IP set via ip_set_reference_rules.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_wafv2_ip_set" "ip_set" {
  for_each           = local.ip_sets_map
  name               = each.value.name
  scope              = each.value.scope
  description        = each.value.description
  ip_address_version = each.value.ip_address_version
  addresses          = each.value.addresses

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 2: Create regex pattern sets — reusable PCRE patterns for URI, header,
# and body inspection. Reference these from custom rule byte-match statements.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_wafv2_regex_pattern_set" "regex_pattern_set" {
  for_each    = local.regex_pattern_sets_map
  name        = each.value.name
  scope       = each.value.scope
  description = each.value.description

  # Step 2a: Create one regular_expression block per regex string in the list.
  dynamic "regular_expression" {
    for_each = each.value.regular_expressions
    content {
      regex_string = regular_expression.value
    }
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 3: Create Web ACLs — the top-level WAFv2 configuration object.
# Rules are evaluated in ascending priority order (lower number = evaluated first).
# The first rule whose statement matches and has an ALLOW or BLOCK action terminates
# evaluation. The Web ACL's default_action applies only when no rule matches.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_wafv2_web_acl" "web_acl" {
  for_each    = local.web_acls_map
  name        = each.value.name
  scope       = each.value.scope
  description = each.value.description

  # Step 3a: Default action for requests that match no rule.
  # "allow" is common for public-facing apps; "block" is used for strict allow-list ACLs.
  default_action {
    dynamic "allow" {
      for_each = each.value.default_action == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = each.value.default_action == "block" ? [1] : []
      content {}
    }
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Step 3b: Managed rule group rules.
  # AWS-maintained rule sets updated automatically for new threats (CVEs,
  # OWASP Top 10, known bad actors). Each rule group consumes Web ACL Capacity
  # Units (WCU) — monitor usage to avoid exceeding the 1500 WCU default quota.
  # ─────────────────────────────────────────────────────────────────────────
  dynamic "rule" {
    for_each = { for r in coalesce(each.value.managed_rule_group_rules, []) : r.name => r }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      # override_action "none" passes each rule's own action through.
      # override_action "count" sets the entire group to COUNT-only (safe testing mode).
      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          vendor_name = rule.value.vendor_name
          name        = rule.value.rule_group_name

          # Step 3c: Override specific rules inside the group to COUNT mode.
          # Used to suppress noisy rules that cause false positives in your app
          # while keeping the rest of the managed group active in BLOCK mode.
          dynamic "rule_action_override" {
            for_each = coalesce(rule.value.excluded_rules, [])
            content {
              name = rule_action_override.value
              action_to_use {
                count {}
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = coalesce(rule.value.metric_name, rule.value.name)
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Step 3d: Rate-based rules — block source IPs that exceed a request count
  # within any 5-minute window. Effective against DDoS, brute-force, and
  # credential-stuffing attacks. Blocked IPs are automatically unblocked once
  # their request rate drops below the threshold.
  # ─────────────────────────────────────────────────────────────────────────
  dynamic "rule" {
    for_each = { for r in coalesce(each.value.rate_based_rules, []) : r.name => r }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        rate_based_statement {
          # limit: max requests allowed per 5-minute window per aggregation key (100 – 2,000,000,000).
          limit = rule.value.limit
          # aggregate_key_type "IP" tracks individual source IPs.
          # "FORWARDED_IP" tracks the IP in the X-Forwarded-For header (use behind a proxy/CDN).
          aggregate_key_type = rule.value.aggregate_key_type
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = coalesce(rule.value.metric_name, rule.value.name)
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Step 3e: IP set reference rules — allow or block requests from specific IP
  # ranges defined in var.ip_sets. ip_set_key must reference a key in var.ip_sets.
  # Typical use: block known-bad IPs, allow internal monitoring IPs.
  # ─────────────────────────────────────────────────────────────────────────
  dynamic "rule" {
    for_each = { for r in coalesce(each.value.ip_set_reference_rules, []) : r.name => r }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        ip_set_reference_statement {
          # Resolve the ip_set_key to the actual IP set ARN created in Step 1.
          arn = aws_wafv2_ip_set.ip_set[rule.value.ip_set_key].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = coalesce(rule.value.metric_name, rule.value.name)
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Step 3f: Geo match rules — allow or block traffic by country of origin.
  # Uses ISO 3166-1 alpha-2 codes. Commonly used to block OFAC-sanctioned
  # countries or to restrict a service to specific regions.
  # ─────────────────────────────────────────────────────────────────────────
  dynamic "rule" {
    for_each = { for r in coalesce(each.value.geo_match_rules, []) : r.name => r }
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        geo_match_statement {
          # country_codes: list of ISO 3166-1 alpha-2 codes (e.g. "CN", "RU", "KP", "IR").
          country_codes = rule.value.country_codes
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = rule.value.cloudwatch_metrics_enabled
        metric_name                = coalesce(rule.value.metric_name, rule.value.name)
        sampled_requests_enabled   = rule.value.sampled_requests_enabled
      }
    }
  }

  # Step 3g: Web ACL-level visibility config — controls CloudWatch metrics and
  # request sampling for the entire ACL (independent of per-rule configs).
  visibility_config {
    cloudwatch_metrics_enabled = each.value.cloudwatch_metrics_enabled
    metric_name                = coalesce(each.value.metric_name, each.value.name)
    sampled_requests_enabled   = each.value.sampled_requests_enabled
  }

  # Step 3h: Optional CAPTCHA/challenge token domain list.
  # WAF only accepts tokens issued for domains in this list.
  token_domains = each.value.token_domains

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 4: Associate Web ACLs with REGIONAL AWS resources.
# One association resource is created per (web_acl_key, resource_arn) pair.
# CLOUDFRONT-scoped ACLs are NOT associated here — set web_acl_id directly on
# the aws_cloudfront_distribution resource using the web_acl_arns module output.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_wafv2_web_acl_association" "web_acl_association" {
  for_each = {
    for k, v in local.web_acl_associations_map : k => v
    if local.web_acls_map[v.web_acl_key].scope == "REGIONAL"
  }
  resource_arn = each.value.resource_arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl[each.value.web_acl_key].arn
}

# ─────────────────────────────────────────────────────────────────────────────
# Step 5: Configure WAF request logging to Kinesis Data Firehose.
# Firehose can forward logs to S3, CloudWatch Logs, or OpenSearch for SIEM
# integration. The Firehose delivery stream name must start with "aws-waf-logs-".
# Created only for Web ACLs that have logging_firehose_arn set.
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_wafv2_web_acl_logging_configuration" "web_acl_logging" {
  for_each                = { for k, v in local.web_acls_map : k => v if v.logging_firehose_arn != null }
  resource_arn            = aws_wafv2_web_acl.web_acl[each.key].arn
  log_destination_configs = [each.value.logging_firehose_arn]

  # Step 5a: Redact sensitive HTTP header values from logs.
  # Each entry in log_redacted_headers creates one redacted_fields block.
  # Common headers to redact: "authorization", "cookie", "x-api-key".
  dynamic "redacted_fields" {
    for_each = coalesce(each.value.log_redacted_headers, [])
    content {
      single_header {
        # Header names must be lowercase per WAF API requirements.
        name = lower(redacted_fields.value)
      }
    }
  }
}
