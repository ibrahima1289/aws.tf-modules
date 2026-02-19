// Root module for AWS Managed Streaming for Apache Kafka (MSK) clusters
// Supports creating multiple MSK clusters with security, logging, and monitoring
// while avoiding nulls via normalized locals and consistent tagging.

resource "aws_msk_cluster" "msk" {
  // Create one MSK cluster per entry in the clusters map
  for_each = local.clusters

  // Core cluster settings
  cluster_name           = each.value.cluster_name
  kafka_version          = each.value.kafka_version
  number_of_broker_nodes = each.value.number_of_broker_nodes

  // Broker node group configuration
  broker_node_group_info {
    instance_type   = each.value.instance_type
    client_subnets  = each.value.client_subnets
    security_groups = each.value.security_groups

    storage_info {
      ebs_storage_info {
        volume_size = each.value.ebs_volume_size
      }
    }
  }

  // Optional MSK configuration (only when ARN and revision are provided)
  dynamic "configuration_info" {
    for_each = each.value.configuration_arn != null && each.value.configuration_revision != null ? [1] : []
    content {
      arn      = each.value.configuration_arn
      revision = each.value.configuration_revision
    }
  }

  // Encryption configuration (at rest + in transit)
  encryption_info {
    encryption_at_rest_kms_key_arn = each.value.encryption_at_rest_kms_key_arn
    encryption_in_transit {
      client_broker = each.value.encryption_in_transit_client_broker
      in_cluster    = each.value.encryption_in_transit_in_cluster
    }
  }

  // Client authentication (SASL, TLS, unauthenticated) created only when requested
  dynamic "client_authentication" {
    for_each = (coalesce(each.value.client_auth_sasl_scram, false) || coalesce(each.value.client_auth_sasl_iam, false) || coalesce(each.value.client_auth_tls_enabled, false)) ? [1] : []
    content {
      dynamic "sasl" {
        for_each = (coalesce(each.value.client_auth_sasl_scram, false) || coalesce(each.value.client_auth_sasl_iam, false)) ? [1] : []
        content {
          scram = coalesce(each.value.client_auth_sasl_scram, false)
          iam   = coalesce(each.value.client_auth_sasl_iam, false)
        }
      }
    }
  }

  // Broker logging configuration: CloudWatch, S3, and/or Firehose
  dynamic "logging_info" {
    for_each = (coalesce(each.value.logging_cloudwatch_enabled, false) || coalesce(each.value.logging_s3_enabled, false) || coalesce(each.value.logging_firehose_enabled, false)) ? [1] : []
    content {
      broker_logs {
        dynamic "cloudwatch_logs" {
          for_each = coalesce(each.value.logging_cloudwatch_enabled, false) ? [1] : []
          content {
            enabled   = true
            log_group = each.value.logging_cloudwatch_log_group
          }
        }

        dynamic "s3" {
          for_each = coalesce(each.value.logging_s3_enabled, false) ? [1] : []
          content {
            enabled = true
            bucket  = each.value.logging_s3_bucket
            prefix  = each.value.logging_s3_prefix
          }
        }

        dynamic "firehose" {
          for_each = coalesce(each.value.logging_firehose_enabled, false) ? [1] : []
          content {
            enabled         = true
            delivery_stream = each.value.logging_firehose_stream
          }
        }
      }
    }
  }

  // Open monitoring with Prometheus exporters
  dynamic "open_monitoring" {
    for_each = (coalesce(each.value.open_monitoring_prometheus_jmx_exporter, false) || coalesce(each.value.open_monitoring_prometheus_node_exporter, false)) ? [1] : []
    content {
      prometheus {
        dynamic "jmx_exporter" {
          for_each = coalesce(each.value.open_monitoring_prometheus_jmx_exporter, false) ? [1] : []
          content {
            enabled_in_broker = true
          }
        }

        dynamic "node_exporter" {
          for_each = coalesce(each.value.open_monitoring_prometheus_node_exporter, false) ? [1] : []
          content {
            enabled_in_broker = true
          }
        }
      }
    }
  }

  // Enhanced monitoring level
  enhanced_monitoring = coalesce(each.value.enhanced_monitoring, "DEFAULT")

  // Tags: global + per-cluster + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

