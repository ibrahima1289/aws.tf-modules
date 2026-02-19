// Root module for AWS Kinesis
// Supports creating multiple Kinesis Data Streams and Firehose delivery streams
// with safe defaults and consistent tagging.

resource "aws_kinesis_stream" "kinesis" {
  // Create one stream per entry in the streams map
  for_each = local.streams

  // Stream name
  name = each.value.name

  // Provisioned vs on-demand mode
  // Shard count only applies when mode is PROVISIONED; coerce to at least 1
  shard_count = each.value.stream_mode == "PROVISIONED" ? max(1, coalesce(each.value.shard_count, 1)) : null

  // Stream retention and metrics
  retention_period    = each.value.retention_period_hours
  shard_level_metrics = each.value.shard_level_metrics

  // Enable on-demand mode via stream_mode_details when requested
  dynamic "stream_mode_details" {
    for_each = each.value.stream_mode == "ON_DEMAND" ? [1] : []
    content {
      stream_mode = "ON_DEMAND"
    }
  }

  // Server-side encryption (only when enabled and KMS key is provided)
  encryption_type = each.value.encryption_enabled && each.value.kms_key_arn != null ? "KMS" : null
  kms_key_id      = each.value.encryption_enabled && each.value.kms_key_arn != null ? each.value.kms_key_arn : null

  // Tags: global + per-stream + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  // Create one Firehose delivery stream per entry in the firehoses map
  for_each = local.firehoses

  name        = each.value.name
  destination = each.value.destination

  extended_s3_configuration {
    # Only meaningful when destination is S3/extended_s3/redshift, but safe to set when bucket ARN is provided
    bucket_arn = each.value.s3_bucket_arn
    role_arn   = each.value.role_arn
    prefix     = each.value.s3_prefix

    buffering_size     = each.value.s3_buffer_size
    buffering_interval = each.value.s3_buffer_interval

    kms_key_arn = each.value.kms_key_arn
  }

  dynamic "http_endpoint_configuration" {
    for_each = each.value.http_endpoint_url != null ? [1] : []
    content {
      url                = each.value.http_endpoint_url
      name               = each.value.http_endpoint_name
      access_key         = each.value.http_endpoint_access_key
      buffering_size     = each.value.http_endpoint_buffer_size
      buffering_interval = each.value.http_endpoint_buffer_interval

      s3_configuration {
        bucket_arn         = each.value.s3_bucket_arn
        role_arn           = each.value.role_arn
        buffering_size     = each.value.s3_buffer_size
        buffering_interval = each.value.s3_buffer_interval
      }
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}
