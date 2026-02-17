// Wrapper plan for AWS SNS module
// Delegates topic and subscription creation to the root module.

module "aws_sns" {
  source = "../../modules/application_integration/aws_sns"

  // Region passed through from wrapper
  region = var.region

  // Global tags applied to all topics and subscriptions
  tags = var.tags

  // Topics map delegated to the root module
  topics = var.topics
}
