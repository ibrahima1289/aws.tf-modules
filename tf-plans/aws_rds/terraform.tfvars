# Example terraform.tfvars for AWS RDS deployment with Writer/Reader in specific AZs
# This configuration uses direct module variables for granular control over writer and reader placement

# AWS Configuration
region = "us-east-1"

# Network Configuration (shared)
vpc_id     = "vpc-0123456789abcdef0"
subnet_ids = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]

# Tags (shared)
environment  = "dev"
project_name = "my-project"
tags = {
  Owner      = "DevOps Team"
  CostCenter = "Engineering"
  Compliance = "Standard"
  Terraform  = "true"
}

# =============================================================================
# Writer/Reader Configuration with Specific Availability Zones
# =============================================================================
# This configuration creates:
# - Writer DB in us-east-1a (myapp-db-writer)
# - Reader DB in us-east-1b (myapp-db-reader-1)

# Note: When using direct module configuration, update main.tf to pass rds_instances
# instead of using the wrapper's instance_count variable

rds_instances = {
  # Primary Writer Instance - us-east-1a
  "myapp-db-writer" = {
    # Engine configuration
    engine         = "postgres"
    engine_version = "14.7"
    instance_class = "db.t3.micro"

    # Database credentials
    db_name  = "myappdb"
    username = "dbadmin"
    password = "CHANGE_ME_STRONG_PASSWORD" # Use AWS Secrets Manager in production

    # Storage configuration
    allocated_storage     = 20
    max_allocated_storage = 100
    storage_type          = "gp3"
    storage_encrypted     = true

    # Network configuration - Writer in us-east-1a
    db_subnet_group_name   = "myapp-db-subnet-group"
    vpc_security_group_ids = ["sg-0123456789abcdef0"]
    publicly_accessible    = false
    availability_zone      = "us-east-1a" # Writer in AZ us-east-1a
    multi_az               = false

    # Backup configuration
    backup_retention_period = 7
    backup_window           = "03:00-04:00"
    skip_final_snapshot     = false
    copy_tags_to_snapshot   = true

    # Maintenance and monitoring
    maintenance_window              = "Mon:04:00-Mon:05:00"
    auto_minor_version_upgrade      = true
    enabled_cloudwatch_logs_exports = ["postgresql"]
    monitoring_interval             = 60 # Enhanced monitoring enabled
    performance_insights_enabled    = true

    # Security
    deletion_protection                 = false # Set to true for production
    iam_database_authentication_enabled = false

    # Tags
    tags = {
      Role = "Writer"
      AZ   = "us-east-1a"
    }
  }

  # Read Replica 1 - us-east-1b
  # Note: Read replicas inherit engine, engine_version, username, password, and db_name from source
  "myapp-db-reader-1" = {
    # Instance configuration
    instance_class = "db.t3.micro"

    # Storage configuration
    allocated_storage = 20
    storage_type      = "gp3"
    storage_encrypted = true

    # Network configuration - Reader in us-east-1b
    availability_zone      = "us-east-1b" # Reader in AZ us-east-1b
    vpc_security_group_ids = ["sg-0123456789abcdef0"]
    publicly_accessible    = false

    # Read replica configuration
    replicate_source_db = "myapp-db-writer" # References the primary writer

    # Monitoring (can be different from primary)
    monitoring_interval          = 60
    performance_insights_enabled = true

    # Backup settings
    backup_retention_period = 0 # Read replicas don't perform backups
    skip_final_snapshot     = true

    # Security
    deletion_protection = false

    # Tags
    tags = {
      Role = "Reader"
      AZ   = "us-east-1b"
    }
  }

  # Optional: Additional Read Replica - us-east-1c
  # "myapp-db-reader-2" = {
  #   instance_class         = "db.t3.micro"
  #   availability_zone      = "us-east-1c" # Reader in AZ us-east-1c
  #   vpc_security_group_ids = ["sg-0123456789abcdef0"]
  #   replicate_source_db    = "myapp-db-writer"
  #   storage_type           = "gp3"
  #   monitoring_interval    = 60
  #   skip_final_snapshot    = true
  #   tags = {
  #     Role = "Reader"
  #     AZ   = "us-east-1c"
  #   }
  # }
}

# DB Subnet Groups
db_subnet_groups = {
  "myapp-db-subnet-group" = {
    description = "DB subnet group for my-project dev"
    subnet_ids  = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
    tags = {
      Environment = "dev"
      Project     = "my-project"
    }
  }
}

# Optional: Custom Parameter Group
# parameter_groups = {
#   "myapp-db-params" = {
#     family      = "postgres14"
#     description = "Custom parameters for PostgreSQL 14"
#     parameters = [
#       {
#         name  = "max_connections"
#         value = "100"
#       },
#       {
#         name  = "shared_buffers"
#         value = "256MB"
#       }
#     ]
#   }
# }

# =============================================================================
# Notes
# =============================================================================
# - Writer instance is created in us-east-1a with full database functionality
# - Reader instance is a read replica in us-east-1b for read scaling
# - Read replicas inherit engine, db_name, username, password from writer
# - For Multi-AZ high availability, set multi_az = true on writer instead
# - For Aurora-style writer/reader clusters, use the aws_aurora module
