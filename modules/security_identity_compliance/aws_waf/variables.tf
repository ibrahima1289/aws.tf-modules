# Variables for AWS WAF v2 Module

variable "region" {
  description = "AWS region for the AWS provider. Use 'us-east-1' for CLOUDFRONT-scoped Web ACLs (required by AWS)."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all WAF resources that support tagging."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# IP Sets — reusable IPv4/IPv6 address lists referenced by Web ACL rules
# Each object supports:
# - key (string, required)              : Stable map key for for_each — must be unique.
# - name (string, required)             : Resource name shown in the WAF console.
# - scope (string, required)            : REGIONAL or CLOUDFRONT. Must match the Web ACL scope that references it.
# - ip_address_version (string, required): IPV4 or IPV6.
# - addresses (list(string), required)  : CIDR blocks (e.g. "10.0.0.0/8", "2001:db8::/32").
# - description (string, optional)      : Human-readable description.
# - tags (map(string), optional)        : Per-IP-set tags merged with global tags.
# ─────────────────────────────────────────────────────────────────────────────
variable "ip_sets" {
  description = "List of IP set definitions. Each entry creates one aws_wafv2_ip_set resource."
  type = list(object({
    key                = string
    name               = string
    scope              = string
    description        = optional(string, "Managed by Terraform")
    ip_address_version = string
    addresses          = list(string)
    tags               = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length([for i in var.ip_sets : i.key]) == length(toset([for i in var.ip_sets : i.key]))
    error_message = "Each ip_set must have a unique 'key'."
  }

  validation {
    condition     = alltrue([for i in var.ip_sets : contains(["IPV4", "IPV6"], i.ip_address_version)])
    error_message = "ip_set.ip_address_version must be 'IPV4' or 'IPV6'."
  }

  validation {
    condition     = alltrue([for i in var.ip_sets : contains(["REGIONAL", "CLOUDFRONT"], i.scope)])
    error_message = "ip_set.scope must be 'REGIONAL' or 'CLOUDFRONT'."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Regex Pattern Sets — reusable regex patterns for URI, header, and body matching
# Each object supports:
# - key (string, required)                    : Stable map key for for_each — must be unique.
# - name (string, required)                   : Resource name.
# - scope (string, required)                  : REGIONAL or CLOUDFRONT.
# - regular_expressions (list(string), required): List of regex strings (PCRE syntax).
# - description (string, optional)            : Human-readable description.
# - tags (map(string), optional)              : Per-set tags merged with global tags.
# ─────────────────────────────────────────────────────────────────────────────
variable "regex_pattern_sets" {
  description = "List of regex pattern set definitions. Each entry creates one aws_wafv2_regex_pattern_set resource."
  type = list(object({
    key                 = string
    name                = string
    scope               = string
    description         = optional(string, "Managed by Terraform")
    regular_expressions = list(string)
    tags                = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length([for r in var.regex_pattern_sets : r.key]) == length(toset([for r in var.regex_pattern_sets : r.key]))
    error_message = "Each regex_pattern_set must have a unique 'key'."
  }

  validation {
    condition     = alltrue([for r in var.regex_pattern_sets : contains(["REGIONAL", "CLOUDFRONT"], r.scope)])
    error_message = "regex_pattern_set.scope must be 'REGIONAL' or 'CLOUDFRONT'."
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Web ACLs — top-level WAF configuration objects
#
# Each object supports:
# - key (string, required)            : Stable map key for for_each — must be unique.
# - name (string, required)           : Web ACL name shown in the WAF console.
# - scope (string, required)          : REGIONAL or CLOUDFRONT.
#     CLOUDFRONT requires the AWS provider to be configured with region = "us-east-1".
# - default_action (string, required) : "allow" or "block" — applied when no rule matches.
# - description (string, optional)    : Human-readable description.
# - cloudwatch_metrics_enabled (bool) : Enable CloudWatch metrics. Default true.
# - metric_name (string, optional)    : CloudWatch metric name. Defaults to web ACL name.
# - sampled_requests_enabled (bool)   : Enable request sampling in the console. Default true.
# - managed_rule_group_rules (list)   : AWS / Marketplace managed rule groups (see sub-fields).
# - rate_based_rules (list)           : IP-level rate limiting rules (see sub-fields).
# - ip_set_reference_rules (list)     : Rules that match against var.ip_sets entries (see sub-fields).
# - geo_match_rules (list)            : Country-based allow/block rules (see sub-fields).
# - association_resource_arns (list)  : REGIONAL only — ALB/API GW/AppSync/Cognito ARNs to protect.
# - logging_firehose_arn (string)     : Kinesis Firehose ARN for WAF log delivery. Set null to skip.
# - log_redacted_headers (list)       : Header names to redact from logs (e.g. "authorization").
# - token_domains (list(string))      : Domains WAF should accept in CAPTCHA/challenge tokens.
# - tags (map(string))                : Per-Web-ACL tags merged with global tags.
#
# managed_rule_group_rules object fields:
# - name (string, required)            : Logical name for this rule entry (unique within the ACL).
# - priority (number, required)        : Evaluation order — lower number = higher priority.
# - vendor_name (string)               : "AWS" (default) or Marketplace vendor name.
# - rule_group_name (string, required) : AWS rule group name (e.g. AWSManagedRulesCommonRuleSet).
# - excluded_rules (list(string))      : Rule names inside the group to override to COUNT mode.
# - override_action (string)           : "none" (default, use group's own actions) or "count".
# - cloudwatch_metrics_enabled (bool)  : Default true.
# - metric_name (string)               : Defaults to rule name.
# - sampled_requests_enabled (bool)    : Default true.
#
# rate_based_rules object fields:
# - name (string, required)            : Unique rule name within the Web ACL.
# - priority (number, required)        : Evaluation order.
# - limit (number, required)           : Max requests per 5-minute window per key (100–2,000,000,000).
# - aggregate_key_type (string)        : "IP" (default) or "FORWARDED_IP".
# - action (string)                    : "block" (default), "allow", or "count".
# - cloudwatch_metrics_enabled (bool)  : Default true.
# - metric_name (string)               : Defaults to rule name.
# - sampled_requests_enabled (bool)    : Default true.
#
# ip_set_reference_rules object fields:
# - name (string, required)            : Unique rule name within the Web ACL.
# - priority (number, required)        : Evaluation order.
# - ip_set_key (string, required)      : Must match a key defined in var.ip_sets.
# - action (string)                    : "block" (default), "allow", or "count".
# - cloudwatch_metrics_enabled (bool)  : Default true.
# - metric_name (string)               : Defaults to rule name.
# - sampled_requests_enabled (bool)    : Default true.
#
# geo_match_rules object fields:
# - name (string, required)            : Unique rule name within the Web ACL.
# - priority (number, required)        : Evaluation order.
# - country_codes (list(string), req)  : ISO 3166-1 alpha-2 codes (e.g. ["CN", "RU", "KP"]).
# - action (string)                    : "block" (default), "allow", or "count".
# - cloudwatch_metrics_enabled (bool)  : Default true.
# - metric_name (string)               : Defaults to rule name.
# - sampled_requests_enabled (bool)    : Default true.
# ─────────────────────────────────────────────────────────────────────────────
variable "web_acls" {
  description = "List of Web ACL definitions. Each entry creates one aws_wafv2_web_acl and optional associations and logging configuration."
  type = list(object({
    key            = string
    name           = string
    scope          = string
    default_action = string
    description    = optional(string, "Managed by Terraform")

    cloudwatch_metrics_enabled = optional(bool, true)
    metric_name                = optional(string)
    sampled_requests_enabled   = optional(bool, true)

    managed_rule_group_rules = optional(list(object({
      name            = string
      priority        = number
      vendor_name     = optional(string, "AWS")
      rule_group_name = string
      excluded_rules  = optional(list(string), [])
      override_action = optional(string, "none")

      cloudwatch_metrics_enabled = optional(bool, true)
      metric_name                = optional(string)
      sampled_requests_enabled   = optional(bool, true)
    })), [])

    rate_based_rules = optional(list(object({
      name               = string
      priority           = number
      limit              = number
      aggregate_key_type = optional(string, "IP")
      action             = optional(string, "block")

      cloudwatch_metrics_enabled = optional(bool, true)
      metric_name                = optional(string)
      sampled_requests_enabled   = optional(bool, true)
    })), [])

    ip_set_reference_rules = optional(list(object({
      name       = string
      priority   = number
      ip_set_key = string
      action     = optional(string, "block")

      cloudwatch_metrics_enabled = optional(bool, true)
      metric_name                = optional(string)
      sampled_requests_enabled   = optional(bool, true)
    })), [])

    geo_match_rules = optional(list(object({
      name          = string
      priority      = number
      country_codes = list(string)
      action        = optional(string, "block")

      cloudwatch_metrics_enabled = optional(bool, true)
      metric_name                = optional(string)
      sampled_requests_enabled   = optional(bool, true)
    })), [])

    association_resource_arns = optional(list(string), [])
    logging_firehose_arn      = optional(string)
    log_redacted_headers      = optional(list(string), [])
    token_domains             = optional(list(string))
    tags                      = optional(map(string), {})
  }))
  default = []

  validation {
    condition     = length([for w in var.web_acls : w.key]) == length(toset([for w in var.web_acls : w.key]))
    error_message = "Each web_acl must have a unique 'key'."
  }

  validation {
    condition     = alltrue([for w in var.web_acls : contains(["REGIONAL", "CLOUDFRONT"], w.scope)])
    error_message = "web_acl.scope must be 'REGIONAL' or 'CLOUDFRONT'."
  }

  validation {
    condition     = alltrue([for w in var.web_acls : contains(["allow", "block"], w.default_action)])
    error_message = "web_acl.default_action must be 'allow' or 'block'."
  }
}
