// Outputs for AWS SQS module

output "queue_ids" {
  description = "Map of queue keys to SQS queue IDs (URLs)."
  value       = { for k, q in aws_sqs_queue.sqs : k => q.id }
}

output "queue_arns" {
  description = "Map of queue keys to SQS queue ARNs."
  value       = { for k, q in aws_sqs_queue.sqs : k => q.arn }
}
