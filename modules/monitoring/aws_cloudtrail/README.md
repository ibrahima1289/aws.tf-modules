# AWS CloudTrail Terraform Module

Creates and manages [Amazon CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) trails including management events, data events (S3, Lambda, DynamoDB), advanced event selectors, CloudWatch Logs delivery, KMS encryption, and Insights anomaly detection. Supports creating **multiple trails** via a single list variable.

## Requirements

| Tool | Version |
|------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | `>= 1.3` |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) | `>= 5.0` |

---

## Architecture

```
  AWS Account (API Calls, Console Actions, SDK Requests)
           │ every API call recorded
           ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │                        CloudTrail Module                               │
  │                                                                        │
  │  ┌─────────────────────────────────────────────────────────────────┐   │
  │  │  aws_cloudtrail.trail  (one per entry in var.trails)            │   │
  │  │                                                                 │   │
  │  │  ┌──────────────────────┐   ┌────────────────────────────────┐  │   │
  │  │  │  Event Selectors     │   │  Advanced Event Selectors      │  │   │
  │  │  │  (management +       │   │  (fine-grained field filters;  │  │   │
  │  │  │   data events)       │   │   mutually exclusive w/ above) │  │   │
  │  │  └──────────────────────┘   └────────────────────────────────┘  │   │
  │  │                                                                 │   │
  │  │  ┌──────────────────────┐    ┌────────────────────────────────┐ │   │
  │  │  │  Insight Selectors   │    │  KMS Encryption (optional)     │ │   │
  │  │  │ (ApiCallRateInsight  │    │  SSE via customer-managed key  │ │   │
  │  │  │  ApiErrorRateInsight)│    └────────────────────────────────┘ │   │
  │  │  └──────────────────────┘                                       │   │
  │  └─────────────────────────────────────────────────────────────────┘   │
  │               │                          │                             │
  │               ▼                          ▼                             │
  │  ┌────────────────────┐     ┌────────────────────────────────────┐     │
  │  │  S3 Bucket         │     │  CloudWatch Logs (optional)        │     │
  │  │  (log file archive │     │  → metric filters → alarms → SNS   │     │
  │  │   + digest files)  │     └────────────────────────────────────┘     │
  │  └────────────────────┘                                                │
  └────────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
               SNS Notifications (optional delivery alerts)
```

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region (e.g., `us-east-1`) |

### Optional — Common

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Tags applied to all resources |

### Optional — `trails` schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | **required** | Trail name — unique per account/region |
| `s3_bucket_name` | `string` | **required** | S3 bucket for log file delivery (must have correct bucket policy) |
| `s3_key_prefix` | `string` | `null` | S3 key prefix for log files (e.g., `"cloudtrail/"`) |
| `sns_topic_name` | `string` | `null` | SNS topic name or ARN for delivery notifications |
| `is_multi_region_trail` | `bool` | `false` | Capture events from all AWS regions into this trail |
| `include_global_service_events` | `bool` | `true` | Include IAM, STS, CloudFront global service events |
| `is_organization_trail` | `bool` | `false` | Apply to all member accounts in AWS Organizations |
| `enable_logging` | `bool` | `true` | Toggle logging on/off without deleting the trail |
| `enable_log_file_validation` | `bool` | `true` | Generate SHA-256 digest files for integrity verification |
| `kms_key_id` | `string` | `null` | Customer-managed KMS key ARN for SSE encryption |
| `cloud_watch_logs_group_arn` | `string` | `null` | CloudWatch Logs log group ARN — must end in `:*` |
| `cloud_watch_logs_role_arn` | `string` | `null` | IAM role ARN for CWL delivery (required with `cloud_watch_logs_group_arn`) |
| `event_selectors` | `list(object)` | `[]` | Standard event selectors — see sub-schema below |
| `advanced_event_selectors` | `list(object)` | `[]` | Advanced event selectors — mutually exclusive with `event_selectors` |
| `insight_selectors` | `list(object)` | `[]` | Insight types to enable: `ApiCallRateInsight`, `ApiErrorRateInsight` |
| `tags` | `map(string)` | `{}` | Per-trail resource tags |

#### `event_selectors[*]` sub-schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `read_write_type` | `string` | `"All"` | `All` \| `ReadOnly` \| `WriteOnly` |
| `include_management_events` | `bool` | `true` | Capture management plane events |
| `exclude_management_event_sources` | `list(string)` | `[]` | Services to suppress (e.g., `["kms.amazonaws.com", "rdsdata.amazonaws.com"]`) |
| `data_resources` | `list(object)` | `[]` | Data event resources: `type` (`AWS::S3::Object`, `AWS::Lambda::Function`, `AWS::DynamoDB::Table`) + `values` (ARN prefixes) |

#### `advanced_event_selectors[*]` sub-schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | `null` | Human-readable label for this selector |
| `field_selectors` | `list(object)` | **required** | Filter conditions: `field` + one of `equals`, `not_equals`, `starts_with`, `not_starts_with`, `ends_with`, `not_ends_with` |

**Common `field` values:** `eventCategory`, `resources.type`, `resources.ARN`, `readOnly`, `eventSource`, `eventName`

#### `insight_selectors[*]` sub-schema

| Field | Type | Description |
|-------|------|-------------|
| `insight_type` | `string` | `ApiCallRateInsight` — unusual write API call rates; `ApiErrorRateInsight` — unusual API error rates |

---

## Outputs

| Name | Description |
|------|-------------|
| `trail_arns` | Map of trail name → ARN |
| `trail_ids` | Map of trail name → resource ID |
| `trail_home_regions` | Map of trail name → home region |

---

## Notes

- All resources are tagged with `created_date` (YYYY-MM-DD) via `locals.tf`.
- `event_selectors` and `advanced_event_selectors` are **mutually exclusive** per trail; if both are provided, `advanced_event_selectors` takes precedence (standard selectors are suppressed).
- The S3 bucket supplied via `s3_bucket_name` must exist and have a [bucket policy granting CloudTrail permission](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html) to call `s3:PutObject`.
- `cloud_watch_logs_group_arn` must end with `:*` — e.g., `arn:aws:logs:us-east-1:123456789012:log-group:/cloudtrail/trail-name:*`.
- `cloud_watch_logs_group_arn` and `cloud_watch_logs_role_arn` must be supplied together.
- Organisation trails require the AWS Organizations service to be enabled and a delegated admin or management account.
- See the [AWS CloudTrail Terraform docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) for the full attribute reference.
