# Variables for AWS Aurora wrapper module

# AWS Region
variable "region" {
  description = "AWS region for Aurora deployment"
  type        = string
  default     = "us-east-1"
}

# Number of Aurora clusters to create
variable "cluster_count" {
  description = "Number of Aurora clusters to create (for scaling)"
  type        = number
  default     = 1
  validation {
    condition     = var.cluster_count > 0 && var.cluster_count <= 5
    error_message = "Cluster count must be between 1 and 5"
  }
}

# Base cluster name prefix
variable "cluster_name_prefix" {
  description = "Prefix for Aurora cluster names"
  type        = string
  default     = "aurora-cluster"
}

# Database engine
variable "engine" {
  description = "Database engine (aurora-mysql, aurora-postgresql)"
  type        = string
  default     = "aurora-postgresql"
  validation {
    condition     = contains(["aurora-mysql", "aurora-postgresql"], var.engine)
    error_message = "Engine must be aurora-mysql or aurora-postgresql"
  }
}

# Engine version
variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = null # Uses latest version if not specified
}

# Engine mode
variable "engine_mode" {
  description = "Engine mode (provisioned, serverless, parallelquery, global)"
  type        = string
  default     = "provisioned"
  validation {
    condition     = contains(["provisioned", "serverless", "parallelquery", "global"], var.engine_mode)
    error_message = "Engine mode must be provisioned, serverless, parallelquery, or global"
  }
}

# Master credentials
variable "master_username" {
  description = "Master username for the database"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the database (use AWS Secrets Manager in production)"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "mydb"
}

# Instance configuration (for provisioned mode)
variable "instance_class" {
  description = "Aurora instance class (e.g., db.r6g.large, db.serverless for Serverless v2)"
  type        = string
  default     = "db.r6g.large"
}

variable "instance_count" {
  description = "Number of instances per cluster (1 writer + n-1 readers)"
  type        = number
  default     = 2
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 15
    error_message = "Instance count must be between 1 and 15"
  }
}

# Serverless v2 scaling configuration
variable "serverlessv2_min_capacity" {
  description = "Minimum Aurora Serverless v2 capacity in ACUs (0.5 to 128)"
  type        = number
  default     = null
}

variable "serverlessv2_max_capacity" {
  description = "Maximum Aurora Serverless v2 capacity in ACUs (0.5 to 128)"
  type        = number
  default     = null
}

# Serverless v1 scaling configuration
variable "serverless_min_capacity" {
  description = "Minimum Aurora Serverless v1 capacity units (2, 4, 8, 16, 32, 64, 128, 256)"
  type        = number
  default     = 2
}

variable "serverless_max_capacity" {
  description = "Maximum Aurora Serverless v1 capacity units (2, 4, 8, 16, 32, 64, 128, 256)"
  type        = number
  default     = 16
}

variable "serverless_auto_pause" {
  description = "Enable auto-pause for Serverless v1"
  type        = bool
  default     = true
}

variable "serverless_seconds_until_auto_pause" {
  description = "Seconds of inactivity before auto-pause (Serverless v1)"
  type        = number
  default     = 300
}

# Storage configuration
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

variable "storage_type" {
  description = "Storage type (aurora for standard, aurora-iopt1 for I/O-Optimized)"
  type        = string
  default     = null
}

# Network configuration
variable "vpc_id" {
  description = "VPC ID where Aurora will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for Aurora clusters"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "List of availability zones for the cluster"
  type        = list(string)
  default     = []
}

# Backup configuration
variable "backup_retention_period" {
  description = "Backup retention period in days (1-35)"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
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
variable "preferred_maintenance_window" {
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
  description = "List of log types to export (audit, error, general, slowquery for MySQL; postgresql for PostgreSQL)"
  type        = list(string)
  default     = []
}

# Advanced features
variable "enable_http_endpoint" {
  description = "Enable Data API HTTP endpoint (Serverless v1 only)"
  type        = bool
  default     = false
}

variable "backtrack_window" {
  description = "Target backtrack window in seconds (0-259200, MySQL only)"
  type        = number
  default     = 0
}

variable "iam_database_authentication_enabled" {
  description = "Enable IAM database authentication"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# Parameter group family (auto-detected based on engine if not provided)
variable "cluster_parameter_group_family" {
  description = "DB cluster parameter group family (e.g., aurora-mysql8.0, aurora-postgresql14)"
  type        = string
  default     = null
}

variable "instance_parameter_group_family" {
  description = "DB instance parameter group family"
  type        = string
  default     = null
}

# Custom parameters
variable "custom_cluster_parameters" {
  description = "List of custom cluster parameters"
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string, "immediate")
  }))
  default = []
}

variable "custom_instance_parameters" {
  description = "List of custom instance parameters"
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
