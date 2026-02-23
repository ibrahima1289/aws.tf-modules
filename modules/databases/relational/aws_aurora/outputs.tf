# Aurora Cluster Outputs

# All Aurora cluster details
output "aurora_clusters" {
  description = "Map of all Aurora cluster attributes"
  value = {
    for k, v in aws_rds_cluster.aurora_cluster : k => {
      id                           = v.id
      arn                          = v.arn
      cluster_identifier           = v.cluster_identifier
      endpoint                     = v.endpoint
      reader_endpoint              = v.reader_endpoint
      engine                       = v.engine
      engine_version_actual        = v.engine_version_actual
      engine_mode                  = v.engine_mode
      database_name                = v.database_name
      port                         = v.port
      master_username              = v.master_username
      hosted_zone_id               = v.hosted_zone_id
      resource_id                  = v.cluster_resource_id
      availability_zones           = v.availability_zones
      backup_retention_period      = v.backup_retention_period
      preferred_backup_window      = v.preferred_backup_window
      preferred_maintenance_window = v.preferred_maintenance_window
      storage_encrypted            = v.storage_encrypted
      kms_key_id                   = v.kms_key_id
      cluster_members              = v.cluster_members
    }
  }
}

# Cluster endpoints for connection
output "cluster_endpoints" {
  description = "Map of Aurora cluster writer endpoints"
  value       = { for k, v in aws_rds_cluster.aurora_cluster : k => v.endpoint }
}

# Cluster reader endpoints
output "cluster_reader_endpoints" {
  description = "Map of Aurora cluster reader endpoints"
  value       = { for k, v in aws_rds_cluster.aurora_cluster : k => v.reader_endpoint }
}

# Cluster ARNs
output "cluster_arns" {
  description = "Map of Aurora cluster ARNs"
  value       = { for k, v in aws_rds_cluster.aurora_cluster : k => v.arn }
}

# Cluster resource IDs
output "cluster_resource_ids" {
  description = "Map of Aurora cluster resource IDs"
  value       = { for k, v in aws_rds_cluster.aurora_cluster : k => v.cluster_resource_id }
}

# Cluster ports
output "cluster_ports" {
  description = "Map of Aurora cluster port numbers"
  value       = { for k, v in aws_rds_cluster.aurora_cluster : k => v.port }
}

# Cluster members
output "cluster_members" {
  description = "Map of Aurora cluster members"
  value       = { for k, v in aws_rds_cluster.aurora_cluster : k => v.cluster_members }
}

# All Aurora cluster instance details
output "aurora_instances" {
  description = "Map of all Aurora cluster instance attributes"
  value = {
    for k, v in aws_rds_cluster_instance.aurora_cluster_instance : k => {
      id                  = v.id
      arn                 = v.arn
      identifier          = v.identifier
      cluster_identifier  = v.cluster_identifier
      instance_class      = v.instance_class
      engine              = v.engine
      engine_version      = v.engine_version_actual
      endpoint            = v.endpoint
      port                = v.port
      publicly_accessible = v.publicly_accessible
      availability_zone   = v.availability_zone
      promotion_tier      = v.promotion_tier
      writer              = v.writer
    }
  }
}

# Instance endpoints
output "instance_endpoints" {
  description = "Map of Aurora instance endpoints"
  value       = { for k, v in aws_rds_cluster_instance.aurora_cluster_instance : k => v.endpoint }
}

# Writer instances
output "writer_instances" {
  description = "Map of writer instance identifiers per cluster"
  value = {
    for cluster_key, cluster in aws_rds_cluster.aurora_cluster : cluster_key => [
      for instance_key, instance in aws_rds_cluster_instance.aurora_cluster_instance :
      instance.identifier if instance.cluster_identifier == cluster.id && instance.writer
    ]
  }
}

# Reader instances
output "reader_instances" {
  description = "Map of reader instance identifiers per cluster"
  value = {
    for cluster_key, cluster in aws_rds_cluster.aurora_cluster : cluster_key => [
      for instance_key, instance in aws_rds_cluster_instance.aurora_cluster_instance :
      instance.identifier if instance.cluster_identifier == cluster.id && !instance.writer
    ]
  }
}

# DB Subnet Groups
output "db_subnet_groups" {
  description = "Map of created DB subnet groups"
  value = {
    for k, v in aws_db_subnet_group.aurora_subnet_group : k => {
      id         = v.id
      arn        = v.arn
      name       = v.name
      subnet_ids = v.subnet_ids
      vpc_id     = v.vpc_id
    }
  }
}

# DB Cluster Parameter Groups
output "db_cluster_parameter_groups" {
  description = "Map of created DB cluster parameter groups"
  value = {
    for k, v in aws_rds_cluster_parameter_group.aurora_cluster_parameter_group : k => {
      id     = v.id
      arn    = v.arn
      name   = v.name
      family = v.family
    }
  }
}

# DB Parameter Groups
output "db_parameter_groups" {
  description = "Map of created DB parameter groups"
  value = {
    for k, v in aws_db_parameter_group.aurora_parameter_group : k => {
      id     = v.id
      arn    = v.arn
      name   = v.name
      family = v.family
    }
  }
}

# Global Clusters
output "global_clusters" {
  description = "Map of created Aurora global clusters"
  value = {
    for k, v in aws_rds_global_cluster.aurora_global_cluster : k => {
      id                        = v.id
      arn                       = v.arn
      global_cluster_identifier = v.global_cluster_identifier
      engine                    = v.engine
      engine_version            = v.engine_version_actual
      database_name             = v.database_name
      storage_encrypted         = v.storage_encrypted
    }
  }
}

# Connection strings (formatted for easy use)
output "connection_strings" {
  description = "Map of database connection strings"
  value = {
    for k, v in aws_rds_cluster.aurora_cluster : k => {
      writer = "${v.engine}://${v.master_username}@${v.endpoint}/${v.database_name != null ? v.database_name : ""}"
      reader = "${v.engine}://${v.master_username}@${v.reader_endpoint}/${v.database_name != null ? v.database_name : ""}"
    }
  }
  sensitive = true
}
