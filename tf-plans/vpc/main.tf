module "vpc" {
  source               = "../../modules/networking_content_delivery/vpc" # Uncomment for local module instead of remote on
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  region               = var.region
  tags                 = var.tags
}