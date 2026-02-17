# AWS SQS Terraform Module

This module manages one or more Amazon SQS queues with safe defaults, optional dead-letter queues, encryption, and policies. It follows the same multi-resource and tagging patterns as the other modules in this repository.

## Requirements

- Terraform = 1.3.0
- AWS Provider = 5.0

## Inputs

| Name    | Type | Required | Description |
|---------|------|----------|-------------|
| `region` | `string` | Yes | AWS region to use for the SQS queues. |
| `tags` | `map(string)` | No | Global tags applied to all SQS queues (default: `{}`). |
| `queues` | `map(object)` | Yes | Map of SQS queues to create; key is a logical name. |

Queue object schema:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | `string` | Yes | Queue name; `.fifo` suffix is auto-added if `fifo_queue = true` and missing. |
| `fifo_queue` | `bool` | No | Whether this is a FIFO queue (default: `false`). |
| `content_based_deduplication` | `bool` | No | Enable content-based deduplication for FIFO queues (default: `false`). |
| `delay_seconds` | `number` | No | Time in seconds that messages are delayed (default: `0`). |
| `maximum_message_size` | `number` | No | Maximum message size in bytes (default: `262144`). |
| `message_retention_seconds` | `number` | No | How long messages are retained (default: `345600`). |
| `receive_wait_time_seconds` | `number` | No | Long polling wait time in seconds (default: `0`). |
| `visibility_timeout_seconds` | `number` | No | Visibility timeout in seconds (default: `30`). |
| `redrive_policy` | `object` | No | Dead-letter queue settings: `{ dead_letter_target_arn, max_receive_count }`. |
| `kms_master_key_id` | `string` | No | KMS key ARN for server-side encryption. |
| `kms_data_key_reuse_period_seconds` | `number` | No | Time in seconds for data key reuse. |
| `policy_json` | `string` | No | JSON-encoded policy attached to the queue. |
| `tags` | `map(string)` | No | Per-queue tags merged with global tags. |

## Outputs

| Name | Description |
|------|-------------|
| `queue_ids` | Map of logical queue keys to SQS queue IDs (URLs). |
| `queue_arns` | Map of logical queue keys to SQS queue ARNs. |

## Usage

```hcl
module "aws_sqs" {
  source = "../../modules/application_integration/aws_sqs"

  region = var.region
  tags   = {
    Environment = "dev"
    Team        = "platform"
  }

  queues = {
    standard_example = {
      name                      = "example-standard-queue"
      message_retention_seconds = 345600
    }

    fifo_example = {
      name                        = "example-fifo-queue" # .fifo will be appended if missing
      fifo_queue                  = true
      content_based_deduplication = true
      visibility_timeout_seconds  = 60
    }
  }
}
```

All queues are tagged with `CreatedDate` from `locals.created_date` in addition to global and per-queue tags.
