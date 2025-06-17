# vpc id output
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}