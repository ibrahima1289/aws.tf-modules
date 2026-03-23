# Step 1: Call the reusable AWS ACM module.
module "certificate_manager" {
  source = "../../modules/security_identity_compliance/aws_certificate_manager"

  # Step 2: Set region and apply wrapper tags with created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Create multiple certificates from wrapper input.
  certificates = var.certificates
}
