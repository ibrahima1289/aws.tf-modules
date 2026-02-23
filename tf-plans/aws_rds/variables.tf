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
