// Outputs from the AWS SNS wrapper

output "topic_arns" {
  description = "Map of topic keys to SNS topic ARNs from the module."
  value       = module.aws_sns.topic_arns
}

output "topic_names" {
  description = "Map of topic keys to SNS topic names from the module."
  value       = module.aws_sns.topic_names
}

output "subscription_arns" {
  description = "Map of subscription keys to SNS subscription ARNs from the module."
  value       = module.aws_sns.subscription_arns
}
