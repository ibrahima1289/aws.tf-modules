#############################################
# AWS Lambda Module - Outputs               #
#############################################

output "function_name" {
  description = "Lambda function name"
  value       = try(aws_lambda_function.function[0].function_name, null)
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = try(aws_lambda_function.function[0].arn, null)
}

output "role_arn" {
  description = "IAM role ARN used by the Lambda"
  value       = coalesce(var.role_arn, try(aws_iam_role.lambda_role[0].arn, null))
}

output "function_url" {
  description = "Function URL"
  value       = try(aws_lambda_function_url.url[0].function_url, null)
}

output "dlq_arn" {
  description = "Dead letter queue ARN"
  value       = try(aws_sqs_queue.dlq[0].arn, null)
}
