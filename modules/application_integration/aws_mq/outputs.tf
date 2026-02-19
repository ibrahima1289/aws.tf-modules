// Outputs for AWS MQ module

output "broker_arns" {
  description = "Map of broker keys to Amazon MQ broker ARNs."
  value       = { for k, b in aws_mq_broker.mq : k => b.arn }
}

output "broker_ids" {
  description = "Map of broker keys to Amazon MQ broker IDs."
  value       = { for k, b in aws_mq_broker.mq : k => b.id }
}

output "broker_names" {
  description = "Map of broker keys to Amazon MQ broker names."
  value       = { for k, b in aws_mq_broker.mq : k => b.broker_name }
}
