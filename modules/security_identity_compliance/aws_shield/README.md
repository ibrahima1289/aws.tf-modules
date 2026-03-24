# AWS Shield Advanced Terraform Module

> **Service:** [AWS Shield](https://docs.aws.amazon.com/waf/latest/developerguide/shield-chapter.html) &nbsp;|&nbsp; **Module path:** `modules/security_identity_compliance/aws_shield` &nbsp;|&nbsp; **Wrapper path:** `tf-plans/aws_shield` &nbsp;|&nbsp; **Pricing:** [aws.amazon.com/shield/pricing](https://aws.amazon.com/shield/pricing/)

This module manages **AWS Shield Advanced** protections, protection groups, DRT (DDoS Response Team) access, and proactive engagement. Shield Standard (free, automatic) requires no Terraform resources.

> ⚠️ **Cost Warning:** Shield Advanced costs **$3,000/month minimum** with a **1-year commitment**. The `enable_subscription` flag defaults to `false` as a safety gate. Only set it to `true` intentionally. Most teams enable Shield Advanced via the AWS Console or AWS Organizations and manage only protections/groups with Terraform.

---

## Shield Standard vs Shield Advanced

| Feature | Shield Standard | Shield Advanced |
|---|---|---|
| Cost | **Free — always on** | $3,000/month + data transfer fees |
| Layer 3/4 DDoS protection | ✅ | ✅ Enhanced |
| Layer 7 DDoS protection | ❌ | ✅ (with WAF) |
| DDoS Response Team (DRT) | ❌ | ✅ 24/7 access |
| Cost protection (usage spikes) | ❌ | ✅ |
| Near real-time attack visibility | ❌ | ✅ CloudWatch metrics |
| Proactive engagement | ❌ | ✅ |
| Terraform managed | ❌ Not needed | ✅ This module |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                       AWS Shield Advanced Module                             │
│                                                                              │
│  var.protections (list)             var.protection_groups (list)             │
│       │                                      │                               │
│       ▼                                      ▼                               │
│  local.protections_map          local.protection_groups_map                  │
│       │                                      │                               │
│       ▼                                      ▼                               │
│  aws_shield_protection          aws_shield_protection_group                  │
│  (one per resource ARN)         (ALL | BY_RESOURCE_TYPE | ARBITRARY)         │
│       │                                                                      │
│  var.drt_role_arn ──► aws_shield_drt_access_role_arn_association             │
│  var.drt_log_buckets ──► aws_shield_drt_access_log_bucket_association        │
│  var.emergency_contacts ──► aws_shield_proactive_engagement                  │
│                                                                              │
│  var.enable_subscription ──► aws_shield_subscription (⚠️ $3k/month)         │
│                                                                              │
│  Outputs: protection_ids · protection_arns · protection_group_ids            │
│           subscription_id                                                    │
└──────────────────────────────────────────────────────────────────────────────┘

  Protected resources (referenced by ARN):
  ┌──────────────┐  ┌───────────┐  ┌─────────┐  ┌──────────────────┐  ┌─────┐
  │ ALB / NLB    │  │CloudFront │  │Route 53 │  │Global Accelerator│  │ EIP │
  └──────────────┘  └───────────┘  └─────────┘  └──────────────────┘  └─────┘
```

---

## Resources Created

| Resource | Purpose | Conditional |
|---|---|---|
| [`aws_shield_subscription`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_subscription) | Enables Shield Advanced subscription | Only when `enable_subscription = true` |
| [`aws_shield_protection`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | Protects a single AWS resource by ARN | One per entry in `protections` |
| [`aws_shield_protection_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection_group) | Groups protections for aggregate management | One per entry in `protection_groups` |
| [`aws_shield_drt_access_role_arn_association`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_drt_access_role_arn_association) | Grants DRT role access | Only when `drt_role_arn` is set |
| [`aws_shield_drt_access_log_bucket_association`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_drt_access_log_bucket_association) | Grants DRT S3 log bucket access | One per bucket in `drt_log_buckets` |
| [`aws_shield_proactive_engagement`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_proactive_engagement) | DRT proactive contact on attack detection | Only when `emergency_contacts` is set |

---

## Terraform & Provider Requirements

| Requirement | Version |
|---|---|
| Terraform | `>= 1.3` (required for `optional()` with defaults in object types) |
| AWS Provider | `>= 5.0` |
| AWS Region | Use `us-east-1` when protecting CloudFront distributions or Route 53 hosted zones |

---

## Input Variables

