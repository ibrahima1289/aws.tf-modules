// Outputs from the AWS SQS wrapper

output "queue_ids" {
  description = "Map of queue keys to SQS queue IDs (URLs) from the module."
  value       = module.aws_sqs.queue_ids
}

output "queue_arns" {
  description = "Map of queue keys to SQS queue ARNs from the module."
  value       = module.aws_sqs.queue_arns
}
