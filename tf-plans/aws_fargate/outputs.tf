# Outputs for the AWS Fargate wrapper.
# Pass through all module outputs for use in downstream configurations.

output "cluster_arns" {
  description = "Map of cluster key to ECS cluster ARN."
  value       = module.fargate.cluster_arns
}

output "cluster_names" {
  description = "Map of cluster key to ECS cluster name."
  value       = module.fargate.cluster_names
}

output "task_definition_arns" {
  description = "Map of task definition key to task definition ARN (with revision)."
  value       = module.fargate.task_definition_arns
}

output "task_definition_revisions" {
  description = "Map of task definition key to the latest revision number."
  value       = module.fargate.task_definition_revisions
}

output "service_arns" {
  description = "Map of service key to ECS service ARN."
  value       = module.fargate.service_arns
}

output "service_names" {
  description = "Map of service key to ECS service name."
  value       = module.fargate.service_names
}

output "log_group_names" {
  description = "Map of task definition key to CloudWatch log group name."
  value       = module.fargate.log_group_names
}

output "log_group_arns" {
  description = "Map of task definition key to CloudWatch log group ARN."
  value       = module.fargate.log_group_arns
}
