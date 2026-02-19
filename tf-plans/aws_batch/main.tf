# Wrapper plan wiring for the AWS Batch module
# - Passes `region`, `tags`, and Batch resources to the module
# - Exposes key outputs for convenience

module "batch" {
  source = "../../modules/compute/aws_containers/aws_batch"

  region               = var.region
  tags                 = var.tags
  compute_environments = var.compute_environments
  job_queues           = var.job_queues
  job_definitions      = var.job_definitions
}
