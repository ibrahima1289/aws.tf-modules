// Output values for AWS DynamoDB wrapper plan

# DynamoDB table outputs from root module
output "tables" {
  description = "Map of DynamoDB table details including ARN, ID, stream ARN, and other attributes."
  value       = module.aws_dynamodb.tables
}

output "table_arns" {
  description = "Map of table names to their ARNs."
  value       = module.aws_dynamodb.table_arns
}

output "table_ids" {
  description = "Map of table names to their IDs."
  value       = module.aws_dynamodb.table_ids
}

output "stream_arns" {
  description = "Map of table names to their stream ARNs (only for tables with streams enabled)."
  value       = module.aws_dynamodb.stream_arns
}

output "read_autoscaling_targets" {
  description = "Map of table read autoscaling target details."
  value       = module.aws_dynamodb.read_autoscaling_targets
}

output "write_autoscaling_targets" {
  description = "Map of table write autoscaling target details."
  value       = module.aws_dynamodb.write_autoscaling_targets
}
