# AWS WAF v2 Terraform Module

> **Service:** [AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/) &nbsp;|&nbsp; **Module path:** `modules/security_identity_compliance/aws_waf` &nbsp;|&nbsp; **Wrapper path:** `tf-plans/aws_waf` &nbsp;|&nbsp; **Pricing:** [aws.amazon.com/waf/pricing](https://aws.amazon.com/waf/pricing/)

This module manages **AWS WAF v2** resources: IP sets, regex pattern sets, Web ACLs (REGIONAL and CLOUDFRONT scopes), Web ACL resource associations, and request logging to Kinesis Data Firehose. Multiple Web ACLs and supporting resources are created in a single `terraform apply` via map-based `for_each`.

---

## Architecture

```
  REGIONAL scope — associated by ARN via aws_wafv2_web_acl_association:
  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
  │  ALB / NLB       │  │  API Gateway     │  │  AWS AppSync     │
  └──────────────────┘  └──────────────────┘  └──────────────────┘
  ┌──────────────────┐  ┌──────────────────┐
  │  Amazon Cognito  │  │  Verified Access │
  └──────────────────┘  └──────────────────┘

  CLOUDFRONT scope — set web_acl_id in aws_cloudfront_distribution:
  ┌───────────────────────────────────────────────────────────────┐
  │           Amazon CloudFront Distribution (us-east-1)          │
  └───────────────────────────────────────────────────────────────┘
```

---

## Resources Created

| Resource | Purpose | Conditional |
|---|---|---|
| [`aws_wafv2_ip_set`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | IPv4/IPv6 address lists for allow/deny rules | One per entry in `ip_sets` |
| [`aws_wafv2_regex_pattern_set`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set) | PCRE regex patterns for URI/header/body matching | One per entry in `regex_pattern_sets` |
| [`aws_wafv2_web_acl`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | Core WAF configuration with ordered rules | One per entry in `web_acls` |
| [`aws_wafv2_web_acl_association`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | Associates a REGIONAL Web ACL with an AWS resource | One per (web_acl_key, resource_arn) pair |
| [`aws_wafv2_web_acl_logging_configuration`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | Sends WAF request logs to Kinesis Firehose | Only when `logging_firehose_arn` is set |

---

## Terraform & Provider Requirements

| Requirement | Version |
|---|---|
| Terraform | `>= 1.3` (required for `optional()` with defaults in object types) |
| AWS Provider | `>= 5.0` (required for `rule_action_override` in managed rule groups) |
| AWS Region (CLOUDFRONT scope) | Must be `us-east-1` — AWS requirement for CloudFront-associated WAFs |

---

## Input Variables

### Top-level variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | AWS region. Use `us-east-1` for CLOUDFRONT-scoped Web ACLs |
| `tags` | `map(string)` | No | `{}` | Global tags applied to all taggable resources |
| `web_acls` | `list(object)` | No | `[]` | List of Web ACL definitions — see object fields below |
| `ip_sets` | `list(object)` | No | `[]` | List of IP set definitions — see object fields below |
| `regex_pattern_sets` | `list(object)` | No | `[]` | List of regex pattern set definitions — see object fields below |

---

### `web_acls` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique `for_each` map key |
| `name` | `string` | ✅ Yes | n/a | Web ACL name in the WAF console |
| `scope` | `string` | ✅ Yes | n/a | `REGIONAL` or `CLOUDFRONT` |
| `default_action` | `string` | ✅ Yes | n/a | `allow` or `block` — applied when no rule matches |
| `description` | `string` | No | `"Managed by Terraform"` | Human-readable description |
| `cloudwatch_metrics_enabled` | `bool` | No | `true` | Enable CloudWatch metrics for this Web ACL |
| `metric_name` | `string` | No | Web ACL name | CloudWatch metric name |
| `sampled_requests_enabled` | `bool` | No | `true` | Enable request sampling in the WAF console |
| `managed_rule_group_rules` | `list(object)` | No | `[]` | AWS/Marketplace managed rule groups — see sub-fields |
| `rate_based_rules` | `list(object)` | No | `[]` | IP-level rate limiting rules — see sub-fields |
| `ip_set_reference_rules` | `list(object)` | No | `[]` | IP set allow/block rules — see sub-fields |
| `geo_match_rules` | `list(object)` | No | `[]` | Country-based allow/block rules — see sub-fields |
| `association_resource_arns` | `list(string)` | No | `[]` | REGIONAL only — resource ARNs to associate (ALB, API GW, AppSync, Cognito, Verified Access) |
| `logging_firehose_arn` | `string` | No | `null` | Kinesis Firehose ARN for request log delivery. Stream name must start with `aws-waf-logs-` |
| `log_redacted_headers` | `list(string)` | No | `[]` | HTTP header names to redact from logs (e.g. `["authorization", "cookie"]`) |
| `token_domains` | `list(string)` | No | `null` | Domains accepted in WAF CAPTCHA/challenge tokens |
| `tags` | `map(string)` | No | `{}` | Per-Web-ACL tags merged with global `tags` |

### `managed_rule_group_rules` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | ✅ Yes | n/a | Logical rule name (unique within the Web ACL) |
| `priority` | `number` | ✅ Yes | n/a | Evaluation order — lower = evaluated first |
| `rule_group_name` | `string` | ✅ Yes | n/a | AWS rule group name (e.g. `AWSManagedRulesCommonRuleSet`) |
| `vendor_name` | `string` | No | `"AWS"` | `"AWS"` or third-party Marketplace vendor name |
| `excluded_rules` | `list(string)` | No | `[]` | Rule names inside the group to override to COUNT mode (suppresses false positives) |
| `override_action` | `string` | No | `"none"` | `"none"` (use group's own actions) or `"count"` (safe testing mode) |
| `cloudwatch_metrics_enabled` | `bool` | No | `true` | Enable CloudWatch metrics for this rule |
| `metric_name` | `string` | No | Rule name | CloudWatch metric name |
| `sampled_requests_enabled` | `bool` | No | `true` | Enable request sampling for this rule |

### Common AWS Managed Rule Groups

| Rule Group Name | WCU | Description |
|---|---|---|
| `AWSManagedRulesCommonRuleSet` | 700 | OWASP Top 10 common web exploits |
| `AWSManagedRulesSQLiRuleSet` | 200 | SQL injection attack patterns |
| `AWSManagedRulesKnownBadInputsRuleSet` | 200 | Known malicious inputs and exploits |
| `AWSManagedRulesAmazonIpReputationList` | 25 | Amazon threat intelligence IP list |
| `AWSManagedRulesBotControlRuleSet` | 50 | Bot detection and control |
| `AWSManagedRulesAnonymousIpList` | 50 | VPNs, proxies, and Tor exit nodes |
| `AWSManagedRulesLinuxRuleSet` | 200 | Linux-specific exploits |
| `AWSManagedRulesWindowsRuleSet` | 200 | Windows-specific exploits |

### `rate_based_rules` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | ✅ Yes | n/a | Unique rule name within the Web ACL |
| `priority` | `number` | ✅ Yes | n/a | Evaluation order |
| `limit` | `number` | ✅ Yes | n/a | Max requests per 5-minute window per key (`100`–`2,000,000,000`) |
| `aggregate_key_type` | `string` | No | `"IP"` | `"IP"` or `"FORWARDED_IP"` (use behind proxy/CDN) |
| `action` | `string` | No | `"block"` | `"allow"`, `"block"`, or `"count"` |
| `cloudwatch_metrics_enabled` | `bool` | No | `true` | Enable CloudWatch metrics |
| `metric_name` | `string` | No | Rule name | CloudWatch metric name |
| `sampled_requests_enabled` | `bool` | No | `true` | Enable request sampling |

### `ip_set_reference_rules` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | ✅ Yes | n/a | Unique rule name within the Web ACL |
| `priority` | `number` | ✅ Yes | n/a | Evaluation order |
| `ip_set_key` | `string` | ✅ Yes | n/a | Key of the IP set defined in `var.ip_sets` |
| `action` | `string` | No | `"block"` | `"allow"`, `"block"`, or `"count"` |
| `cloudwatch_metrics_enabled` | `bool` | No | `true` | Enable CloudWatch metrics |
| `metric_name` | `string` | No | Rule name | CloudWatch metric name |
| `sampled_requests_enabled` | `bool` | No | `true` | Enable request sampling |

### `geo_match_rules` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | ✅ Yes | n/a | Unique rule name within the Web ACL |
| `priority` | `number` | ✅ Yes | n/a | Evaluation order |
| `country_codes` | `list(string)` | ✅ Yes | n/a | ISO 3166-1 alpha-2 codes (e.g. `["CN", "RU", "KP"]`) |
| `action` | `string` | No | `"block"` | `"allow"`, `"block"`, or `"count"` |
| `cloudwatch_metrics_enabled` | `bool` | No | `true` | Enable CloudWatch metrics |
| `metric_name` | `string` | No | Rule name | CloudWatch metric name |
| `sampled_requests_enabled` | `bool` | No | `true` | Enable request sampling |

### `ip_sets` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique `for_each` map key |
| `name` | `string` | ✅ Yes | n/a | IP set name |
| `scope` | `string` | ✅ Yes | n/a | `REGIONAL` or `CLOUDFRONT` (must match the Web ACL scope that references it) |
| `ip_address_version` | `string` | ✅ Yes | n/a | `IPV4` or `IPV6` |
| `addresses` | `list(string)` | ✅ Yes | n/a | CIDR blocks (e.g. `["192.0.2.0/24", "198.51.100.0/24"]`) |
| `description` | `string` | No | `"Managed by Terraform"` | Human-readable description |
| `tags` | `map(string)` | No | `{}` | Per-IP-set tags |

### `regex_pattern_sets` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique `for_each` map key |
| `name` | `string` | ✅ Yes | n/a | Regex pattern set name |
| `scope` | `string` | ✅ Yes | n/a | `REGIONAL` or `CLOUDFRONT` |
| `regular_expressions` | `list(string)` | ✅ Yes | n/a | PCRE regex strings |
| `description` | `string` | No | `"Managed by Terraform"` | Human-readable description |
| `tags` | `map(string)` | No | `{}` | Per-set tags |

---

## Outputs

| Output | Description |
|--------|-------------|
| `web_acl_ids` | Map of Web ACL key → resource ID |
| `web_acl_arns` | Map of Web ACL key → ARN. Use for `aws_cloudfront_distribution.web_acl_id` |
| `web_acl_capacity` | Map of Web ACL key → WCU consumed (max 1500 per ACL by default) |
| `ip_set_ids` | Map of IP set key → resource ID |
| `ip_set_arns` | Map of IP set key → ARN |
| `regex_pattern_set_ids` | Map of regex pattern set key → resource ID |
| `regex_pattern_set_arns` | Map of regex pattern set key → ARN |

---

## Usage Example

```hcl
module "waf" {
  source = "../../modules/security_identity_compliance/aws_waf"

  region = "us-east-1"
  tags   = { Environment = "production", Project = "platform" }

  ip_sets = [
    {
      key                = "blocklist"
      name               = "prod-blocked-ips"
      scope              = "REGIONAL"
      ip_address_version = "IPV4"
      addresses          = ["192.0.2.0/24"]
    }
  ]

  web_acls = [
    {
      key            = "prod-alb-waf"
      name           = "prod-alb-web-acl"
      scope          = "REGIONAL"
      default_action = "allow"

      managed_rule_group_rules = [
        { name = "CommonRules", priority = 10, rule_group_name = "AWSManagedRulesCommonRuleSet" },
        { name = "SQLiRules",   priority = 20, rule_group_name = "AWSManagedRulesSQLiRuleSet"   }
      ]

      rate_based_rules = [
        { name = "RateLimitPerIP", priority = 5, limit = 2000 }
      ]

      ip_set_reference_rules = [
        { name = "BlockKnownBadIPs", priority = 1, ip_set_key = "blocklist" }
      ]

      logging_firehose_arn = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-prod"
      log_redacted_headers = ["authorization", "cookie"]
    }
  ]
}
```

---

## Notes

- **WCU Quota:** Each Web ACL has a default capacity of 1,500 WCU. Common rule sets consume significant WCU (e.g. `AWSManagedRulesCommonRuleSet` = 700 WCU). Request a quota increase if needed.
- **CLOUDFRONT Scope:** The AWS provider must be configured with `region = "us-east-1"`. Associate via `aws_cloudfront_distribution.web_acl_id = module.waf.web_acl_arns["your-key"]`.
- **REGIONAL Associations:** One `aws_wafv2_web_acl_association` is created per (web_acl, resource_arn) pair. A REGIONAL Web ACL can be associated with multiple resources.
- **Logging:** Kinesis Firehose delivery stream names must start with `aws-waf-logs-`. The Firehose stream and S3/CloudWatch destination must exist before applying.
- **Rule Priorities:** All rule names within a single Web ACL must be unique, and priorities must be unique integers. Plan your priority numbering before deployment.
- **Testing New Rules:** Set `override_action = "count"` on a managed rule group or `action = "count"` on individual rules to count (not block) during testing. Switch to `"none"` or `"block"` once validated.
