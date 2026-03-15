# AWS CloudTrail Wrapper (tf-plans)

This wrapper consumes the [CloudTrail module](../../modules/monitoring/aws_cloudtrail/README.md) and exposes all variables for deployment. Adjust `terraform.tfvars` to configure your trails, event selectors, and CloudWatch Logs integration.

## Quick Start

```bash
terraform init -upgrade
terraform validate
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region (e.g., `us-east-1`) |

---

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all resources |
| `trails` | `list(object)` | `[]` | List of CloudTrail trails — see schema in [module README](../../modules/monitoring/aws_cloudtrail/README.md) |

---

## Deployment Scenarios

### 1 — Baseline management-events trail (recommended for all accounts)

```hcl
trails = [
  {
    name                          = "prod-management-trail"
    s3_bucket_name                = "my-org-cloudtrail-logs"
    s3_key_prefix                 = "cloudtrail"
    is_multi_region_trail         = true
    include_global_service_events = true
    enable_log_file_validation    = true
    kms_key_id                    = "arn:aws:kms:us-east-1:123456789012:key/abc-123"
  }
]
```

### 2 — Data events for S3 and Lambda

```hcl
trails = [
  {
    name           = "prod-data-events-trail"
    s3_bucket_name = "my-org-cloudtrail-logs"
    event_selectors = [
      {
        read_write_type           = "All"
        include_management_events = true
        data_resources = [
          { type = "AWS::S3::Object",      values = ["arn:aws:s3:::my-sensitive-bucket/"] },
          { type = "AWS::Lambda::Function", values = ["arn:aws:lambda:us-east-1:123456789012:function:"] }
        ]
      }
    ]
  }
]
```

### 3 — CloudWatch Logs delivery for real-time alerting

```hcl
trails = [
  {
    name                       = "prod-cw-trail"
    s3_bucket_name             = "my-org-cloudtrail-logs"
    cloud_watch_logs_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/cloudtrail/prod:*"
    cloud_watch_logs_role_arn  = "arn:aws:iam::123456789012:role/CloudTrailCWLogsRole"
    event_selectors            = [{ read_write_type = "All", include_management_events = true }]
  }
]
```

### 4 — Insights anomaly detection

```hcl
trails = [
  {
    name           = "prod-insights-trail"
    s3_bucket_name = "my-org-cloudtrail-logs"
    insight_selectors = [
      { insight_type = "ApiCallRateInsight" },
      { insight_type = "ApiErrorRateInsight" }
    ]
  }
]
```

### 5 — Advanced event selectors (fine-grained data event filtering)

```hcl
trails = [
  {
    name           = "prod-advanced-trail"
    s3_bucket_name = "my-org-cloudtrail-logs"
    advanced_event_selectors = [
      {
        name = "S3-sensitive-writes"
        field_selectors = [
          { field = "eventCategory",  equals      = ["Data"] },
          { field = "resources.type", equals      = ["AWS::S3::Object"] },
          { field = "resources.ARN",  starts_with = ["arn:aws:s3:::my-sensitive-bucket/"] },
          { field = "readOnly",       equals      = ["false"] }
        ]
      }
    ]
  }
]
```

---

## Outputs

| Name | Description |
|------|-------------|
| `trail_arns` | Map of trail name → ARN |
| `trail_ids` | Map of trail name → resource ID |
| `trail_home_regions` | Map of trail name → home region |
