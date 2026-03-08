// Root module for AWS DynamoDB table management
// Supports creating multiple DynamoDB tables with various capacity modes, encryption, streams, and backup settings
// Provides consistent configuration patterns with autoscaling, global tables, and advanced features

# ---------------------------------------------------------------------------
# DynamoDB Tables
# ---------------------------------------------------------------------------

# Create DynamoDB tables for serverless NoSQL data storage
resource "aws_dynamodb_table" "table" {
  // Create one table per entry in the tables map
  for_each = local.tables

  // Basic table settings
  name         = each.value.name
  billing_mode = each.value.billing_mode
  hash_key     = each.value.hash_key
  range_key    = each.value.range_key
  table_class  = each.value.table_class

  // Read/write capacity (only for PROVISIONED billing mode)
  read_capacity  = each.value.billing_mode == "PROVISIONED" ? each.value.read_capacity : null
  write_capacity = each.value.billing_mode == "PROVISIONED" ? each.value.write_capacity : null

  // Stream settings for capturing table changes
  stream_enabled   = each.value.stream_enabled
  stream_view_type = each.value.stream_enabled ? each.value.stream_view_type : null

  // Deletion protection to prevent accidental table deletion
  deletion_protection_enabled = each.value.deletion_protection_enabled

  // Attribute definitions (all attributes used in keys or indexes)
  dynamic "attribute" {
    for_each = each.value.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  // Time to Live (TTL) for automatic item expiration
  dynamic "ttl" {
    for_each = coalesce(each.value.ttl_enabled, false) ? [1] : []
    content {
      enabled        = true
      attribute_name = each.value.ttl_attribute_name
    }
  }

  // Global Secondary Indexes (GSI) for alternative query patterns
  dynamic "global_secondary_index" {
    for_each = coalesce(each.value.global_secondary_indexes, [])
    content {
      name               = global_secondary_index.value.name
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = global_secondary_index.value.projection_type == "INCLUDE" ? global_secondary_index.value.non_key_attributes : null
      read_capacity      = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity     = each.value.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null

      // Iterate directly over the key_schema list provided by the caller
      dynamic "key_schema" {
        for_each = global_secondary_index.value.key_schema
        content {
          attribute_name = key_schema.value.attribute_name
          key_type       = key_schema.value.key_type
        }
      }
    }
  }

  // Local Secondary Indexes (LSI) for alternative sort keys with same partition key
  dynamic "local_secondary_index" {
    for_each = coalesce(each.value.local_secondary_indexes, [])
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? local_secondary_index.value.non_key_attributes : null
    }
  }

  // Point-in-time recovery for backup and restore capabilities
  dynamic "point_in_time_recovery" {
    for_each = coalesce(each.value.point_in_time_recovery_enabled, false) ? [1] : []
    content {
      enabled = true
    }
  }

  // Server-side encryption configuration
  dynamic "server_side_encryption" {
    for_each = coalesce(each.value.encryption_enabled, false) ? [1] : []
    content {
      enabled     = true
      kms_key_arn = each.value.kms_key_arn
    }
  }

  // Import table from S3 (if specified)
  dynamic "import_table" {
    for_each = each.value.import_table != null ? [each.value.import_table] : []
    content {
      input_format = import_table.value.input_format

      s3_bucket_source {
        bucket       = import_table.value.s3_bucket_source.bucket
        bucket_owner = import_table.value.s3_bucket_source.bucket_owner
        key_prefix   = import_table.value.s3_bucket_source.key_prefix
      }

      dynamic "input_format_options" {
        for_each = import_table.value.input_format_options != null ? [import_table.value.input_format_options] : []
        content {
          dynamic "csv" {
            for_each = input_format_options.value.csv != null ? [input_format_options.value.csv] : []
            content {
              delimiter   = csv.value.delimiter
              header_list = csv.value.header_list
            }
          }
        }
      }

      input_compression_type = import_table.value.input_compression_type
    }
  }

  // Replica regions for global tables (multi-region replication)
  dynamic "replica" {
    for_each = coalesce(each.value.replica_regions, [])
    content {
      region_name            = replica.value.region_name
      kms_key_arn            = replica.value.kms_key_arn
      propagate_tags         = replica.value.propagate_tags
      point_in_time_recovery = replica.value.point_in_time_recovery
    }
  }

  // Tags: global + per-table + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

# ---------------------------------------------------------------------------
# Auto Scaling Configuration (for PROVISIONED billing mode)
# ---------------------------------------------------------------------------

# Create autoscaling target for table read capacity
resource "aws_appautoscaling_target" "table_read" {
  // Only create for tables with PROVISIONED billing mode and autoscaling enabled
  for_each = {
    for key, table in local.tables : key => table
    if table.billing_mode == "PROVISIONED" && table.enable_autoscaling && table.read_capacity != null
  }

  max_capacity       = each.value.read_max_capacity
  min_capacity       = each.value.read_min_capacity
  resource_id        = "table/${each.value.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"

  depends_on = [aws_dynamodb_table.table]
}

# Create autoscaling policy for table read capacity
resource "aws_appautoscaling_policy" "table_read" {
  for_each = aws_appautoscaling_target.table_read

  name               = "${each.value.resource_id}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = local.tables[each.key].read_target_value
  }
}

# Create autoscaling target for table write capacity
resource "aws_appautoscaling_target" "table_write" {
  // Only create for tables with PROVISIONED billing mode and autoscaling enabled
  for_each = {
    for key, table in local.tables : key => table
    if table.billing_mode == "PROVISIONED" && table.enable_autoscaling && table.write_capacity != null
  }

  max_capacity       = each.value.write_max_capacity
  min_capacity       = each.value.write_min_capacity
  resource_id        = "table/${each.value.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"

  depends_on = [aws_dynamodb_table.table]
}

# Create autoscaling policy for table write capacity
resource "aws_appautoscaling_policy" "table_write" {
  for_each = aws_appautoscaling_target.table_write

  name               = "${each.value.resource_id}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = local.tables[each.key].write_target_value
  }
}

# ---------------------------------------------------------------------------
# Global Secondary Index (GSI) Auto Scaling (for PROVISIONED billing mode)
# ---------------------------------------------------------------------------

# Create autoscaling target for GSI read capacity
resource "aws_appautoscaling_target" "gsi_read" {
  for_each = local.gsi_autoscaling_targets

  max_capacity       = each.value.max
  min_capacity       = each.value.min
  resource_id        = "table/${each.value.table_name}/index/${each.value.index_name}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"

  depends_on = [aws_dynamodb_table.table]
}

# Create autoscaling policy for GSI read capacity
resource "aws_appautoscaling_policy" "gsi_read" {
  for_each = aws_appautoscaling_target.gsi_read

  name               = "${each.value.resource_id}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = local.gsi_autoscaling_targets[each.key].target
  }
}

# Create autoscaling target for GSI write capacity
resource "aws_appautoscaling_target" "gsi_write" {
  for_each = local.gsi_write_autoscaling_targets

  max_capacity       = each.value.max
  min_capacity       = each.value.min
  resource_id        = "table/${each.value.table_name}/index/${each.value.index_name}"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"

  depends_on = [aws_dynamodb_table.table]
}

# Create autoscaling policy for GSI write capacity
resource "aws_appautoscaling_policy" "gsi_write" {
  for_each = aws_appautoscaling_target.gsi_write

  name               = "${each.value.resource_id}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  service_namespace  = each.value.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = local.gsi_write_autoscaling_targets[each.key].target
  }
}
