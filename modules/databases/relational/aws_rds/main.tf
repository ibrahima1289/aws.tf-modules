# AWS RDS Terraform Module
# This module creates and manages AWS RDS database instances with support for all database engines
# Supports: MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, and Aurora

# Create DB Subnet Groups if specified
resource "aws_db_subnet_group" "rds_subnet_group" {
  for_each = var.db_subnet_groups

  name        = each.key
  description = each.value.description
  subnet_ids  = each.value.subnet_ids

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = each.key
    }
  )
}

# Create DB Parameter Groups if specified
# This is needed to apply custom parameters that are not available in default parameter groups
resource "aws_db_parameter_group" "rds_parameter_group" {
  for_each = var.parameter_groups

  name        = each.key
  family      = each.value.family
  description = each.value.description

  # Apply custom parameters
  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = each.key
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Create DB Option Groups if specified (for Oracle and SQL Server)
resource "aws_db_option_group" "rds_option_group" {
  for_each = var.option_groups

  name                     = each.key
  option_group_description = coalesce(each.value.option_group_description, each.value.description)
  engine_name              = each.value.engine_name
  major_engine_version     = each.value.major_engine_version

  # Configure options
  dynamic "option" {
    for_each = each.value.options
    content {
      option_name                    = option.value.option_name
      port                           = option.value.port
      version                        = option.value.version
      db_security_group_memberships  = option.value.db_security_group_memberships
      vpc_security_group_memberships = option.value.vpc_security_group_memberships

      # Configure option settings
      dynamic "option_settings" {
        for_each = option.value.option_settings
        content {
          name  = option_settings.value.name
          value = option_settings.value.value
        }
      }
    }
  }

  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name = each.key
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Create RDS Database Instances
resource "aws_db_instance" "rds_instance" {
  for_each = var.rds_instances

  # Instance identifier
  identifier = each.key

  # Engine configuration (not used for read replicas)
  engine         = each.value.replicate_source_db == null ? each.value.engine : null
  engine_version = each.value.replicate_source_db == null ? each.value.engine_version : null
  instance_class = each.value.instance_class

  # Database name and credentials (not used for read replicas)
  db_name  = each.value.replicate_source_db == null ? each.value.db_name : null
  username = each.value.replicate_source_db == null ? each.value.username : null
  password = each.value.replicate_source_db == null ? each.value.password : null # Use AWS Secrets Manager in production

  # Storage configuration
  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  storage_type          = each.value.storage_type
  storage_encrypted     = each.value.storage_encrypted
  kms_key_id            = each.value.kms_key_id
  iops                  = each.value.iops
  storage_throughput    = each.value.storage_throughput

  # Network configuration
  db_subnet_group_name   = each.value.db_subnet_group_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  publicly_accessible    = each.value.publicly_accessible
  availability_zone      = each.value.availability_zone
  multi_az               = each.value.multi_az
  port                   = each.value.port

  # Database options
  parameter_group_name                = each.value.parameter_group_name
  option_group_name                   = each.value.option_group_name
  character_set_name                  = each.value.character_set_name
  timezone                            = each.value.timezone
  license_model                       = each.value.license_model
  ca_cert_identifier                  = each.value.ca_cert_identifier
  domain                              = each.value.domain
  domain_iam_role_name                = each.value.domain_iam_role_name
  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled

  # Backup configuration
  backup_retention_period   = each.value.backup_retention_period
  backup_window             = each.value.backup_window
  copy_tags_to_snapshot     = each.value.copy_tags_to_snapshot
  skip_final_snapshot       = each.value.skip_final_snapshot
  final_snapshot_identifier = each.value.final_snapshot_identifier != null ? each.value.final_snapshot_identifier : "${each.key}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  delete_automated_backups  = each.value.delete_automated_backups
  snapshot_identifier       = each.value.snapshot_identifier

  # Maintenance and monitoring
  maintenance_window              = each.value.maintenance_window
  auto_minor_version_upgrade      = each.value.auto_minor_version_upgrade
  apply_immediately               = each.value.apply_immediately
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports
  monitoring_interval             = each.value.monitoring_interval
  monitoring_role_arn             = each.value.monitoring_interval > 0 ? each.value.monitoring_role_arn : null

  # Performance Insights
  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_retention_period = each.value.performance_insights_enabled ? each.value.performance_insights_retention_period : null
  performance_insights_kms_key_id       = each.value.performance_insights_enabled ? each.value.performance_insights_kms_key_id : null

  # Advanced options
  allow_major_version_upgrade = each.value.allow_major_version_upgrade
  deletion_protection         = each.value.deletion_protection
  replicate_source_db         = each.value.replicate_source_db

  # Restore to point in time (mutually exclusive with snapshot_identifier)
  dynamic "restore_to_point_in_time" {
    for_each = each.value.restore_to_point_in_time != null && each.value.snapshot_identifier == null ? [each.value.restore_to_point_in_time] : []
    content {
      source_db_instance_identifier = restore_to_point_in_time.value.source_db_instance_identifier
      restore_time                  = restore_to_point_in_time.value.restore_time
      use_latest_restorable_time    = restore_to_point_in_time.value.use_latest_restorable_time
    }
  }

  # Blue/Green deployment configuration
  dynamic "blue_green_update" {
    for_each = each.value.blue_green_update != null && each.value.blue_green_update.enabled ? [each.value.blue_green_update] : []
    content {
      enabled = blue_green_update.value.enabled
    }
  }

  # Merge common tags with instance-specific tags
  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name          = each.key
      Engine        = each.value.engine
      EngineVersion = each.value.engine_version
    }
  )

  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      password, # Ignore password changes to avoid recreation
    ]
  }

  # Dependencies
  depends_on = [
    aws_db_subnet_group.rds_subnet_group,
    aws_db_parameter_group.rds_parameter_group,
    aws_db_option_group.rds_option_group
  ]
}
