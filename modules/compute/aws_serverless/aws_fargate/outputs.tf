# Outputs for the AWS Fargate Module.

output "cluster_arns" {
  description = "Map of cluster key to ECS cluster ARN."
  value       = { for k, v in aws_ecs_cluster.cluster : k => v.arn }
}

output "cluster_names" {
  description = "Map of cluster key to ECS cluster name."
  value       = { for k, v in aws_ecs_cluster.cluster : k => v.name }
}

output "task_definition_arns" {
  description = "Map of task definition key to task definition ARN (includes revision)."
  value       = { for k, v in aws_ecs_task_definition.task : k => v.arn }
}

output "task_definition_revisions" {
  description = "Map of task definition key to the latest active revision number."
  value       = { for k, v in aws_ecs_task_definition.task : k => v.revision }
}

output "service_arns" {
  description = "Map of service key to ECS service ARN."
  value       = { for k, v in aws_ecs_service.service : k => v.id }
}

output "service_names" {
  description = "Map of service key to ECS service name."
  value       = { for k, v in aws_ecs_service.service : k => v.name }
}

output "log_group_names" {
  description = "Map of task definition key to CloudWatch log group name."
  value       = { for k, v in aws_cloudwatch_log_group.task : k => v.name }
}

output "log_group_arns" {
  description = "Map of task definition key to CloudWatch log group ARN."
  value       = { for k, v in aws_cloudwatch_log_group.task : k => v.arn }
}
