# Step 1: Call the reusable AWS Secrets Manager module.
module "secrets_manager" {
  source = "../../modules/security_identity_compliance/aws_secrets_manager"

  # Step 2: Set region and apply wrapper-level tags merged with created_date.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass the full list of secret definitions from wrapper input variables.
  secrets = var.secrets
}
