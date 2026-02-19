# AWS Kinesis Terraform Module

This module manages one or more Amazon Kinesis Data Streams and optional Kinesis Data Firehose delivery streams with safe defaults, optional encryption, and tagging.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name        | Type          | Required | Description |
|-------------|---------------|----------|-------------|
| `region`    | `string`      | Yes      | AWS region to use for Kinesis resources. |
| `tags`      | `map(string)` | No       | Global tags applied to all Kinesis resources (default: `{}`). |
| `streams`   | `map(object)` | Yes      | Map of Kinesis Data Streams to create; key is a logical name. |
| `firehoses` | `map(object)` | No       | Map of Kinesis Data Firehose delivery streams to create; key is a logical name. |

Stream object schema (per entry in `streams`):

| Field                   | Type           | Required | Description |
|-------------------------|----------------|----------|-------------|
| `name`                  | `string`       | Yes      | Stream name. |
| `stream_mode`           | `string`       | No       | `"PROVISIONED"` (default) or `"ON_DEMAND"`. |
| `shard_count`           | `number`       | No       | Number of shards (used when `stream_mode = "PROVISIONED"`; default: `1`). |
| `retention_period_hours` | `number`      | No       | Stream retention period in hours (default: `24`). |
| `shard_level_metrics`   | `list(string)` | No       | Shard-level metrics to enable (e.g., `"IncomingBytes"`, `"OutgoingRecords"`). |
| `encryption_enabled`    | `bool`         | No       | Whether to enable KMS encryption for the stream (default: `false`). |
| `kms_key_arn`           | `string`       | No       | KMS key ARN used when `encryption_enabled = true`. |
| `tags`                  | `map(string)`  | No       | Per-stream tags merged with global tags. |

Firehose object schema (per entry in `firehoses`):

| Field                             | Type          | Required | Description |
|-----------------------------------|---------------|----------|-------------|
| `name`                            | `string`      | Yes      | Firehose delivery stream name. |
| `destination`                     | `string`      | Yes      | Destination type (e.g., `"s3"`, `"extended_s3"`, `"http_endpoint"`, `"redshift"`). |
| `role_arn`                        | `string`      | Yes      | IAM role ARN assumed by Kinesis Firehose. |
| `s3_bucket_arn`                   | `string`      | No       | S3 bucket ARN for S3/extended_s3/redshift destinations. |
| `s3_prefix`                       | `string`      | No       | S3 object prefix. |
| `s3_buffer_size`                  | `number`      | No       | S3 buffer size in MB (default: `5`). |
| `s3_buffer_interval`              | `number`      | No       | S3 buffer interval in seconds (default: `300`). |
| `kms_key_arn`                     | `string`      | No       | KMS key ARN for Firehose encryption. |
| `http_endpoint_url`               | `string`      | No       | HTTP endpoint URL when `destination = "http_endpoint"`. |
| `http_endpoint_name`              | `string`      | No       | Name for the HTTP endpoint configuration. |
| `http_endpoint_access_key`        | `string`      | No       | Access key for the HTTP endpoint. |
| `http_endpoint_buffer_size`       | `number`      | No       | HTTP endpoint buffer size in MB (default: `5`). |
| `http_endpoint_buffer_interval`   | `number`      | No       | HTTP endpoint buffer interval in seconds (default: `300`). |
| `tags`                            | `map(string)` | No       | Per-firehose tags merged with global tags. |

## Outputs

| Name             | Description |
|------------------|-------------|
| `stream_arns`    | Map of stream keys to Kinesis stream ARNs. |
| `stream_names`   | Map of stream keys to Kinesis stream names. |
| `stream_ids`     | Map of stream keys to Kinesis stream IDs. |
| `firehose_arns`  | Map of firehose keys to Firehose delivery stream ARNs. |
| `firehose_names` | Map of firehose keys to Firehose delivery stream names. |

## Usage

```hcl
module "aws_kinesis" {
  source = "../../modules/analytics/aws_kinesis"

  region = var.region
  tags   = {
    Environment = "dev"
    Team        = "platform"
  }

  streams = {
    example_standard = {
      name                   = "example-kinesis-stream"
      stream_mode            = "PROVISIONED"
      shard_count            = 2
      retention_period_hours = 48
    }
  }

  firehoses = {
    example_firehose_s3 = {
      name        = "example-firehose-to-s3"
      destination = "s3"
      role_arn    = "arn:aws:iam::123456789012:role/example-firehose-role" # replace with your role ARN

      s3_bucket_arn        = "arn:aws:s3:::my-firehose-bucket" # replace with your bucket ARN
      s3_prefix            = "firehose/"
      s3_buffer_size       = 5
      s3_buffer_interval   = 300
      kms_key_arn          = null

      tags = {
        Purpose = "analytics-firehose-s3"
      }
    }
  }
}
```

All streams and Firehose delivery streams are tagged with `CreatedDate` from `locals.created_date` in addition to global and per-resource tags.
