# RDS Instance Outputs

# All RDS instance details
output "rds_instances" {
  description = "Map of all RDS instance attributes"
  value = {
    for k, v in aws_db_instance.rds_instance : k => {
      id                      = v.id
      arn                     = v.arn
      address                 = v.address
      endpoint                = v.endpoint
      hosted_zone_id          = v.hosted_zone_id
      port                    = v.port
      engine                  = v.engine
      engine_version          = v.engine_version_actual
      instance_class          = v.instance_class
      allocated_storage       = v.allocated_storage
      storage_type            = v.storage_type
      storage_encrypted       = v.storage_encrypted
      availability_zone       = v.availability_zone
      multi_az                = v.multi_az
      resource_id             = v.resource_id
      status                  = v.status
      backup_retention_period = v.backup_retention_period
      latest_restorable_time  = v.latest_restorable_time
      replicas                = v.replicas
      ca_cert_identifier      = v.ca_cert_identifier
    }
  }
}

# Individual connection endpoints
output "db_instance_endpoints" {
  description = "Map of RDS instance connection endpoints"
  value       = { for k, v in aws_db_instance.rds_instance : k => v.endpoint }
}

# Individual addresses (hostname only)
output "db_instance_addresses" {
  description = "Map of RDS instance addresses (hostname)"
  value       = { for k, v in aws_db_instance.rds_instance : k => v.address }
}

# Individual ARNs
output "db_instance_arns" {
  description = "Map of RDS instance ARNs"
  value       = { for k, v in aws_db_instance.rds_instance : k => v.arn }
}

# Individual resource IDs
output "db_instance_resource_ids" {
  description = "Map of RDS instance resource IDs"
  value       = { for k, v in aws_db_instance.rds_instance : k => v.resource_id }
}

# Port numbers
output "db_instance_ports" {
  description = "Map of RDS instance port numbers"
  value       = { for k, v in aws_db_instance.rds_instance : k => v.port }
}

# Availability zones
output "db_instance_availability_zones" {
  description = "Map of RDS instance availability zones"
  value       = { for k, v in aws_db_instance.rds_instance : k => v.availability_zone }
}

# DB Subnet Groups
output "db_subnet_groups" {
  description = "Map of created DB subnet groups"
  value = {
    for k, v in aws_db_subnet_group.rds_subnet_group : k => {
      id         = v.id
      arn        = v.arn
      name       = v.name
      subnet_ids = v.subnet_ids
      vpc_id     = v.vpc_id
    }
  }
}

# DB Parameter Groups
output "db_parameter_groups" {
  description = "Map of created DB parameter groups"
  value = {
    for k, v in aws_db_parameter_group.rds_parameter_group : k => {
      id     = v.id
      arn    = v.arn
      name   = v.name
      family = v.family
    }
  }
}

# DB Option Groups
output "db_option_groups" {
  description = "Map of created DB option groups"
  value = {
    for k, v in aws_db_option_group.rds_option_group : k => {
      id                   = v.id
      arn                  = v.arn
      name                 = v.name
      engine_name          = v.engine_name
      major_engine_version = v.major_engine_version
    }
  }
}

# Connection strings (formatted for easy use)
output "connection_strings" {
  description = "Map of database connection strings"
  value = {
    for k, v in aws_db_instance.rds_instance : k => {
      mysql      = v.engine == "mysql" || v.engine == "mariadb" ? "mysql://${v.username}@${v.endpoint}/${v.db_name}" : null
      postgresql = v.engine == "postgres" ? "postgresql://${v.username}@${v.endpoint}/${v.db_name}" : null
      generic    = "${v.engine}://${v.username}@${v.endpoint}/${v.db_name != null ? v.db_name : ""}"
    }
  }
  sensitive = true
}

# Latest restorable time for PITR
output "latest_restorable_times" {
  description = "Map of latest restorable times for point-in-time recovery"
  value       = { for k, v in aws_db_instance.rds_instance : k => v.latest_restorable_time }
}
