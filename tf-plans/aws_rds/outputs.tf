# Outputs from AWS RDS wrapper module

# All RDS instance details
output "rds_instances" {
  description = "Map of all RDS instance details"
  value       = module.rds.rds_instances
}

# Database endpoints for connection
output "db_endpoints" {
  description = "Map of database connection endpoints"
  value       = module.rds.db_instance_endpoints
}

# Database addresses (hostname only)
output "db_addresses" {
  description = "Map of database addresses"
  value       = module.rds.db_instance_addresses
}

# Database ARNs
output "db_arns" {
  description = "Map of database ARNs"
  value       = module.rds.db_instance_arns
}

# Database ports
output "db_ports" {
  description = "Map of database port numbers"
  value       = module.rds.db_instance_ports
}

# Database resource IDs
output "db_resource_ids" {
  description = "Map of database resource IDs"
  value       = module.rds.db_instance_resource_ids
}

# Availability zones
output "availability_zones" {
  description = "Map of availability zones where databases are deployed"
  value       = module.rds.db_instance_availability_zones
}

# Connection strings
output "connection_strings" {
  description = "Map of formatted connection strings"
  value       = module.rds.connection_strings
  sensitive   = true
}

# DB subnet group details
output "db_subnet_groups" {
  description = "DB subnet groups created"
  value       = module.rds.db_subnet_groups
}

# DB parameter group details
output "db_parameter_groups" {
  description = "DB parameter groups created"
  value       = module.rds.db_parameter_groups
}

# Latest restorable times for PITR
output "latest_restorable_times" {
  description = "Latest restorable times for point-in-time recovery"
  value       = module.rds.latest_restorable_times
}

# Summary output for quick reference
output "deployment_summary" {
  description = "Summary of RDS deployment"
  value = {
    region         = var.region
    engine         = var.engine
    engine_version = var.engine_version
    instance_count = var.instance_count
    instance_class = var.instance_class
    multi_az       = var.multi_az
    storage_type   = var.storage_type
    environment    = var.environment
    project        = var.project_name
  }
}
