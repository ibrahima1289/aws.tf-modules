variable "region" {
  description = "AWS region where WAF resources are created. Use 'us-east-1' for CLOUDFRONT-scoped Web ACLs."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all WAF resources."
  type        = map(string)
  default     = {}
}

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
}

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
}

variable "web_acls" {
  description = "List of Web ACL definitions. Each entry creates one aws_wafv2_web_acl and optional associations/logging."
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
}
