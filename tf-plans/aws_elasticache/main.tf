// Wrapper plan for AWS ElastiCache module
// Delegates cluster and replication group creation to the root module and keeps inputs simple.

module "aws_elasticache" {
  source = "../../modules/databases/non-relational/aws_elasticache"

  // Region passed through from wrapper
  region = var.region

  // Global tags applied to all ElastiCache resources
  tags = var.tags

  // Clusters map delegated to the root module (for standalone Memcached or Redis)
  clusters = var.clusters

  // Replication groups map delegated to the root module (for Redis with replication/HA)
  replication_groups = var.replication_groups
}
