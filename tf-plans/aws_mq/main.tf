// Wrapper plan for AWS MQ module
// Delegates broker creation to the root module and keeps inputs simple.

module "aws_mq" {
  source = "../../modules/application_integration/aws_mq"

  // Region passed through from wrapper
  region = var.region

  // Global tags applied to all Amazon MQ resources
  tags = var.tags

  // Brokers map delegated to the root module
  brokers = var.brokers
}
