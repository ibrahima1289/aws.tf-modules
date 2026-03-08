// Wrapper plan for AWS DynamoDB module
// Delegates table creation to the root module and keeps inputs simple.

module "aws_dynamodb" {
  source = "../../modules/databases/non-relational/aws_dynamodb"

  // Region passed through from wrapper
  region = var.region

  // Global tags applied to all DynamoDB resources
  tags = var.tags

  // Tables map delegated to the root module (for serverless NoSQL data storage)
  tables = var.tables
}
