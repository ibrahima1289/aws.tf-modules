module "security_group" {
  # source        = "git::https://github.com/ibrahima1289/aws.tf-modules/security-group.git?ref=main"
  source        = "../../security-group" # Uncomment for local module instead of remote one
  name          = var.name
  description   = var.description
  vpc_id        = var.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  tags          = var.tags
}
