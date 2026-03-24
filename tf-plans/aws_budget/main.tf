# AWS Budget wrapper plan
# Calls the root module and passes all variables through.
# This wrapper provides a repeatable plan/apply workflow with example tfvars.

# Step 1: Call the reusable AWS Budgets module.
module "budget" {
  source = "../../modules/cloud_financial_management/aws_budget"

  # Step 2: Set region and merge wrapper-level tags with the auto-generated created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass the full list of budget definitions from wrapper input variables.
  budgets = var.budgets
}
