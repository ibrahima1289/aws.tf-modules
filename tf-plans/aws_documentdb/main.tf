// Wrapper plan for AWS DocumentDB module
// Creates Secrets Manager secrets when needed, resolves master credentials,
// then delegates all cluster creation to the root module.
// Credential resolution logic lives in locals.tf.

module "aws_documentdb" {
  source = "../../modules/databases/non-relational/aws_documentdb"

  // AWS region for all DocumentDB resources
  region = var.region

  // Global tags merged onto every resource created by the module
  tags = var.tags

  // Clusters map with credentials resolved (from variable or Secrets Manager resource)
  clusters = local.clusters_resolved
}
