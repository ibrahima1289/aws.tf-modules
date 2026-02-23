# AWS Region
variable "region" {
  description = "AWS region where Aurora clusters will be created"
  type        = string
  default     = "us-east-1"
}

# Aurora Cluster Configuration Map
variable "aurora_clusters" {
  description = "Map of Aurora cluster configurations. Key is the cluster identifier."
  type = map(object({
    # Required parameters
    engine         = string # aurora-mysql, aurora-postgresql
    engine_version = optional(string)

    # Database credentials
    master_username = string
    master_password = string # Consider using AWS Secrets Manager in production
    database_name   = optional(string)

    # Network configuration
    db_subnet_group_name   = optional(string)
    vpc_security_group_ids = optional(list(string))
    availability_zones     = optional(list(string))

    # Instance configuration (for provisioned clusters)
    instance_class = optional(string, "db.r6g.large")
    instances = optional(map(object({
      instance_class      = optional(string)
      publicly_accessible = optional(bool, false)
      promotion_tier      = optional(number, 1)
    })), {})

    # Serverless v2 scaling configuration
    serverlessv2_scaling_configuration = optional(object({
      min_capacity = number # 0.5 to 128 ACUs
      max_capacity = number # 0.5 to 128 ACUs
    }))

    # Storage configuration
    storage_encrypted             = optional(bool, true)
    kms_key_id                    = optional(string)
    storage_type                  = optional(string) # "aurora", "aurora-iopt1" for Aurora I/O-Optimized
    allocated_storage             = optional(number) # For Aurora I/O-Optimized
    iops                          = optional(number)
    db_cluster_instance_class     = optional(string) # For Aurora I/O-Optimized
    backup_retention_period       = optional(number, 7)
    preferred_backup_window       = optional(string)
    preferred_maintenance_window  = optional(string)
    skip_final_snapshot           = optional(bool, false)
    final_snapshot_identifier     = optional(string)
    copy_tags_to_snapshot         = optional(bool, true)
    snapshot_identifier           = optional(string)
    replication_source_identifier = optional(string)

    # Monitoring and logging
    enabled_cloudwatch_logs_exports       = optional(list(string), [])
    monitoring_interval                   = optional(number, 0)
    monitoring_role_arn                   = optional(string)
    performance_insights_enabled          = optional(bool, false)
    performance_insights_kms_key_id       = optional(string)
    performance_insights_retention_period = optional(number, 7)

    # Cluster features
    engine_mode                    = optional(string, "provisioned") # provisioned, serverless, parallelquery, global
    enable_http_endpoint           = optional(bool, false)           # For Data API (Serverless v1)
    backtrack_window               = optional(number, 0)             # 0-259200 seconds (72 hours), MySQL only
    enable_global_write_forwarding = optional(bool, false)
    deletion_protection            = optional(bool, false)
    apply_immediately              = optional(bool, false)
    allow_major_version_upgrade    = optional(bool, false)
    auto_minor_version_upgrade     = optional(bool, true)

    # Parameter and option groups
    db_cluster_parameter_group_name = optional(string)
    db_parameter_group_name         = optional(string)

    # IAM roles and authentication
    iam_database_authentication_enabled = optional(bool, false)
    iam_roles = optional(list(object({
      role_arn     = string
      feature_name = string # s3Import, s3Export, Lambda, SageMaker, Comprehend
    })), [])

    # Restore options
    restore_to_point_in_time = optional(object({
      source_cluster_identifier  = string
      restore_type               = optional(string, "full-copy") # full-copy, copy-on-write
      use_latest_restorable_time = optional(bool, true)
      restore_to_time            = optional(string)
    }))

    # S3 import (MySQL only)
    s3_import = optional(object({
      source_engine         = string
      source_engine_version = string
      bucket_name           = string
      bucket_prefix         = optional(string)
      ingestion_role        = string
    }))

    # Scaling configuration (Serverless v1)
    scaling_configuration = optional(object({
      auto_pause               = optional(bool, true)
      max_capacity             = optional(number, 16)
      min_capacity             = optional(number, 2)
      seconds_until_auto_pause = optional(number, 300)
      timeout_action           = optional(string, "RollbackCapacityChange")
    }))

    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# DB Subnet Groups (optional, create new ones)
variable "db_subnet_groups" {
  description = "Map of DB subnet groups to create"
  type = map(object({
    description = optional(string, "DB subnet group managed by Terraform")
    subnet_ids  = list(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

# DB Cluster Parameter Groups (optional, create custom ones)
variable "db_cluster_parameter_groups" {
  description = "Map of DB cluster parameter groups to create"
  type = map(object({
    family      = string # aurora-mysql8.0, aurora-postgresql14, etc.
    description = optional(string, "DB cluster parameter group managed by Terraform")
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate") # immediate or pending-reboot
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# DB Parameter Groups (optional, for instances)
variable "db_parameter_groups" {
  description = "Map of DB parameter groups to create for Aurora instances"
  type = map(object({
    family      = string
    description = optional(string, "DB parameter group managed by Terraform")
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate")
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# Global Database Configuration (optional)
variable "global_clusters" {
  description = "Map of Aurora global database configurations"
  type = map(object({
    global_cluster_identifier    = string
    engine                       = optional(string)
    engine_version               = optional(string)
    database_name                = optional(string)
    deletion_protection          = optional(bool, false)
    storage_encrypted            = optional(bool, true)
    source_db_cluster_identifier = optional(string)      # For adding secondary regions
    force_destroy                = optional(bool, false) # Required when source_db_cluster_identifier is set
  }))
  default = {}
}
