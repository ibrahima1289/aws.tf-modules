# Example terraform.tfvars for AWS RDS deployment
# Copy this file to terraform.tfvars and customize values

# AWS Configuration
region = "us-east-1"

# RDS Scaling Configuration
instance_count       = 2
instance_name_prefix = "myapp-db"

# Database Engine Configuration
engine         = "postgres"
engine_version = "14.7"
instance_class = "db.t3.micro"

# Database Configuration
db_name         = "myappdb"
master_username = "dbadmin"
# master_password = "CHANGE_ME_STRONG_PASSWORD" # Set via environment variable or AWS Secrets Manager

# Storage Configuration
allocated_storage     = 20
max_allocated_storage = 100
storage_type          = "gp3"
storage_encrypted     = true
# kms_key_id          = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Network Configuration
vpc_id              = "vpc-0123456789abcdef0"
subnet_ids          = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
security_group_ids  = ["sg-0123456789abcdef0"]
publicly_accessible = false
multi_az            = false

# Backup Configuration
backup_retention_period = 7
backup_window           = "03:00-04:00"
skip_final_snapshot     = false # Set to true for dev/test environments

# Maintenance Configuration
maintenance_window         = "Mon:04:00-Mon:05:00"
auto_minor_version_upgrade = true

# Monitoring Configuration
monitoring_interval                   = 0     # 0 disables enhanced monitoring, use 60 for 1-minute intervals
performance_insights_enabled          = false # Set to true for production
performance_insights_retention_period = 7

# CloudWatch Logs (examples for different engines)
# PostgreSQL: ["postgresql"]
# MySQL/MariaDB: ["audit", "error", "general", "slowquery"]
enabled_cloudwatch_logs_exports = []

# Security Configuration
deletion_protection                 = false # Set to true for production
iam_database_authentication_enabled = false

# Custom Parameters (optional)
# parameter_group_family = "postgres14"
# custom_parameters = [
#   {
#     name  = "max_connections"
#     value = "100"
#   },
#   {
#     name  = "shared_buffers"
#     value = "256MB"
#   }
# ]

# Tags
environment  = "dev"
project_name = "my-project"
tags = {
  Owner      = "DevOps Team"
  CostCenter = "Engineering"
  Compliance = "Standard"
  Terraform  = "true"
}

# =============================================================================
# Engine-Specific Examples
# =============================================================================

# PostgreSQL Example:
# engine         = "postgres"
# engine_version = "14.7"
# enabled_cloudwatch_logs_exports = ["postgresql"]

# MySQL Example:
# engine         = "mysql"
# engine_version = "8.0.32"
# enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

# MariaDB Example:
# engine         = "mariadb"
# engine_version = "10.6.12"

# Oracle SE2 Example:
# engine         = "oracle-se2"
# engine_version = "19.0.0.0.ru-2023-01.rur-2023-01.r1"
# instance_class = "db.t3.medium" # Oracle requires larger instances

# SQL Server Express Example:
# engine         = "sqlserver-ex"
# engine_version = "15.00.4236.7.v1"
# instance_class = "db.t3.small" # SQL Server requires larger instances
