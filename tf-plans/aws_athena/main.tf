# AWS Athena wrapper plan.
# Calls the root Athena module and passes all variables through.
# Named queries are defined in locals.tf (SQL strings loaded from templates/).

# Step 1: Call the reusable Athena module.
module "athena" {
  source = "../../modules/analytics/aws_athena"

  # Step 2: Set region and merge wrapper-level tags with the auto-generated created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass workgroup definitions from terraform.tfvars.
  workgroups = var.workgroups

  # Step 4: Pass database definitions from terraform.tfvars.
  databases = var.databases

  # Step 5: Pass named queries built in locals.tf (SQL loaded from templates/).
  named_queries = local.named_queries_config

  # Step 6: Pass federated data catalog definitions from terraform.tfvars.
  data_catalogs = var.data_catalogs
}
