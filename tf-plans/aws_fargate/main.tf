# AWS Fargate wrapper plan.
# Calls the root Fargate module and passes all variables through.
# Task definitions are defined in locals.tf (container JSON loaded from templates/).

# Step 1: Call the reusable Fargate module.
module "fargate" {
  source = "../../modules/compute/aws_serverless/aws_fargate"

  # Step 2: Set region and merge wrapper-level tags with the auto-generated created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass cluster definitions.
  clusters = var.clusters

  # Step 4: Pass task definitions (built in locals.tf with file() container JSON).
  task_definitions = local.task_definitions_config

  # Step 5: Pass service definitions.
  services = var.services
}
