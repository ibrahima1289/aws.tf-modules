output "internet_gateway_id" {
  description = "ID of the created Internet Gateway"
  value       = module.internet_gateway.internet_gateway_id
}

output "internet_gateway_arn" {
  description = "ARN of the created Internet Gateway"
  value       = module.internet_gateway.internet_gateway_arn
}
