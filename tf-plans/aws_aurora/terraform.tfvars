# Example terraform.tfvars for AWS Aurora deployment
# Copy this file to terraform.tfvars and customize values

# AWS Configuration
region = "us-east-1"

# Aurora Cluster Configuration
cluster_count       = 1
cluster_name_prefix = "myapp-aurora"

# Database Engine Configuration
engine         = "aurora-postgresql"
engine_version = "14.7"
engine_mode    = "provisioned" # provisioned, serverless, parallelquery

# Database Configuration
database_name   = "myappdb"
master_username = "dbadmin"
# master_password = "CHANGE_ME_STRONG_PASSWORD" # Set via environment variable or AWS Secrets Manager

# Instance Configuration (for provisioned mode)
instance_class = "db.r6g.large"
instance_count = 2 # 1 writer + 1 reader

# Serverless v2 Scaling (for Serverless v2 with provisioned mode)
# Uncomment to enable Serverless v2 scaling
# instance_class = "db.serverless"
# serverlessv2_min_capacity = 0.5  # Minimum ACUs
# serverlessv2_max_capacity = 2.0  # Maximum ACUs

# Serverless v1 Configuration (for engine_mode = "serverless")
# serverless_min_capacity            = 2   # 2, 4, 8, 16, 32, 64, 128, 256
# serverless_max_capacity            = 16
# serverless_auto_pause              = true
# serverless_seconds_until_auto_pause = 300

# Storage Configuration
storage_encrypted = true
# kms_key_id      = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
# storage_type    = "aurora-iopt1" # Use aurora-iopt1 for I/O-Optimized

# Network Configuration
vpc_id             = "vpc-0123456789abcdef0"
subnet_ids         = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1", "subnet-0123456789abcdef2"]
security_group_ids = ["sg-0123456789abcdef0"]
# availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Backup Configuration
backup_retention_period = 7
preferred_backup_window = "03:00-04:00"
skip_final_snapshot     = false # Set to true for dev/test environments

# Maintenance Configuration
preferred_maintenance_window = "Mon:04:00-Mon:05:00"
auto_minor_version_upgrade   = true

# Monitoring Configuration
monitoring_interval                   = 0     # 0 disables enhanced monitoring, use 60 for 1-minute intervals
performance_insights_enabled          = false # Set to true for production
performance_insights_retention_period = 7

# CloudWatch Logs (examples for different engines)
# PostgreSQL: ["postgresql"]
# MySQL: ["audit", "error", "general", "slowquery"]
enabled_cloudwatch_logs_exports = []

# Advanced Features
enable_http_endpoint                = false # Enable Data API (Serverless v1 only)
backtrack_window                    = 0     # Target backtrack window in seconds (MySQL only, 0-259200)
iam_database_authentication_enabled = false
deletion_protection                 = false # Set to true for production

# Custom Cluster Parameters (optional)
# cluster_parameter_group_family = "aurora-postgresql14"
# custom_cluster_parameters = [
#   {
#     name  = "shared_preload_libraries"
#     value = "pg_stat_statements,auto_explain"
#   },
#   {
#     name  = "log_statement"
#     value = "all"
#   }
# ]

# Custom Instance Parameters (optional)
# instance_parameter_group_family = "aurora-postgresql14"
# custom_instance_parameters = [
#   {
#     name  = "max_connections"
#     value = "100"
#   }
# ]

# Tags
environment  = "dev"
project_name = "my-project"
tags = {
  Owner      = "DevOps Team"
  CostCenter = "Engineering"
  Terraform  = "true"
}

# =============================================================================
# Engine-Specific Examples
# =============================================================================

# Example 1: Aurora PostgreSQL (Provisioned)
# engine         = "aurora-postgresql"
# engine_version = "14.7"
# engine_mode    = "provisioned"
# instance_class = "db.r6g.large"
# instance_count = 2
# enabled_cloudwatch_logs_exports = ["postgresql"]

# Example 2: Aurora MySQL (Provisioned with Backtrack)
# engine         = "aurora-mysql"
# engine_version = "8.0.mysql_aurora.3.04.0"
# engine_mode    = "provisioned"
# instance_class = "db.r6g.large"
# instance_count = 3
# backtrack_window = 86400 # 24 hours
# enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

# Example 3: Aurora Serverless v2 (PostgreSQL)
# engine         = "aurora-postgresql"
# engine_version = "14.7"
# engine_mode    = "provisioned"
# instance_class = "db.serverless"
# instance_count = 2
# serverlessv2_min_capacity = 0.5
# serverlessv2_max_capacity = 4.0

# Example 4: Aurora Serverless v1 (MySQL)
# engine         = "aurora-mysql"
# engine_version = "5.7.mysql_aurora.2.11.2"
# engine_mode    = "serverless"
# serverless_min_capacity = 2
# serverless_max_capacity = 16
# serverless_auto_pause   = true
# enable_http_endpoint    = true

# Example 5: Aurora I/O-Optimized (PostgreSQL)
# engine         = "aurora-postgresql"
# engine_version = "14.7"
# engine_mode    = "provisioned"
# storage_type   = "aurora-iopt1"
# instance_class = "db.r6g.large"
# instance_count = 2
