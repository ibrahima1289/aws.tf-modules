# Wrapper plan wiring for the API Gateway module
# - Passes `region`, `tags`, and `apis` to the module
# - Exposes key outputs for convenience

module "api_gw" {
  source = "../../modules/networking_content_delivery/aws_api_gateway"

  region = var.region
  tags   = var.tags
  apis   = var.apis
}
