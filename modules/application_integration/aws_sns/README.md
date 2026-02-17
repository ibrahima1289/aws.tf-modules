# AWS SNS Terraform Module

This module manages one or more Amazon SNS topics and optional subscriptions with safe defaults and consistent tagging.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name     | Type         | Required | Description |
|----------|--------------|----------|-------------|
| `region` | `string`     | Yes      | AWS region to use for SNS topics. |
| `tags`   | `map(string)` | No      | Global tags applied to all SNS resources (default: `{}`). |
| `topics` | `map(object)` | Yes     | Map of SNS topics to create; key is a logical name. |

Topic object schema (per entry in `topics`):

| Field                        | Type           | Required | Description |
|-----------------------------|----------------|----------|-------------|
| `name`                      | `string`       | Yes      | Topic name; `.fifo` suffix is auto-added if `fifo_topic = true` and missing. |
| `fifo_topic`                | `bool`         | No       | Whether this is a FIFO topic (default: `false`). |
| `content_based_deduplication` | `bool`       | No       | Enable content-based deduplication for FIFO topics (default: `false`). |
| `display_name`              | `string`       | No       | Display name for SMS notifications. |
| `kms_master_key_id`         | `string`       | No       | KMS key ARN for server-side encryption. |
| `policy_json`               | `string`       | No       | JSON-encoded topic access policy. |
| `delivery_policy`           | `string`       | No       | JSON-encoded delivery policy. |
| `tags`                      | `map(string)`  | No       | Per-topic tags merged with global tags. |
| `subscriptions`             | `list(object)` | No       | Optional list of subscriptions for this topic. |

Subscription object schema (per entry in `subscriptions`):

| Field                  | Type          | Required | Description |
|------------------------|---------------|----------|-------------|
| `protocol`             | `string`      | Yes      | Subscription protocol (e.g., `email`, `lambda`, `sqs`, `https`). |
| `endpoint`             | `string`      | Yes      | Endpoint for the chosen protocol (e.g., email address, Lambda ARN, SQS ARN, URL). |
| `raw_message_delivery` | `bool`        | No       | Whether to enable raw message delivery (where supported). |
| `filter_policy`        | `string`      | No       | JSON filter policy for message attributes. |
| `redrive_policy_arn`   | `string`      | No       | SQS DLQ ARN for this subscription (used to build `redrive_policy`). |

## Outputs

| Name                 | Description |
|----------------------|-------------|
| `topic_arns`         | Map of topic keys to SNS topic ARNs. |
| `topic_names`        | Map of topic keys to SNS topic names. |
| `subscription_arns`  | Map of subscription keys to SNS subscription ARNs. |

## Usage

```hcl
module "aws_sns" {
  source = "../../modules/application_integration/aws_sns"

  region = var.region
  tags   = {
    Environment = "dev"
    Team        = "platform"
  }

  topics = {
    events_standard = {
      name = "example-events-topic"
    }

    events_fifo = {
      name                        = "example-events-fifo"
      fifo_topic                  = true
      content_based_deduplication = true
    }
  }
}
```

All topics are tagged with `CreatedDate` from `locals.created_date` in addition to global and per-topic tags.
