# Local values for computed configurations
locals {
  # Auto-detect parameter group families if not provided
  cluster_parameter_family_map = {
    "aurora-mysql"      = "aurora-mysql8.0"
    "aurora-postgresql" = "aurora-postgresql14"
  }

  instance_parameter_family_map = {
    "aurora-mysql"      = "aurora-mysql8.0"
    "aurora-postgresql" = "aurora-postgresql14"
  }

  # Use provided family or auto-detect
  cluster_parameter_group_family  = var.cluster_parameter_group_family != null ? var.cluster_parameter_group_family : lookup(local.cluster_parameter_family_map, var.engine, "aurora-postgresql14")
  instance_parameter_group_family = var.instance_parameter_group_family != null ? var.instance_parameter_group_family : lookup(local.instance_parameter_family_map, var.engine, "aurora-postgresql14")

  # Generate DB subnet group name
  db_subnet_group_name = "${var.cluster_name_prefix}-subnet-group"

  # Generate parameter group names if custom parameters are provided
  create_cluster_parameter_group  = length(var.custom_cluster_parameters) > 0
  create_instance_parameter_group = length(var.custom_instance_parameters) > 0 && var.engine_mode != "serverless"
  cluster_parameter_group_name    = local.create_cluster_parameter_group ? "${var.cluster_name_prefix}-cluster-params" : null
  instance_parameter_group_name   = local.create_instance_parameter_group ? "${var.cluster_name_prefix}-instance-params" : null

  # Determine if using Serverless v2
  use_serverlessv2 = var.serverlessv2_min_capacity != null && var.serverlessv2_max_capacity != null

  # Build instances map for provisioned mode
  instances_map = var.engine_mode == "provisioned" ? {
    for i in range(var.instance_count) : "instance-${i + 1}" => {
      instance_class      = var.instance_class
      publicly_accessible = false
      promotion_tier      = i # First instance (0) has highest priority
    }
  } : {}

  # Build Aurora clusters map based on count
  aurora_clusters = {
    for i in range(var.cluster_count) : "${var.cluster_name_prefix}-${i + 1}" => {
      engine         = var.engine
      engine_version = var.engine_version
      engine_mode    = var.engine_mode

      # Database credentials
      master_username = var.master_username
      master_password = var.master_password
      database_name   = var.database_name

      # Network configuration
      db_subnet_group_name   = local.db_subnet_group_name
      vpc_security_group_ids = var.security_group_ids
      availability_zones     = var.availability_zones

      # Instance configuration (for provisioned mode)
      instance_class = var.instance_class
      instances      = local.instances_map

      # Serverless v2 scaling configuration
      serverlessv2_scaling_configuration = local.use_serverlessv2 ? {
        min_capacity = var.serverlessv2_min_capacity
        max_capacity = var.serverlessv2_max_capacity
      } : null

      # Serverless v1 scaling configuration
      scaling_configuration = var.engine_mode == "serverless" ? {
        auto_pause               = var.serverless_auto_pause
        max_capacity             = var.serverless_max_capacity
        min_capacity             = var.serverless_min_capacity
        seconds_until_auto_pause = var.serverless_seconds_until_auto_pause
        timeout_action           = "RollbackCapacityChange"
      } : null

      # Storage configuration
      storage_encrypted = var.storage_encrypted
      kms_key_id        = var.kms_key_id
      storage_type      = var.storage_type

      # Backup configuration
      backup_retention_period      = var.backup_retention_period
      preferred_backup_window      = var.preferred_backup_window
      preferred_maintenance_window = var.preferred_maintenance_window
      skip_final_snapshot          = var.skip_final_snapshot
      copy_tags_to_snapshot        = true

      # Monitoring and logging
      enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
      monitoring_interval                   = var.monitoring_interval
      performance_insights_enabled          = var.performance_insights_enabled
      performance_insights_retention_period = var.performance_insights_retention_period

      # Advanced features
      enable_http_endpoint                = var.enable_http_endpoint
      backtrack_window                    = var.backtrack_window
      iam_database_authentication_enabled = var.iam_database_authentication_enabled
      deletion_protection                 = var.deletion_protection
      auto_minor_version_upgrade          = var.auto_minor_version_upgrade

      # Parameter groups
      db_cluster_parameter_group_name = local.cluster_parameter_group_name
      db_parameter_group_name         = local.instance_parameter_group_name

      # Tags specific to this cluster
      tags = merge(
        var.tags,
        {
          Environment = var.environment
          Project     = var.project_name
          Cluster     = "${var.cluster_name_prefix}-${i + 1}"
        }
      )
    }
  }

  # DB subnet groups configuration
  db_subnet_groups = {
    "${local.db_subnet_group_name}" = {
      description = "DB subnet group for ${var.project_name} ${var.environment} Aurora clusters"
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

  # Cluster parameter groups configuration
  db_cluster_parameter_groups = local.create_cluster_parameter_group ? {
    "${local.cluster_parameter_group_name}" = {
      family      = local.cluster_parameter_group_family
      description = "Custom cluster parameter group for ${var.project_name} ${var.environment}"
      parameters  = var.custom_cluster_parameters
      tags = merge(
        var.tags,
        {
          Environment = var.environment
          Project     = var.project_name
        }
      )
    }
  } : {}

  # Instance parameter groups configuration
  db_parameter_groups = local.create_instance_parameter_group ? {
    "${local.instance_parameter_group_name}" = {
      family      = local.instance_parameter_group_family
      description = "Custom instance parameter group for ${var.project_name} ${var.environment}"
      parameters  = var.custom_instance_parameters
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