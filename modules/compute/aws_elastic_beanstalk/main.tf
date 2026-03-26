# Terraform AWS Elastic Beanstalk Module
# Manages Elastic Beanstalk applications and environments.
# Supports multiple applications and environments via for_each.
# Environment settings (instance type, VPC, ASG, env vars) are assembled
# from convenience variables in locals.tf and injected via dynamic setting blocks.

# ─── Step 1: Elastic Beanstalk Applications ───────────────────────────────────
# Each application acts as a logical container for its environments and versions.
# Create one application per entry in var.applications.
resource "aws_elastic_beanstalk_application" "app" {
  for_each = local.applications_map

  name        = each.value.name
  description = each.value.description

  # Step 1a: Version lifecycle policy — automatically deletes old application
  # versions to prevent hitting the 1,000-version hard account limit.
  # Omit this block to retain all versions indefinitely.
  dynamic "appversion_lifecycle" {
    for_each = each.value.appversion_lifecycle != null ? [each.value.appversion_lifecycle] : []
    content {
      service_role          = appversion_lifecycle.value.service_role
      max_count             = appversion_lifecycle.value.max_count
      max_age_in_days       = appversion_lifecycle.value.max_age_in_days
      delete_source_from_s3 = appversion_lifecycle.value.delete_source_from_s3
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

# ─── Step 2: Elastic Beanstalk Environments ───────────────────────────────────
# Each environment is a live collection of AWS resources (EC2 instances, ALB,
# ASG, CloudWatch) running one version of the application.
# Settings are fed from local.environment_settings, which translates all
# convenience variables into EBS namespace/option_name/value triplets.
resource "aws_elastic_beanstalk_environment" "env" {
  for_each = local.environments_map

  name                = each.value.name
  description         = each.value.description
  application         = aws_elastic_beanstalk_application.app[each.value.application_key].name
  solution_stack_name = each.value.solution_stack

  # Step 2a: Tier — "WebServer" handles HTTP/HTTPS traffic behind a load balancer;
  # "Worker" pulls tasks from an SQS queue for background processing.
  tier = each.value.tier

  # Step 2b: Inject all environment settings as individual setting blocks.
  # The full list is built in locals.tf from the convenience variables and
  # custom_settings list, ensuring uniform block structure throughout.
  dynamic "setting" {
    for_each = local.environment_settings[each.key]
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
      resource  = setting.value.resource
    }
  }

  tags = merge(local.common_tags, each.value.tags)

  # Environments must be created after their parent application.
  depends_on = [aws_elastic_beanstalk_application.app]
}
