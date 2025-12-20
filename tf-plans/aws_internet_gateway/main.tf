module "internet_gateway" {
  source = "../../modules/networking_content_delivery/aws_internet_gateway"

  # Required
  region = var.region

  # Conditionally required when enabled
  vpc_id = var.vpc_id

  # Optional
  enable_internet_gateway = var.enable_internet_gateway
  name                    = var.name
  tags                    = merge(var.tags, { created_date = local.created_date })
}
