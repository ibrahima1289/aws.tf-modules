# Step 1: Call the reusable AWS NACL module.
module "nacl" {
  source = "../../modules/security_identity_compliance/aws_nacl"

  # Step 2: Set region and apply wrapper tags with created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Create multiple NACLs with subnet associations and rules.
  nacls = var.nacls
}
