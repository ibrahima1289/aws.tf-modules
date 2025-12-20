############################################
# Outputs
############################################

output "internet_gateway_id" {
  description = "ID of the created Internet Gateway (null if not created)."
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "internet_gateway_arn" {
  description = "ARN of the created Internet Gateway (null if not created)."
  value       = try(aws_internet_gateway.this[0].arn, null)
}
