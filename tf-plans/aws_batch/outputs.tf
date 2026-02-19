# Expose module outputs at the wrapper level

output "compute_environment_arns" {
  value       = module.batch.compute_environment_arns
  description = "Map of compute environment key to ARN"
}

output "compute_environment_names" {
  value       = module.batch.compute_environment_names
  description = "Map of compute environment key to name"
}

output "job_queue_arns" {
  value       = module.batch.job_queue_arns
  description = "Map of job queue key to ARN"
}

output "job_queue_names" {
  value       = module.batch.job_queue_names
  description = "Map of job queue key to name"
}

output "job_definition_arns" {
  value       = module.batch.job_definition_arns
  description = "Map of job definition key to ARN"
}

output "job_definition_names" {
  value       = module.batch.job_definition_names
  description = "Map of job definition key to name"
}

output "job_definition_revisions" {
  value       = module.batch.job_definition_revisions
  description = "Map of job definition key to revision number"
}
