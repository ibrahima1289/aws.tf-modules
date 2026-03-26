# AWS Backup wrapper plan.
# Calls the root Backup module and passes all variables through.
# Adjust terraform.tfvars to match your vault, plan, and selection requirements.

# Step 1: Call the reusable AWS Backup module.
module "backup" {
  source = "../../modules/storage/aws_backup"

  # Step 2: Set region and merge wrapper-level tags with the auto-generated created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass vault definitions from terraform.tfvars.
  vaults = var.vaults

  # Step 4: Pass backup plan definitions from terraform.tfvars.
  plans = var.plans

  # Step 5: Pass resource selection definitions from terraform.tfvars.
  selections = var.selections
}
