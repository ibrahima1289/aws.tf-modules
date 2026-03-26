# AWS EBS wrapper plan.
# Calls the root EBS module and passes all variables through.
# Adjust terraform.tfvars to match your volume types, sizes, and EC2 instances.

# Step 1: Call the reusable EBS module.
module "ebs" {
  source = "../../modules/storage/aws_ebs"

  # Step 2: Set region and merge wrapper-level tags with the auto-generated created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass volume definitions from terraform.tfvars.
  volumes = var.volumes

  # Step 4: Pass volume attachment definitions from terraform.tfvars.
  attachments = var.attachments

  # Step 5: Pass snapshot definitions from terraform.tfvars.
  snapshots = var.snapshots
}
