module "vpc" {
  source                   = "../../modules/networking_content_delivery/vpc"
  region                   = var.region
  vpc_cidr_block           = var.vpc_cidr_block
  defined_name             = var.defined_name
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_subnet_cidrs     = var.private_subnet_cidrs
  tags                     = var.tags
}