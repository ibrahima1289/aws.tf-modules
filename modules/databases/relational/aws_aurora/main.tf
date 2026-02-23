# AWS Aurora Terraform Module
# This module creates and manages AWS Aurora database clusters
# Supports: Aurora MySQL, Aurora PostgreSQL, Serverless v1/v2, Global Databases

# Create DB Subnet Groups if specified
resource "aws_db_subnet_group" "aurora_subnet_group" {
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

# Create DB Cluster Parameter Groups if specified
resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  for_each = var.db_cluster_parameter_groups

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

# Create DB Parameter Groups for instances if specified
resource "aws_db_parameter_group" "aurora_parameter_group" {
  for_each = var.db_parameter_groups

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

# Create Aurora Global Databases if specified
resource "aws_rds_global_cluster" "aurora_global_cluster" {
  for_each = var.global_clusters

  global_cluster_identifier    = each.value.global_cluster_identifier
  engine                       = each.value.engine
  engine_version               = each.value.engine_version
  database_name                = each.value.database_name
  deletion_protection          = each.value.deletion_protection
  storage_encrypted            = each.value.storage_encrypted
  source_db_cluster_identifier = each.value.source_db_cluster_identifier
  force_destroy                = each.value.force_destroy

  lifecycle {
    ignore_changes = [
      source_db_cluster_identifier
    ]
  }
}

# Create Aurora Database Clusters
resource "aws_rds_cluster" "aurora_cluster" {
  for_each = var.aurora_clusters

  # Cluster identifier
  cluster_identifier = each.key

  # Engine configuration
  engine         = each.value.engine
  engine_version = each.value.engine_version
  engine_mode    = each.value.engine_mode

  # Database credentials
  master_username = each.value.master_username
  master_password = each.value.master_password
  database_name   = each.value.database_name

  # Network configuration
  db_subnet_group_name   = each.value.db_subnet_group_name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  availability_zones     = each.value.availability_zones

  # Storage configuration
  storage_encrypted         = each.value.storage_encrypted
  kms_key_id                = each.value.kms_key_id
  storage_type              = each.value.storage_type
  allocated_storage         = each.value.allocated_storage
  iops                      = each.value.iops
  db_cluster_instance_class = each.value.db_cluster_instance_class

  # Backup configuration
  backup_retention_period       = each.value.backup_retention_period
  preferred_backup_window       = each.value.preferred_backup_window
  preferred_maintenance_window  = each.value.preferred_maintenance_window
  skip_final_snapshot           = each.value.skip_final_snapshot
  final_snapshot_identifier     = each.value.final_snapshot_identifier != null ? each.value.final_snapshot_identifier : "${each.key}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  copy_tags_to_snapshot         = each.value.copy_tags_to_snapshot
  snapshot_identifier           = each.value.snapshot_identifier
  replication_source_identifier = each.value.replication_source_identifier

  # Monitoring and logging
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  # Cluster features
  enable_http_endpoint           = each.value.enable_http_endpoint
  backtrack_window               = each.value.backtrack_window
  enable_global_write_forwarding = each.value.enable_global_write_forwarding
  deletion_protection            = each.value.deletion_protection
  apply_immediately              = each.value.apply_immediately
  allow_major_version_upgrade    = each.value.allow_major_version_upgrade

  # Parameter groups
  db_cluster_parameter_group_name = each.value.db_cluster_parameter_group_name

  # IAM authentication and roles
  iam_database_authentication_enabled = each.value.iam_database_authentication_enabled
  iam_roles                           = [for role in each.value.iam_roles : role.role_arn]

  # Serverless v2 scaling configuration
  dynamic "serverlessv2_scaling_configuration" {
    for_each = each.value.serverlessv2_scaling_configuration != null ? [each.value.serverlessv2_scaling_configuration] : []
    content {
      min_capacity = serverlessv2_scaling_configuration.value.min_capacity
      max_capacity = serverlessv2_scaling_configuration.value.max_capacity
    }
  }

  # Restore to point in time
  dynamic "restore_to_point_in_time" {
    for_each = each.value.restore_to_point_in_time != null ? [each.value.restore_to_point_in_time] : []
    content {
      source_cluster_identifier  = restore_to_point_in_time.value.source_cluster_identifier
      restore_type               = restore_to_point_in_time.value.restore_type
      use_latest_restorable_time = restore_to_point_in_time.value.use_latest_restorable_time
      restore_to_time            = restore_to_point_in_time.value.restore_to_time
    }
  }

  # S3 import (MySQL only)
  dynamic "s3_import" {
    for_each = each.value.s3_import != null ? [each.value.s3_import] : []
    content {
      source_engine         = s3_import.value.source_engine
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = s3_import.value.bucket_prefix
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  # Scaling configuration (Serverless v1)
  dynamic "scaling_configuration" {
    for_each = each.value.scaling_configuration != null ? [each.value.scaling_configuration] : []
    content {
      auto_pause               = scaling_configuration.value.auto_pause
      max_capacity             = scaling_configuration.value.max_capacity
      min_capacity             = scaling_configuration.value.min_capacity
      seconds_until_auto_pause = scaling_configuration.value.seconds_until_auto_pause
      timeout_action           = scaling_configuration.value.timeout_action
    }
  }

  # Merge common tags with cluster-specific tags
  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name          = each.key
      Engine        = each.value.engine
      EngineMode    = each.value.engine_mode
      EngineVersion = each.value.engine_version
    }
  )

  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      master_password, # Ignore password changes to avoid recreation
      snapshot_identifier,
      replication_source_identifier
    ]
  }

  # Dependencies
  depends_on = [
    aws_db_subnet_group.aurora_subnet_group,
    aws_rds_cluster_parameter_group.aurora_cluster_parameter_group,
    aws_rds_global_cluster.aurora_global_cluster
  ]
}

