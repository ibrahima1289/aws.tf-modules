# Variables for AWS RDS wrapper module

# AWS Region
variable "region" {
  description = "AWS region for RDS deployment"
  type        = string
  default     = "us-east-1"
}

# Number of RDS instances to create
variable "instance_count" {
  description = "Number of RDS instances to create (for scaling)"
  type        = number
  default     = 1
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10"
  }
}

# Base instance name prefix
variable "instance_name_prefix" {
  description = "Prefix for RDS instance names"
  type        = string
  default     = "rds-instance"
}

# Database engine
variable "engine" {
  description = "Database engine (mysql, postgres, mariadb, oracle-ee, oracle-se2, sqlserver-ee, sqlserver-se, sqlserver-ex, sqlserver-web)"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["mysql", "postgres", "mariadb", "oracle-ee", "oracle-se2", "oracle-se1", "oracle-se", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"], var.engine)
    error_message = "Engine must be a valid RDS engine type"
  }
}

# Engine version
variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "14.7" # PostgreSQL 14.7
}

# Instance class
variable "instance_class" {
  description = "RDS instance class (e.g., db.t3.micro, db.t3.small, db.r6g.large)"
  type        = string
  default     = "db.t3.micro"
}

# Database name
variable "db_name" {
  description = "Name of the database to create (optional for some engines)"
  type        = string
  default     = "mydb"
}

# Master username
variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

# Master password
variable "master_password" {
  description = "Master password for the database (use AWS Secrets Manager in production)"
  type        = string
  sensitive   = true
}

# Storage configuration
variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling in GB (0 to disable)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "storage_encrypted" {
  description = "Enable storage encryption"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for storage encryption (optional)"
  type        = string
  default     = null
}

# Network configuration
variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for RDS instances"
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "Make RDS instance publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for single-AZ deployment (only used when multi_az = false)"
  type        = string
  default     = null
}

# Backup configuration
variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window (e.g., 03:00-04:00)"
  type        = string
  default     = "03:00-04:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying"
  type        = bool
  default     = false
}

# Maintenance configuration
variable "maintenance_window" {
  description = "Preferred maintenance window (e.g., Mon:04:00-Mon:05:00)"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

# Monitoring
variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 1, 5, 10, 15, 30, 60)"
  type        = number
  default     = 0
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days (7 or 731)"
  type        = number
  default     = 7
}

# CloudWatch logs
variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch (audit, error, general, slowquery for MySQL; postgresql for PostgreSQL)"
  type        = list(string)
  default     = []
}

# Deletion protection
variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# IAM database authentication
variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = false
}

# Parameter group family (auto-detected based on engine and version)
variable "parameter_group_family" {
  description = "DB parameter group family (e.g., postgres14, mysql8.0)"
  type        = string
  default     = null
}

# Custom parameters
variable "custom_parameters" {
  description = "List of custom database parameters"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

# Environment
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# Project name
variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "my-project"
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
    deletion_protection         = optional(bool, false)
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
