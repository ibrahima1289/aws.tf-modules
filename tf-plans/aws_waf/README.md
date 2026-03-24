# AWS WAF v2 — Terraform Wrapper

> **Module:** [aws_waf](../../modules/security_identity_compliance/aws_waf/README.md) &nbsp;|&nbsp; **Service Docs:** [aws-waf.md](../../modules/security_identity_compliance/aws_waf/aws-waf.md) &nbsp;|&nbsp; **Pricing:** [aws.amazon.com/waf/pricing](https://aws.amazon.com/waf/pricing/)

Wrapper plan for the `aws_waf` root module. Demonstrates two Web ACL patterns — a **REGIONAL ACL** protecting an ALB with managed rules, IP-based blocking/allowing, and rate limiting, and a **CLOUDFRONT ACL** providing global edge protection with geo-blocking — alongside reusable IP sets and regex pattern sets. All resources are provisioned in a single `terraform apply`.

---

## Architecture

```
terraform.tfvars ──► wrapper main.tf ──► module "waf"
                                               │
          ┌────────────────────────────────────┤
          │                                    │                         │
          ▼                                    ▼                         ▼
aws_wafv2_ip_set          aws_wafv2_web_acl (REGIONAL)    aws_wafv2_web_acl (CLOUDFRONT)
(known-bad-ips,           │ Rules (by priority):          │ Rules (by priority):
 internal-allowlist)      │  1  BlockKnownBadIPs          │  3  GlobalRateLimitPerIP
          │               │  2  AllowInternalIPs          │  5  BlockSanctionedCountries
          │ referenced ───┘  5  RateLimitPerIP            │ 10  CommonRuleSet
          │               │ 10  CommonRuleSet             │ 20  AmazonIpReputationList
          │               │ 20  SQLiRuleSet               │
          │               │ 30  KnownBadInputsRuleSet     │
          │               │ 40  AmazonIpReputationList    │
          │               │                               │
          │               ▼                               ▼
          │  aws_wafv2_web_acl_association   (CLOUDFRONT scope: set
          │  (REGIONAL: attach to ALB)        web_acl_id in CloudFront
          │                                   distribution resource)
          ▼
aws_wafv2_web_acl_logging_configuration
(Kinesis Firehose → S3 log archive)

aws_wafv2_regex_pattern_set
(malicious-user-agents)
```

---

## Files

| File | Purpose |
|------|---------|
| `main.tf` | Calls the root module; passes region, merged tags, IP sets, regex sets, and Web ACLs |
| `variables.tf` | Mirrors the root module's variable types for wrapper-level inputs |
| `locals.tf` | Computes `created_date` for consistent `created_date` tag injection |
| `provider.tf` | AWS provider and Terraform version constraints |
| `outputs.tf` | Passes all 7 module outputs through to the wrapper caller |
| `terraform.tfvars` | Example values: 2 IP sets, 1 regex set, 2 Web ACLs (REGIONAL + CLOUDFRONT) |

---

## Usage

```bash
cd tf-plans/aws_waf
terraform init
terraform plan
terraform apply
```

> **Prerequisite for CLOUDFRONT scope:** The AWS provider must be configured with `region = "us-east-1"`. This is a hard AWS requirement for WAFs associated with CloudFront distributions.

> **Prerequisite for logging:** The Kinesis Firehose delivery stream must exist before applying. Its name must start with `aws-waf-logs-`.

---

## Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | AWS region — must be `us-east-1` when using CLOUDFRONT scope |
| `tags` | `map(string)` | No | `{}` | Global tags applied to all resources |
| `ip_sets` | `list(object)` | No | `[]` | IP set definitions — see fields below |
| `regex_pattern_sets` | `list(object)` | No | `[]` | Regex pattern set definitions — see fields below |
| `web_acls` | `list(object)` | ✅ Yes | n/a | Web ACL definitions — see fields below |

### `web_acls` key fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique map key |
| `name` | `string` | ✅ Yes | n/a | Web ACL name |
| `scope` | `string` | ✅ Yes | n/a | `REGIONAL` or `CLOUDFRONT` |
| `default_action` | `string` | ✅ Yes | n/a | `allow` or `block` |
| `managed_rule_group_rules` | `list(object)` | No | `[]` | AWS/Marketplace rule groups |
| `rate_based_rules` | `list(object)` | No | `[]` | Rate-based rules (`limit` = max requests per 5 min) |
| `ip_set_reference_rules` | `list(object)` | No | `[]` | IP-based allow/deny rules |
| `geo_match_rules` | `list(object)` | No | `[]` | Country-based allow/deny rules |
| `association_resource_arns` | `list(string)` | No | `[]` | REGIONAL: ARNs to associate (ALB, API GW, AppSync…) |
| `logging_firehose_arn` | `string` | No | `null` | Kinesis Firehose ARN for WAF logs |
| `log_redacted_headers` | `list(string)` | No | `[]` | HTTP headers to redact from logs |

### `ip_sets` key fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique map key |
| `name` | `string` | ✅ Yes | n/a | IP set name |
| `scope` | `string` | ✅ Yes | n/a | `REGIONAL` or `CLOUDFRONT` |
| `ip_address_version` | `string` | ✅ Yes | n/a | `IPV4` or `IPV6` |
| `addresses` | `list(string)` | ✅ Yes | n/a | CIDR blocks to match |

### `regex_pattern_sets` key fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique map key |
| `name` | `string` | ✅ Yes | n/a | Pattern set name |
| `scope` | `string` | ✅ Yes | n/a | `REGIONAL` or `CLOUDFRONT` |
| `regular_expressions` | `list(string)` | ✅ Yes | n/a | PCRE regex strings |

---

## Outputs

| Output | Description |
|--------|-------------|
| `web_acl_ids` | Map of key → Web ACL resource ID |
| `web_acl_arns` | Map of key → Web ACL ARN (use for CloudFront `web_acl_id`) |
| `web_acl_capacity` | Map of key → WCU consumed (max 1500 per ACL by default) |
| `ip_set_ids` | Map of key → IP set resource ID |
| `ip_set_arns` | Map of key → IP set ARN |
| `regex_pattern_set_ids` | Map of key → regex pattern set resource ID |
| `regex_pattern_set_arns` | Map of key → regex pattern set ARN |

---

## Web ACL Patterns in `terraform.tfvars`

| Key | Scope | Default | Rule Types | Logging | Association |
|-----|-------|---------|-----------|---------|-------------|
| `prod-alb-waf` | REGIONAL | allow | Managed (×4) + Rate limit + IP block + IP allow | ✅ Firehose | Uncomment ARN |
| `prod-cf-waf` | CLOUDFRONT | allow | Managed (×2) + Geo block + Rate limit | — | CloudFront `web_acl_id` |

---

## Attaching the CLOUDFRONT Web ACL to a CloudFront Distribution

After applying this wrapper, reference the ARN output in your CloudFront distribution:

```hcl
resource "aws_cloudfront_distribution" "example" {
  web_acl_id = module.waf.web_acl_arns["prod-cf-waf"]
  # ...
}
```

---

## Managed Rule Group WCU Reference

| Rule Group | WCU | Notes |
|---|---|---|
| `AWSManagedRulesCommonRuleSet` | 700 | OWASP Top 10 — largest WCU consumer |
| `AWSManagedRulesSQLiRuleSet` | 200 | SQL injection patterns |
| `AWSManagedRulesKnownBadInputsRuleSet` | 200 | Exploits, log4j, SSRF |
| `AWSManagedRulesAmazonIpReputationList` | 25 | Amazon threat intel |
| Rate-based rule | 2 | Per rule |
| IP set reference rule | 1 | Per rule |
| Geo match rule | 1 | Per rule |

> Default WCU quota per Web ACL is **1,500**. The `prod-alb-waf` ACL in this example consumes ~1,129 WCU. Request a quota increase via AWS Support if you need more than 1,500 WCU.
