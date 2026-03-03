// Output values for AWS DynamoDB module

# DynamoDB table outputs
output "tables" {
  description = "Map of DynamoDB table details including ARN, ID, stream ARN, and other attributes."
  value = {
    for key, table in aws_dynamodb_table.table : key => {
      id                  = table.id
      arn                 = table.arn
      name                = table.name
      hash_key            = table.hash_key
      range_key           = table.range_key
      billing_mode        = table.billing_mode
      read_capacity       = table.read_capacity
      write_capacity      = table.write_capacity
      stream_arn          = table.stream_arn
      stream_label        = table.stream_label
      stream_enabled      = table.stream_enabled
      table_class         = table.table_class
      deletion_protection = table.deletion_protection_enabled
      tags_all            = table.tags_all
    }
  }
}

# Individual table ARNs
output "table_arns" {
  description = "Map of table names to their ARNs."
  value = {
    for key, table in aws_dynamodb_table.table : key => table.arn
  }
}

# Individual table IDs
output "table_ids" {
  description = "Map of table names to their IDs."
  value = {
    for key, table in aws_dynamodb_table.table : key => table.id
  }
}

# Stream ARNs (for tables with streams enabled)
output "stream_arns" {
  description = "Map of table names to their stream ARNs (only for tables with streams enabled)."
  value = {
    for key, table in aws_dynamodb_table.table : key => table.stream_arn
    if table.stream_enabled
  }
}

# Autoscaling target outputs (if autoscaling is enabled)
output "read_autoscaling_targets" {
  description = "Map of table read autoscaling target details."
  value = {
    for key, target in aws_appautoscaling_target.table_read : key => {
      service_namespace  = target.service_namespace
      scalable_dimension = target.scalable_dimension
      resource_id        = target.resource_id
      min_capacity       = target.min_capacity
      max_capacity       = target.max_capacity
    }
  }
}

output "write_autoscaling_targets" {
  description = "Map of table write autoscaling target details."
  value = {
    for key, target in aws_appautoscaling_target.table_write : key => {
      service_namespace  = target.service_namespace
      scalable_dimension = target.scalable_dimension
      resource_id        = target.resource_id
      min_capacity       = target.min_capacity
      max_capacity       = target.max_capacity
    }
  }
}
