module "security_group" {
  source        = "../../modules/security_identity_compliance/aws_security_group"
  region        = var.region
  defined_name  = var.defined_name
  description   = var.description
  vpc_id        = var.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  tags          = merge(var.tags, { created_date = local.created_date })
}
