output "asg_names" {
  value       = module.aws_asg.asg_names
  description = "Map of ASG names keyed by ASG key"
}

output "asg_arns" {
  value       = module.aws_asg.asg_arns
  description = "Map of ASG ARNs keyed by ASG key"
}

output "asg_desired_capacities" {
  value       = module.aws_asg.asg_desired_capacities
  description = "Map of desired capacities keyed by ASG key"
}

output "asg_min_max_sizes" {
  value       = module.aws_asg.asg_min_max_sizes
  description = "Map of min/max sizes keyed by ASG key"
}
