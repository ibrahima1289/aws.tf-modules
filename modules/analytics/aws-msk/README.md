# AWS MSK Terraform Module

This module manages one or more Amazon Managed Streaming for Apache Kafka (MSK) clusters with safe defaults, security options, logging, monitoring, and consistent tagging.

## Requirements

- Terraform >= 1.3.0
- AWS Provider >= 5.0

## Inputs

| Name       | Type          | Required | Description |
|------------|---------------|----------|-------------|
| `region`   | `string`      | Yes      | AWS region to use for MSK clusters. |
| `tags`     | `map(string)` | No       | Global tags applied to all MSK resources (default: `{}`). |
| `clusters` | `map(object)` | Yes      | Map of MSK clusters to create; key is a logical name. |

Cluster object schema (per entry in `clusters`):

| Field                                       | Type           | Required | Description |
|---------------------------------------------|----------------|----------|-------------|
| `cluster_name`                              | `string`       | Yes      | MSK cluster name. |
| `kafka_version`                             | `string`       | Yes      | Apache Kafka version (e.g., `"3.6.0"`). |
| `number_of_broker_nodes`                    | `number`       | No       | Total number of broker nodes (default: `3`). |
| `instance_type`                             | `string`       | Yes      | Broker instance type (e.g., `"kafka.m5.large"`). |
| `client_subnets`                            | `list(string)` | Yes      | Subnet IDs for broker nodes (typically across AZs). |
| `security_groups`                           | `list(string)` | Yes      | Security group IDs for broker nodes. |
| `ebs_volume_size`                           | `number`       | No       | EBS storage size (GiB) per broker (default: `1000`). |
| `configuration_arn`                         | `string`       | No       | ARN of an MSK configuration to apply. |
| `configuration_revision`                    | `number`       | No       | Revision of the MSK configuration. |
| `encryption_at_rest_kms_key_arn`            | `string`       | No       | KMS key ARN for encryption at rest. |
| `encryption_in_transit_client_broker`       | `string`       | No       | Client-broker encryption mode (default: `"TLS"`). |
| `encryption_in_transit_in_cluster`          | `bool`         | No       | Whether encryption in-cluster is enabled (default: `true`). |
| `logging_cloudwatch_enabled`                | `bool`         | No       | Enable CloudWatch Logs for brokers. |
| `logging_cloudwatch_log_group`              | `string`       | No       | CloudWatch log group for broker logs. |
| `logging_s3_enabled`                        | `bool`         | No       | Enable S3 logging for brokers. |
| `logging_s3_bucket`                         | `string`       | No       | S3 bucket for broker logs. |
| `logging_s3_prefix`                         | `string`       | No       | S3 key prefix for broker logs. |
| `logging_firehose_enabled`                  | `bool`         | No       | Enable Firehose logging for brokers. |
| `logging_firehose_stream`                   | `string`       | No       | Firehose delivery stream name. |
| `client_auth_sasl_scram`                    | `bool`         | No       | Enable SASL/SCRAM authentication. |
| `client_auth_sasl_iam`                      | `bool`         | No       | Enable IAM-based SASL authentication. |
| `client_auth_tls_enabled`                   | `bool`         | No       | Enable TLS mutual authentication. |
| `client_auth_unauthenticated`               | `bool`         | No       | Allow unauthenticated access. |
| `enhanced_monitoring`                       | `string`       | No       | Enhanced monitoring level (default: `"DEFAULT"`). |
| `open_monitoring_prometheus_jmx_exporter`   | `bool`         | No       | Enable Prometheus JMX exporter. |
| `open_monitoring_prometheus_node_exporter`  | `bool`         | No       | Enable Prometheus Node exporter. |
| `tags`                                      | `map(string)`  | No       | Per-cluster tags merged with global tags. |

## Outputs

| Name                | Description |
|---------------------|-------------|
| `cluster_arns`      | Map of cluster keys to MSK cluster ARNs. |
| `cluster_names`     | Map of cluster keys to MSK cluster names. |
| `bootstrap_brokers` | Map of cluster keys to bootstrap broker connection strings. |

## Usage

```hcl
module "aws_msk" {
  source = "../../modules/analytics/aws-msk"

  region = var.region
  tags = {
    Environment = "dev"
    Team        = "platform"
  }

  clusters = {
    example_msk_basic = {
      cluster_name           = "example-msk-basic"
      kafka_version          = "3.6.0"
      number_of_broker_nodes = 3
      instance_type          = "kafka.m5.large"
      client_subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
      security_groups        = ["sg-aaa"]
      ebs_volume_size        = 1000
    }
  }
}
```

All MSK clusters are tagged with `CreatedDate` from `locals.created_date` in addition to global and per-cluster tags.