### Top-level variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | AWS region — use `us-east-1` for global resources |
| `tags` | `map(string)` | No | `{}` | Global tags applied to all taggable resources |
| `enable_subscription` | `bool` | No | `false` | ⚠️ Set `true` to enable Shield Advanced subscription ($3,000/month) |
| `subscription_auto_renew` | `string` | No | `"ENABLED"` | Subscription auto-renewal: `ENABLED` or `DISABLED` |
| `protections` | `list(object)` | No | `[]` | List of resources to protect — see object fields below |
| `protection_groups` | `list(object)` | No | `[]` | List of protection groups — see object fields below |
| `drt_role_arn` | `string` | No | `null` | IAM role ARN for DRT access. Role must trust `shield.amazonaws.com` |
| `drt_log_buckets` | `list(string)` | No | `[]` | S3 bucket names for DRT log access. Requires `drt_role_arn` |
| `proactive_engagement_enabled` | `bool` | No | `false` | Enable DRT proactive engagement on attack detection |
| `emergency_contacts` | `list(object)` | No | `[]` | Emergency contacts for proactive engagement — see object fields below |

### `protections` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique `for_each` map key |
| `name` | `string` | ✅ Yes | n/a | Friendly name shown in the Shield console |
| `resource_arn` | `string` | ✅ Yes | n/a | ARN of the resource to protect (ALB, NLB, EIP, CloudFront, Route 53, Global Accelerator) |
| `tags` | `map(string)` | No | `{}` | Per-protection tags merged with global `tags` |

### `protection_groups` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Stable unique `for_each` map key |
| `protection_group_id` | `string` | ✅ Yes | n/a | Unique group identifier shown in the Shield console |
| `aggregation` | `string` | ✅ Yes | n/a | Attack metric aggregation: `SUM`, `MEAN`, or `MAX` |
| `pattern` | `string` | ✅ Yes | n/a | `ALL` (entire account), `BY_RESOURCE_TYPE`, or `ARBITRARY` (explicit list) |
| `resource_type` | `string` | Conditional | `null` | Required when `pattern = BY_RESOURCE_TYPE`. One of: `APPLICATION_LOAD_BALANCER`, `CLOUDFRONT_DISTRIBUTION`, `ELASTIC_IP_ALLOCATION`, `CLASSIC_LOAD_BALANCER`, `ROUTE_53_HOSTED_ZONE`, `GLOBAL_ACCELERATOR` |
| `member_keys` | `list(string)` | Conditional | `null` | Required when `pattern = ARBITRARY`. Must match `key` values in `var.protections` |
| `tags` | `map(string)` | No | `{}` | Per-group tags merged with global `tags` |

### `emergency_contacts` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `email_address` | `string` | ✅ Yes | n/a | Contact email address |
| `phone_number` | `string` | No | `null` | Contact phone number in E.164 format (e.g. `+12125551234`) |
| `contact_notes` | `string` | No | `null` | Free-text notes shown to the DRT (escalation procedures, on-call details) |

---

## Outputs

| Output | Description |
|--------|-------------|
| `protection_ids` | Map of protection key → Shield protection resource ID |
| `protection_arns` | Map of protection key → Shield protection ARN |
| `protection_group_ids` | Map of protection group key → protection group ID |
| `subscription_id` | Shield Advanced subscription ID (empty when `enable_subscription = false`) |

---

## Tags

All taggable Shield resources include `created_date` (YYYY-MM-DD) sourced from `local.created_date`, merged with global `var.tags` and any per-resource `tags`.

> **Note:** `aws_shield_subscription`, `aws_shield_drt_access_role_arn_association`, `aws_shield_drt_access_log_bucket_association`, and `aws_shield_proactive_engagement` do not support tags.

---

## Usage

```hcl
module "shield" {
  source = "../../modules/security_identity_compliance/aws_shield"
  region = "us-east-1"   # Use us-east-1 for CloudFront / Route 53 protections
  tags   = { Environment = "prod" }

  # ⚠️  Uncomment ONLY if you want Terraform to manage the subscription
  # enable_subscription     = true
  # subscription_auto_renew = "ENABLED"

  protections = [
    {
      key          = "prod-alb"
      name         = "Production ALB"
      resource_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/prod-alb/abc123"
      tags         = { Tier = "web" }
    },
    {
      key          = "prod-cloudfront"
      name         = "Production CloudFront"
      resource_arn = "arn:aws:cloudfront::123456789012:distribution/EDFDVBD6EXAMPLE"
      tags         = { Tier = "cdn" }
    }
  ]

  protection_groups = [
    {
      # ALL pattern — covers every protection in the account
      key                 = "all-resources"
      protection_group_id = "all-resources-group"
      aggregation         = "MAX"
      pattern             = "ALL"
    },
    {
      # ARBITRARY pattern — covers two explicitly named protections
      key                 = "web-tier"
      protection_group_id = "web-tier-group"
      aggregation         = "SUM"
      pattern             = "ARBITRARY"
      member_keys         = ["prod-alb", "prod-cloudfront"]
    }
  ]

  # DRT access (optional)
  drt_role_arn    = "arn:aws:iam::123456789012:role/shield-drt-role"
  drt_log_buckets = ["my-access-logs-bucket"]

  # Proactive engagement (optional)
  proactive_engagement_enabled = true
  emergency_contacts = [
    {
      email_address = "oncall@example.com"
      phone_number  = "+12125551234"
      contact_notes = "Contact the on-call security team. Escalate to CISO after 30 min."
    }
  ]
}
```
