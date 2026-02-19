// Outputs from the AWS MQ wrapper

output "broker_arns" {
  description = "Map of broker keys to Amazon MQ broker ARNs from the module."
  value       = module.aws_mq.broker_arns
}

output "broker_ids" {
  description = "Map of broker keys to Amazon MQ broker IDs from the module."
  value       = module.aws_mq.broker_ids
}

output "broker_names" {
  description = "Map of broker keys to Amazon MQ broker names from the module."
  value       = module.aws_mq.broker_names
}
