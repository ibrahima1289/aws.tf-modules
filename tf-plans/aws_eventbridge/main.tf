# AWS EventBridge wrapper plan
# Calls the root EventBridge module and passes all variables through.
# This wrapper provides a repeatable plan/apply workflow with example tfvars.

# Step 1: Call the reusable AWS EventBridge module.
module "eventbridge" {
  source = "../../modules/application_integration/aws_eventbridge"

  # Step 2: Set region and merge wrapper-level tags with the auto-generated created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass custom event bus definitions.
  event_buses = var.event_buses

  # Step 4: Pass rule definitions loaded from locals.tf (JSON fields sourced from templates/).
  rules = local.rules_config

  # Step 5: Pass event archive definitions.
  archives = var.archives
}
