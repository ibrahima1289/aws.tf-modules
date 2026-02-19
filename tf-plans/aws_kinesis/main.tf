// Wrapper plan for AWS Kinesis module
// Delegates stream and Firehose creation to the root module and keeps inputs simple.

module "aws_kinesis" {
  source = "../../modules/analytics/aws_kinesis"

  // Region passed through from wrapper
  region = var.region

  // Global tags applied to all Kinesis resources
  tags = var.tags

  // Streams map delegated to the root module
  streams = var.streams

  // Firehose delivery streams delegated to the root module
  firehoses = var.firehoses
}
