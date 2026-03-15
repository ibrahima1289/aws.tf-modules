# AWS CloudWatch Terraform Module

Creates and manages [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/WhatIsCloudWatch.html) resources including log groups, metric alarms, composite alarms, dashboards, log metric filters, and log subscription filters. Supports creating **multiple resources of each type** via list variables.

## Requirements

| Tool | Version |
|------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | `>= 1.3` |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest) | `>= 5.0` |

---

## Architecture

```
  AWS Services (EC2, RDS, Lambda, ECS…)
         │ emit metrics & logs
         ▼
  ┌─────────────────────────────────────────────────────────────────────┐
  │                      CloudWatch Module                              │
  │                                                                     │
  │  ┌──────────────┐   pattern    ┌────────────────────┐               │
  │  │  Log Groups  │ ──────────▶ │  Log Metric        │               │
  │  │              │              │  Filters           │               │
  │  └──────┬───────┘              └──────────┬─────────┘               │
  │         │ subscribe                       │ custom metric           │
  │         ▼                                 ▼                         │
  │  ┌──────────────┐              ┌────────────────────┐               │
  │  │  Log Sub.    │              │   Metric Alarms    │               │
  │  │  Filters     │              └──────────┬─────────┘               │
  │  └──────┬───────┘                         │ ALARM() / OK()          │
  │         │                                 ▼                         │
  │         │                       ┌────────────────────┐              │
  │         │                       │  Composite Alarms  │              │
  │         │                       └──────────┬─────────┘              │
  │         │                                  │ actions                │
  │         ▼                                  ▼                        │
  │  Lambda / Kinesis /            SNS Topics / Auto Scaling /          │
  │  Firehose Destination          EC2 Actions / OpsCenter              │
  │                                                                     │
  │  ┌──────────────────────────────────────────────────────────────┐   │
  │  │               Dashboards (visualise all metrics)             │   │
  │  └──────────────────────────────────────────────────────────────┘   │
  └─────────────────────────────────────────────────────────────────────┘
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

### Optional — `log_groups` schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | **required** | Log group name (e.g., `/aws/lambda/my-fn`) |
| `retention_in_days` | `number` | `30` | Days to retain log events (`0` = never expire) |
| `kms_key_id` | `string` | `null` | KMS key ARN for encryption at rest |
| `tags` | `map(string)` | `{}` | Per-resource tags |

### Optional — `metric_alarms` schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `alarm_name` | `string` | **required** | Unique alarm name |
| `comparison_operator` | `string` | **required** | e.g., `GreaterThanThreshold` |
| `evaluation_periods` | `number` | **required** | Number of periods to evaluate |
| `threshold` | `number` | **required** | Numeric threshold |
| `metric_name` | `string` | `null` | Metric name (omit when using `metric_queries`) |
| `namespace` | `string` | `null` | Namespace (e.g., `AWS/EC2`) |
| `period` | `number` | `60` | Period in seconds |
| `statistic` | `string` | `Average` | `Average \| Sum \| Min \| Max \| SampleCount` |
| `extended_statistic` | `string` | `null` | Percentile stat (e.g., `p99`); overrides `statistic` |
| `unit` | `string` | `null` | Metric unit |
| `dimensions` | `map(string)` | `{}` | Dimension key/value pairs |
| `alarm_description` | `string` | alarm name | Human-readable description |
| `alarm_actions` | `list(string)` | `[]` | SNS/action ARNs on ALARM state |
| `ok_actions` | `list(string)` | `[]` | SNS/action ARNs on OK state |
| `insufficient_data_actions` | `list(string)` | `[]` | SNS/action ARNs on INSUFFICIENT_DATA |
| `treat_missing_data` | `string` | `missing` | `missing \| ignore \| breaching \| notBreaching` |
| `datapoints_to_alarm` | `number` | `null` | N-of-M datapoints to breach |
| `metric_queries` | `list(object)` | `[]` | Expression-based queries (math/anomaly detection) |
| `tags` | `map(string)` | `{}` | Per-resource tags |

#### `metric_queries[*]` sub-schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `id` | `string` | **required** | Unique ID in this alarm (e.g., `m1`) |
| `expression` | `string` | `null` | Math expression (e.g., `m1+m2`) |
| `label` | `string` | `null` | Display label |
| `period` | `number` | `null` | Override period |
| `return_data` | `bool` | `false` | `true` on the query whose result is evaluated against threshold |
| `metric` | `object` | `null` | Nested metric: `metric_name`, `namespace`, `period`, `stat`, `unit?`, `dimensions?` |

### Optional — `composite_alarms` schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `alarm_name` | `string` | **required** | Unique composite alarm name |
| `alarm_rule` | `string` | **required** | Boolean expression using `ALARM()`, `OK()`, `INSUFFICIENT_DATA()` |
| `alarm_description` | `string` | alarm name | Human-readable description |
| `alarm_actions` | `list(string)` | `[]` | Action ARNs on ALARM |
| `ok_actions` | `list(string)` | `[]` | Action ARNs on OK |
| `insufficient_data_actions` | `list(string)` | `[]` | Action ARNs on INSUFFICIENT_DATA |
| `actions_suppressor` | `object` | `null` | Suppressor: `alarm` (name), `extension_period?` (s), `wait_period?` (s) |
| `tags` | `map(string)` | `{}` | Per-resource tags |

### Optional — `dashboards` schema

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Dashboard name (unique per account/region) |
| `body` | `string` | JSON body — use [`jsonencode()`](https://developer.hashicorp.com/terraform/language/functions/jsonencode) in the caller |

### Optional — `log_metric_filters` schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | **required** | Filter name |
| `pattern` | `string` | **required** | [Filter pattern](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/FilterAndPatternSyntax.html) (e.g., `"ERROR"`) |
| `log_group_name` | `string` | **required** | Source log group |
| `metric_name` | `string` | **required** | Metric to publish |
| `metric_namespace` | `string` | **required** | Namespace for the metric |
| `metric_value` | `string` | `"1"` | Value per match (numeric string) |
| `metric_default_value` | `number` | `null` | Value when no events match |
| `metric_unit` | `string` | `None` | Metric unit |
| `metric_dimensions` | `map(string)` | `{}` | Dimensions from log fields |

### Optional — `log_subscription_filters` schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | `string` | **required** | Filter name |
| `log_group_name` | `string` | **required** | Source log group |
| `filter_pattern` | `string` | **required** | Filter pattern (`""` = all events) |
| `destination_arn` | `string` | **required** | ARN of Lambda, Kinesis Stream, or Firehose |
| `distribution` | `string` | `ByLogStream` | `ByLogStream` or `Random` |
| `role_arn` | `string` | `null` | IAM role ARN (required for Kinesis/Firehose) |

---

## Outputs

| Name | Description |
|------|-------------|
| `log_group_names` | Map of key → log group name |
| `log_group_arns` | Map of key → log group ARN |
| `metric_alarm_arns` | Map of alarm name → ARN |
| `metric_alarm_ids` | Map of alarm name → resource ID |
| `composite_alarm_arns` | Map of composite alarm name → ARN |
| `composite_alarm_ids` | Map of composite alarm name → ID |
| `dashboard_arns` | Map of dashboard name → ARN |
| `log_metric_filter_ids` | Map of filter name → resource ID |
| `log_subscription_filter_ids` | Map of filter name → resource ID |

---

## Notes

- All resources are tagged with `created_date` (YYYY-MM-DD) via `locals.tf`.
- Multiple resources of each type are created from a single list variable, outputting maps keyed by resource name.
- CloudWatch dashboards do not support tags (AWS limitation).
- For expression-based alarms, omit `metric_name`/`namespace`/`period`/`statistic` and use `metric_queries` instead.
- Log subscription filters to Kinesis/Firehose require a `role_arn` with permission to call `kinesis:PutRecord`.
- See the [AWS CloudWatch Terraform docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) for full attribute reference.
