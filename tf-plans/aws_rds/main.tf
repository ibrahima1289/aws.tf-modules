# AWS RDS Wrapper Module
# This wrapper simplifies the deployment of multiple RDS instances with common configurations

# Call the RDS module with generated configurations
module "rds" {
  source = "../../modules/databases/relational/aws_rds"

  # Pass region
  region = var.region

  # Pass generated RDS instances configuration
  rds_instances = var.rds_instances

  # Pass DB subnet groups
  db_subnet_groups = var.db_subnet_groups

  # Pass parameter groups
  parameter_groups = var.parameter_groups

  # Option groups can be extended in future if needed
  option_groups = {}
}
