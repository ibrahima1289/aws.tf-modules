# AWS Region
variable "region" {
  description = "AWS region where RDS instances will be created"
  type        = string
  default     = "us-east-1"
}

# RDS Instance Configuration Map
variable "rds_instances" {
  description = "Map of RDS instance configurations. Key is the instance identifier."
  type = map(object({
    # Required parameters (optional for read replicas when replicate_source_db is set)
    engine         = optional(string) # mysql, postgres, mariadb, oracle-ee, oracle-se2, oracle-se1, oracle-se, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web
    engine_version = optional(string)
    instance_class = string

    # Database credentials (optional for read replicas when replicate_source_db is set)
    db_name  = optional(string)
    username = optional(string)
    password = optional(string) # Consider using AWS Secrets Manager in production

    # Storage configuration
    allocated_storage     = number
    max_allocated_storage = optional(number) # Enable storage autoscaling
    storage_type          = optional(string, "gp3")
    storage_encrypted     = optional(bool, true)
    kms_key_id            = optional(string)
    iops                  = optional(number)
    storage_throughput    = optional(number) # For gp3 only

    # Network configuration
    db_subnet_group_name   = optional(string)
    vpc_security_group_ids = optional(list(string))
    publicly_accessible    = optional(bool, false)
    availability_zone      = optional(string)
    multi_az               = optional(bool, false)

    # Database options
    port                                = optional(number)
    parameter_group_name                = optional(string)
    option_group_name                   = optional(string)
    character_set_name                  = optional(string) # For Oracle and SQL Server
    timezone                            = optional(string) # For SQL Server
    license_model                       = optional(string) # license-included, bring-your-own-license
    ca_cert_identifier                  = optional(string)
    domain                              = optional(string) # Active Directory domain
    domain_iam_role_name                = optional(string)
    iam_database_authentication_enabled = optional(bool, false)

    # Backup configuration
    backup_retention_period   = optional(number, 7)
    backup_window             = optional(string)
    copy_tags_to_snapshot     = optional(bool, true)
    skip_final_snapshot       = optional(bool, false)
    final_snapshot_identifier = optional(string)
    delete_automated_backups  = optional(bool, true)
    snapshot_identifier       = optional(string) # Restore from snapshot

    # Maintenance and monitoring
    maintenance_window                    = optional(string)
    auto_minor_version_upgrade            = optional(bool, true)
    apply_immediately                     = optional(bool, false)
    enabled_cloudwatch_logs_exports       = optional(list(string), [])
    monitoring_interval                   = optional(number, 0)
    monitoring_role_arn                   = optional(string)
    performance_insights_enabled          = optional(bool, false)
    performance_insights_retention_period = optional(number, 7)
    performance_insights_kms_key_id       = optional(string)

    # Advanced options
    allow_major_version_upgrade = optional(bool, false)
    deletion_protection         = optional(bool, true)
    replicate_source_db         = optional(string) # For read replicas
    restore_to_point_in_time = optional(object({
      source_db_instance_identifier = string
      restore_time                  = optional(string)
      use_latest_restorable_time    = optional(bool, true)
    }))

    # Blue/Green deployment
    blue_green_update = optional(object({
      enabled = optional(bool, false)
    }))

    # Tags
    tags = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.rds_instances : try(v.publicly_accessible, false) == false])
    error_message = "publicly_accessible must remain false. RDS instances must not be exposed to the public internet."
  }

  validation {
    condition     = alltrue([for k, v in var.rds_instances : try(v.storage_encrypted, true) == true])
    error_message = "storage_encrypted must remain true. Disabling encryption at rest is not permitted."
  }
}

# DB Subnet Groups(optional, create new ones)
variable "db_subnet_groups" {
  description = "Map of DB subnet groups to create"
  type = map(object({
    description = optional(string, "DB subnet group managed by Terraform")
    subnet_ids  = list(string)
    tags        = optional(map(string), {})
  }))
  default = {}
}

# Parameter Groups (optional, create custom ones)
variable "parameter_groups" {
  description = "Map of DB parameter groups to create"
  type = map(object({
    family      = string # e.g., mysql8.0, postgres14, etc.
    description = optional(string, "DB parameter group managed by Terraform")
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string, "immediate") # immediate or pending-reboot
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# Option Groups (optional, for Oracle and SQL Server)
variable "option_groups" {
  description = "Map of DB option groups to create"
  type = map(object({
    engine_name              = string
    major_engine_version     = string
    description              = optional(string, "DB option group managed by Terraform")
    option_group_description = optional(string)
    options = optional(list(object({
      option_name = string
      option_settings = optional(list(object({
        name  = string
        value = string
      })), [])
      port                           = optional(number)
      version                        = optional(string)
      db_security_group_memberships  = optional(list(string), [])
      vpc_security_group_memberships = optional(list(string), [])
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}