# Create Aurora Cluster Instances (only for provisioned and serverless v2)
resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  for_each = merge([
    for cluster_key, cluster in var.aurora_clusters :
    cluster.engine_mode != "serverless" ? {
      for instance_key, instance in cluster.instances :
      "${cluster_key}-${instance_key}" => {
        cluster_identifier                    = cluster_key
        instance_class                        = instance.instance_class != null ? instance.instance_class : cluster.instance_class
        engine                                = cluster.engine
        publicly_accessible                   = instance.publicly_accessible
        promotion_tier                        = instance.promotion_tier
        monitoring_interval                   = cluster.monitoring_interval
        monitoring_role_arn                   = cluster.monitoring_interval > 0 ? cluster.monitoring_role_arn : null
        performance_insights_enabled          = cluster.performance_insights_enabled
        performance_insights_kms_key_id       = cluster.performance_insights_enabled ? cluster.performance_insights_kms_key_id : null
        performance_insights_retention_period = cluster.performance_insights_enabled ? cluster.performance_insights_retention_period : null
        db_parameter_group_name               = cluster.db_parameter_group_name
        auto_minor_version_upgrade            = cluster.auto_minor_version_upgrade
        apply_immediately                     = cluster.apply_immediately
        tags                                  = cluster.tags
      }
    } : {}
  ]...)

  identifier              = each.key
  cluster_identifier      = aws_rds_cluster.aurora_cluster[each.value.cluster_identifier].id
  instance_class          = each.value.instance_class
  engine                  = each.value.engine
  publicly_accessible     = each.value.publicly_accessible
  promotion_tier          = each.value.promotion_tier
  db_parameter_group_name = each.value.db_parameter_group_name

  # Monitoring
  monitoring_interval = each.value.monitoring_interval
  monitoring_role_arn = each.value.monitoring_role_arn

  # Performance Insights
  performance_insights_enabled          = each.value.performance_insights_enabled
  performance_insights_kms_key_id       = each.value.performance_insights_kms_key_id
  performance_insights_retention_period = each.value.performance_insights_retention_period

  # Maintenance
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  apply_immediately          = each.value.apply_immediately

  # Tags
  tags = merge(
    local.common_tags,
    each.value.tags,
    {
      Name    = each.key
      Cluster = each.value.cluster_identifier
    }
  )

  # Dependencies
  depends_on = [
    aws_rds_cluster.aurora_cluster,
    aws_db_parameter_group.aurora_parameter_group
  ]
}
