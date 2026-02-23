# Outputs from AWS Aurora wrapper module

# All Aurora cluster details
output "aurora_clusters" {
  description = "Map of all Aurora cluster details"
  value       = module.aurora.aurora_clusters
}

# Cluster writer endpoints
output "cluster_endpoints" {
  description = "Map of Aurora cluster writer endpoints"
  value       = module.aurora.cluster_endpoints
}

# Cluster reader endpoints
output "cluster_reader_endpoints" {
  description = "Map of Aurora cluster reader endpoints"
  value       = module.aurora.cluster_reader_endpoints
}

# Cluster ARNs
output "cluster_arns" {
  description = "Map of Aurora cluster ARNs"
  value       = module.aurora.cluster_arns
}

# Cluster resource IDs
output "cluster_resource_ids" {
  description = "Map of Aurora cluster resource IDs"
  value       = module.aurora.cluster_resource_ids
}

# Cluster ports
output "cluster_ports" {
  description = "Map of Aurora cluster port numbers"
  value       = module.aurora.cluster_ports
}

# Cluster members
output "cluster_members" {
  description = "Map of Aurora cluster members"
  value       = module.aurora.cluster_members
}

# All Aurora instance details
output "aurora_instances" {
  description = "Map of all Aurora instance details"
  value       = module.aurora.aurora_instances
}

# Instance endpoints
output "instance_endpoints" {
  description = "Map of Aurora instance endpoints"
  value       = module.aurora.instance_endpoints
}

# Writer instances
output "writer_instances" {
  description = "Map of writer instance identifiers per cluster"
  value       = module.aurora.writer_instances
}

# Reader instances
output "reader_instances" {
  description = "Map of reader instance identifiers per cluster"
  value       = module.aurora.reader_instances
}

# Connection strings
output "connection_strings" {
  description = "Map of formatted connection strings"
  value       = module.aurora.connection_strings
  sensitive   = true
}

# DB subnet group details
output "db_subnet_groups" {
  description = "DB subnet groups created"
  value       = module.aurora.db_subnet_groups
}

# DB cluster parameter group details
output "db_cluster_parameter_groups" {
  description = "DB cluster parameter groups created"
  value       = module.aurora.db_cluster_parameter_groups
}

# DB instance parameter group details
output "db_parameter_groups" {
  description = "DB instance parameter groups created"
  value       = module.aurora.db_parameter_groups
}

# Summary output for quick reference
output "deployment_summary" {
  description = "Summary of Aurora deployment"
  value = {
    region         = var.region
    engine         = var.engine
    engine_version = var.engine_version
    engine_mode    = var.engine_mode
    cluster_count  = var.cluster_count
    instance_count = var.instance_count
    instance_class = var.instance_class
    environment    = var.environment
    project        = var.project_name
    serverless_v2  = var.serverlessv2_min_capacity != null
  }
}
