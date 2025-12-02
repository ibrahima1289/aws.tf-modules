module "aws_kms" {
  source = "../../modules/security_identity_compliance/aws_kms"

  region = var.region
  tags   = var.tags
  keys   = var.keys
  grants = var.grants
}
