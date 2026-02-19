# Local helpers and stable created date

locals {
  # ISO 8601 timestamp used in tags
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Convenience aliases
  compute_environments = var.compute_environments
  job_queues           = var.job_queues
  job_definitions      = var.job_definitions

  # Flatten compute environment references for job queues
  # Map job queue key -> list of compute environment ARNs
  job_queue_compute_envs = {
    for jq_key, jq in var.job_queues :
    jq_key => [
      for env_key in jq.compute_environment_keys :
      aws_batch_compute_environment.compute_env[env_key].arn
    ]
  }
}
