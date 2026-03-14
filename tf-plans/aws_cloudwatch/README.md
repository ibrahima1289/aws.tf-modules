# AWS CloudWatch Wrapper (tf-plans)

This wrapper consumes the [CloudWatch module](../../modules/monitoring/aws_cloudwatch/README.md) and exposes all variables for deployment. Adjust `terraform.tfvars` to configure your log groups, alarms, dashboards, and filters.

## Quick Start

```bash
terraform init -upgrade
terraform validate
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Architecture

```
  terraform.tfvars
        │
        ▼
  ┌────────────────────────────────────────────────────────────────┐
  │  tf-plans/aws_cloudwatch  (wrapper)                            │
  │                                                                │
  │  provider.tf  ──▶  AWS provider (region)                      │
  │  locals.tf    ──▶  created_date tag                           │
  │  variables.tf ──▶  all input variables                        │
  │  main.tf      ──▶  module "cloudwatch" {                      │
  │                       source = ../../modules/monitoring/…      │
  │                    }                                           │
  │  outputs.tf   ──▶  expose all module outputs                  │
  └────────────────────────────────────────────────────────────────┘
        │
        ▼
  modules/monitoring/aws_cloudwatch/
  ├─ Log Groups              (aws_cloudwatch_log_group)
  ├─ Metric Alarms           (aws_cloudwatch_metric_alarm)
  ├─ Composite Alarms        (aws_cloudwatch_composite_alarm)
  ├─ Dashboards              (aws_cloudwatch_dashboard)
  ├─ Log Metric Filters      (aws_cloudwatch_log_metric_filter)
  └─ Log Subscription Filters (aws_cloudwatch_log_subscription_filter)
```

---

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region (e.g., `us-east-1`) |

---

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all resources |
| `log_groups` | `list(object)` | `[]` | Log groups — see schema below |
| `metric_alarms` | `list(object)` | `[]` | Metric alarms — see schema below |
| `composite_alarms` | `list(object)` | `[]` | Composite alarms — see schema below |
| `dashboards` | `list(object)` | `[]` | Dashboards (name + JSON body) |
| `log_metric_filters` | `list(object)` | `[]` | Log metric filters — see schema below |
| `log_subscription_filters` | `list(object)` | `[]` | Log subscription filters — see schema below |

See [module README](../../modules/monitoring/aws_cloudwatch/README.md) for full object schemas.

---

## Deployment Scenarios

### 1 — Log groups only (centralise application logs)

```hcl
log_groups = [
  { name = "/app/my-api",     retention_in_days = 30 },
  { name = "/app/my-workers", retention_in_days = 14 },
]
```

### 2 — EC2 CPU alarm with SNS notification

```hcl
metric_alarms = [
  {
    alarm_name          = "prod-high-cpu"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods  = 3
    threshold           = 80
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 300
    statistic           = "Average"
    dimensions          = { AutoScalingGroupName = "prod-asg" }
    alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:ops-alerts"]
    treat_missing_data  = "breaching"
  }
]
```

### 3 — Expression-based alarm (anomaly detection)

```hcl
metric_alarms = [
  {
    alarm_name          = "prod-anomaly-cpu"
    comparison_operator = "GreaterThanUpperThreshold"
    evaluation_periods  = 2
    threshold           = 2
    alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:ops-alerts"]
    metric_queries = [
      {
        id = "m1"; return_data = false
        metric = {
          metric_name = "CPUUtilization"; namespace = "AWS/EC2"
          period = 300; stat = "Average"
          dimensions = { InstanceId = "i-0abc123" }
        }
      },
      {
        id = "ad1"; expression = "ANOMALY_DETECTION_BAND(m1, 2)"
        label = "CPU (expected)"; return_data = true
      }
    ]
  }
]
```

### 4 — Log-to-metric filter + alarm

```hcl
log_metric_filters = [
  {
    name = "api-errors"; pattern = "ERROR"
    log_group_name = "/app/my-api"
    metric_name = "ApiErrorCount"; metric_namespace = "MyApp"
  }
]

metric_alarms = [
  {
    alarm_name = "api-error-rate"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1; threshold = 10
    metric_name = "ApiErrorCount"; namespace = "MyApp"
    period = 60; statistic = "Sum"
    alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alerts"]
  }
]
```

### 5 — Stream logs to Lambda

```hcl
log_subscription_filters = [
  {
    name = "api-to-lambda"
    log_group_name = "/app/my-api"
    filter_pattern = ""
    destination_arn = "arn:aws:lambda:us-east-1:123456789012:function:log-processor"
  }
]
```

---

## Outputs

| Name | Description |
|------|-------------|
| `log_group_names` | Map of key → log group name |
| `log_group_arns` | Map of key → log group ARN |
| `metric_alarm_arns` | Map of alarm name → ARN |
| `metric_alarm_ids` | Map of alarm name → ID |
| `composite_alarm_arns` | Map of composite alarm name → ARN |
| `composite_alarm_ids` | Map of composite alarm name → ID |
| `dashboard_arns` | Map of dashboard name → ARN |
| `log_metric_filter_ids` | Map of filter name → ID |
| `log_subscription_filter_ids` | Map of filter name → ID |
