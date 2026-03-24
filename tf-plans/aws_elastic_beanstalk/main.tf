# AWS Elastic Beanstalk wrapper plan.
# Calls the root Elastic Beanstalk module and passes all variables through.
# Applications and environments are defined in terraform.tfvars.

# Step 1: Call the reusable Elastic Beanstalk module.
module "beanstalk" {
  source = "../../modules/compute/aws_elastic_beanstalk"

  # Step 2: Set region and merge wrapper-level tags with the auto-generated created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass application definitions (logical containers for environments + versions).
  applications = var.applications

  # Step 4: Pass environment definitions (EC2, ALB, ASG, settings).
  environments = var.environments
}
