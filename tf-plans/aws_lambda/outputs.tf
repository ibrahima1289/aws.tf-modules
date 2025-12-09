#############################################
# Wrapper - Outputs                         #
#############################################

output "function_name" {
  value = module.lambda.function_name
}

output "function_arn" {
  value = module.lambda.function_arn
}

output "role_arn" {
  value = module.lambda.role_arn
}

output "function_url" {
  value = module.lambda.function_url
}

output "dlq_arn" {
  value = module.lambda.dlq_arn
}