# Wire inputs to the CloudFront module

module "cloudfront" {
  source = "../../modules/networking_content_delivery/aws_cloudFront"

  # Pass variables to the module
  region        = var.region
  tags          = var.tags
  distributions = var.distributions
}
