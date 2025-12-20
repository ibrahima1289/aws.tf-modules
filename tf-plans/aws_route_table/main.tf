module "route_table" {
  source = "../../modules/networking_content_delivery/aws_route_table"

  region = var.region
  vpc_id = var.vpc_id

  # Multiple tables or single-table fallback
  route_tables       = var.route_tables
  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids

  # Fallback single-table values (used only if route_tables is empty)
  name        = var.name
  routes      = var.routes
  subnet_ids  = var.subnet_ids
  set_as_main = var.set_as_main
  tags        = merge(var.tags, { created_date = local.created_date })
}
