// Wrapper plan for AWS SQS module
// Delegates queue creation to the root module and keeps inputs simple.

module "aws_sqs" {
  source = "../../modules/application_integration/aws_sqs"

  // Region passed through from wrapper
  region = var.region

  // Global tags applied to all queues
  tags = var.tags

  // Queues map delegated to the root module
  queues = var.queues
}
