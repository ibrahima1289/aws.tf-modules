# AWS MQ Terraform Module

This module manages one or more Amazon MQ brokers (ActiveMQ or RabbitMQ) with safe defaults, encryption options, logging, maintenance windows, and consistent tagging.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name       | Type          | Required | Description |
|------------|---------------|----------|-------------|
| `region`   | `string`      | Yes      | AWS region to use for Amazon MQ brokers. |
| `tags`     | `map(string)` | No       | Global tags applied to all Amazon MQ resources (default: `{}`). |
| `brokers`  | `map(object)` | Yes      | Map of Amazon MQ brokers to create; key is a logical name. |

Broker object schema (per entry in `brokers`):

| Field                      | Type             | Required | Description |
|----------------------------|------------------|----------|-------------|
| `broker_name`              | `string`         | Yes      | Amazon MQ broker name. |
| `engine_type`              | `string`         | Yes      | Engine type (e.g., `"ActiveMQ"` or `"RabbitMQ"`). |
| `engine_version`           | `string`         | Yes      | Engine version. |
| `host_instance_type`       | `string`         | Yes      | Broker instance type (e.g., `"mq.m5.large"`). |
| `subnet_ids`               | `list(string)`   | Yes      | Subnet IDs for the broker (usually multiple AZs). |
| `security_groups`          | `list(string)`   | Yes      | Security group IDs to attach to the broker. |
| `deployment_mode`          | `string`         | No       | Deployment mode (`"SINGLE_INSTANCE"`, `"ACTIVE_STANDBY_MULTI_AZ"`, `"CLUSTER_MULTI_AZ"`; default: `"SINGLE_INSTANCE"`). |
| `publicly_accessible`      | `bool`           | No       | Whether the broker is publicly accessible (default: `false`). |
| `auto_minor_version_upgrade` | `bool`        | No       | Enable automatic minor version upgrades (default: `true`). |
| `apply_immediately`        | `bool`           | No       | Whether changes are applied immediately (default: `true`). |
| `storage_type`             | `string`         | No       | Storage type for the broker (default: `"EBS"`). |
| `authentication_strategy`  | `string`         | No       | Authentication strategy (default: `"SIMPLE"`). |
| `kms_key_id`               | `string`         | No       | KMS key ID for broker encryption (optional if using AWS owned key). |
| `use_aws_owned_key`        | `bool`           | No       | Whether to use the AWS-owned KMS key (default: `true`). |
| `maintenance_day_of_week`  | `string`         | No       | Preferred maintenance day (e.g. `"MONDAY"`). |
| `maintenance_time_of_day`  | `string`         | No       | Preferred maintenance start time in UTC (`"HH:MM"`). |
| `maintenance_time_zone`    | `string`         | No       | Time zone for maintenance window (e.g. `"UTC"`). |
| `general_logs_enabled`     | `bool`           | No       | Enable general logs for the broker (default: `false`). |
| `audit_logs_enabled`       | `bool`           | No       | Enable audit logs for the broker (default: `false`). |
| `users`                    | `list(object)`   | Yes      | List of users (see user schema below). |
| `tags`                     | `map(string)`    | No       | Per-broker tags merged with global tags. |

User object schema (per entry in `users`):

| Field            | Type            | Required | Description |
|------------------|-----------------|----------|-------------|
| `username`       | `string`        | Yes      | Username for the broker. |
| `password`       | `string`        | Yes      | Password for the broker user. |
| `console_access` | `bool`          | No       | Whether the user has console access (default: `false`). |
| `groups`         | `list(string)`  | No       | Groups associated with the user (default: `[]`). |

## Outputs

| Name           | Description |
|----------------|-------------|
| `broker_arns`  | Map of broker keys to Amazon MQ broker ARNs. |
| `broker_ids`   | Map of broker keys to Amazon MQ broker IDs. |
| `broker_names` | Map of broker keys to Amazon MQ broker names. |

## Usage

```hcl
module "aws_mq" {
  source = "../../modules/application_integration/aws_mq"

  region = var.region
  tags = {
    Environment = "dev"
    Team        = "platform"
  }

  brokers = {
    example_mq_basic = {
      broker_name        = "example-mq-basic"
      engine_type        = "ActiveMQ"
      engine_version     = "5.17.6"
      host_instance_type = "mq.m5.large"

      subnet_ids      = ["subnet-aaa", "subnet-bbb"]
      security_groups = ["sg-aaa"]

      users = [
        {
          username = "app-user"
          password = "CHANGE_ME_STRONG_PASSWORD" # replace with a secure value or use TF vars
        }
      ]
    }
  }
}
```

All brokers are tagged with `CreatedDate` from `locals.created_date` in addition to global and per-broker tags.
