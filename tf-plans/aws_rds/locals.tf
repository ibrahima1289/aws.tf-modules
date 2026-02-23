# Local values for computed configurations
locals {
  # Auto-detect parameter group family if not provided
  parameter_family_map = {
    "mysql"         = "mysql8.0"
    "postgres"      = "postgres14"
    "mariadb"       = "mariadb10.6"
    "oracle-ee"     = "oracle-ee-19"
    "oracle-se2"    = "oracle-se2-19"
    "oracle-se1"    = "oracle-se1-11.2"
    "oracle-se"     = "oracle-se-11.2"
    "sqlserver-ee"  = "sqlserver-ee-15.0"
    "sqlserver-se"  = "sqlserver-se-15.0"
    "sqlserver-ex"  = "sqlserver-ex-15.0"
    "sqlserver-web" = "sqlserver-web-15.0"
  }

  # Use provided family or auto-detect
  parameter_group_family = var.parameter_group_family != null ? var.parameter_group_family : lookup(local.parameter_family_map, var.engine, "postgres14")

  # Generate DB subnet group name
  db_subnet_group_name = "${var.instance_name_prefix}-subnet-group"

  # Generate parameter group name if custom parameters are provided
  create_parameter_group = length(var.custom_parameters) > 0
  parameter_group_name   = local.create_parameter_group ? "${var.instance_name_prefix}-params" : null

  # Build RDS instances map based on count
  rds_instances = {
    for i in range(var.instance_count) : "${var.instance_name_prefix}-${i + 1}" => {
      engine         = var.engine
      engine_version = var.engine_version
      instance_class = var.instance_class

      # Database credentials
      db_name  = var.db_name
      username = var.master_username
      password = var.master_password

      # Storage configuration
      allocated_storage     = var.allocated_storage
      max_allocated_storage = var.max_allocated_storage > 0 ? var.max_allocated_storage : null
      storage_type          = var.storage_type
      storage_encrypted     = var.storage_encrypted
      kms_key_id            = var.kms_key_id

      # Network configuration
      db_subnet_group_name   = local.db_subnet_group_name
      vpc_security_group_ids = var.security_group_ids
      publicly_accessible    = var.publicly_accessible
      multi_az               = var.multi_az

      # Parameter group
      parameter_group_name = local.parameter_group_name

      # Backup configuration
      backup_retention_period = var.backup_retention_period
      backup_window           = var.backup_window
      skip_final_snapshot     = var.skip_final_snapshot
      copy_tags_to_snapshot   = true

      # Maintenance and monitoring
      maintenance_window              = var.maintenance_window
      auto_minor_version_upgrade      = var.auto_minor_version_upgrade
      enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
      monitoring_interval             = var.monitoring_interval

      # Performance Insights
      performance_insights_enabled          = var.performance_insights_enabled
      performance_insights_retention_period = var.performance_insights_retention_period

      # Advanced options
      deletion_protection                 = var.deletion_protection
      iam_database_authentication_enabled = var.iam_database_authentication_enabled

      # Tags specific to this instance
      tags = merge(
        var.tags,
        {
          Environment = var.environment
          Project     = var.project_name
          Instance    = "${var.instance_name_prefix}-${i + 1}"
        }
      )
    }
  }

  # DB subnet groups configuration
  db_subnet_groups = {
    "${local.db_subnet_group_name}" = {
      description = "DB subnet group for ${var.project_name} ${var.environment}"
      subnet_ids  = var.subnet_ids
      tags = merge(
        var.tags,
        {
          Environment = var.environment
          Project     = var.project_name
        }
      )
    }
  }

  # Parameter groups configuration (only if custom parameters are provided)
  parameter_groups = local.create_parameter_group ? {
    "${local.parameter_group_name}" = {
      family      = local.parameter_group_family
      description = "Custom parameter group for ${var.project_name} ${var.environment}"
      parameters  = var.custom_parameters
      tags = merge(
        var.tags,
        {
          Environment = var.environment
          Project     = var.project_name
        }
      )
    }
  } : {}
}
