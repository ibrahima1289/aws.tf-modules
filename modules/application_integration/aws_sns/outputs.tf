// Outputs for AWS SNS module

output "topic_arns" {
  description = "Map of topic keys to SNS topic ARNs."
  value       = { for k, t in aws_sns_topic.sns : k => t.arn }
}

output "topic_names" {
  description = "Map of topic keys to SNS topic names."
  value       = { for k, t in aws_sns_topic.sns : k => t.name }
}

output "subscription_arns" {
  description = "Map of subscription keys to SNS subscription ARNs."
  value       = { for k, s in aws_sns_topic_subscription.sns : k => s.arn }
}
