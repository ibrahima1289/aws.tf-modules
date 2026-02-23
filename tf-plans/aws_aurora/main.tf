# AWS Aurora Wrapper Module
# This wrapper simplifies the deployment of Aurora clusters with common configurations

# Call the Aurora module with generated configurations
module "aurora" {
  source = "../../modules/databases/relational/aws_aurora"

  # Pass region
  region = var.region

  # Pass generated Aurora clusters configuration
  aurora_clusters = local.aurora_clusters

  # Pass DB subnet groups
  db_subnet_groups = local.db_subnet_groups

  # Pass cluster parameter groups
  db_cluster_parameter_groups = local.db_cluster_parameter_groups

  # Pass instance parameter groups
  db_parameter_groups = local.db_parameter_groups

  # Global clusters can be extended in future if needed
  global_clusters = {}
}
