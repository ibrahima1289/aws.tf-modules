# Map outputs for created Batch resources

# Compute environment outputs
output "compute_environment_arns" {
  description = "Map of compute environment key to ARN"
  value       = { for k, v in aws_batch_compute_environment.compute_env : k => v.arn }
}

output "compute_environment_names" {
  description = "Map of compute environment key to name"
  value       = { for k, v in aws_batch_compute_environment.compute_env : k => v.name }
}

output "compute_environment_ecs_cluster_arns" {
  description = "Map of compute environment key to ECS cluster ARN"
  value       = { for k, v in aws_batch_compute_environment.compute_env : k => v.ecs_cluster_arn }
}

# Job queue outputs
output "job_queue_arns" {
  description = "Map of job queue key to ARN"
  value       = { for k, v in aws_batch_job_queue.job_queue : k => v.arn }
}

output "job_queue_names" {
  description = "Map of job queue key to name"
  value       = { for k, v in aws_batch_job_queue.job_queue : k => v.name }
}

# Job definition outputs
output "job_definition_arns" {
  description = "Map of job definition key to ARN"
  value       = { for k, v in aws_batch_job_definition.job_def : k => v.arn }
}

output "job_definition_names" {
  description = "Map of job definition key to name"
  value       = { for k, v in aws_batch_job_definition.job_def : k => v.name }
}

output "job_definition_revisions" {
  description = "Map of job definition key to revision number"
  value       = { for k, v in aws_batch_job_definition.job_def : k => v.revision }
}
