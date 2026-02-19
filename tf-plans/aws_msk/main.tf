// Wrapper plan for AWS MSK module
// Delegates MSK cluster creation to the root module and keeps inputs simple.

module "aws_msk" {
  source = "../../modules/analytics/aws-msk"

  region   = var.region
  tags     = var.tags
  clusters = var.clusters
}
