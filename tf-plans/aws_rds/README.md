# AWS RDS Wrapper Module

This wrapper module simplifies the deployment of AWS RDS instances by providing a streamlined interface with sensible defaults while still supporting the full feature set of the underlying RDS module.

## Features

- 🚀 **Simplified Configuration**: Fewer variables for common use cases
- 📈 **Auto-Scaling**: Create multiple instances with a single `instance_count` variable
- 🔧 **Smart Defaults**: Automatically detects parameter group family based on engine
- 🏗️ **Infrastructure Automation**: Automatically creates subnet groups and parameter groups
- 🎯 **Environment-Aware**: Built-in support for environment and project tagging

## Quick Start

### 1. Basic PostgreSQL Database

```hcl
module "postgres_db" {
  source = "../../tf-plans/aws_rds"

  region               = "us-east-1"
  instance_name_prefix = "myapp-db"
  
  # Database Engine
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.micro"
  
  # Database Credentials
  db_name         = "myappdb"
  master_username = "dbadmin"
  master_password = var.db_password # Pass via variable or environment
  
  # Network Configuration
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-111", "subnet-222"]
  
  # Environment
  environment  = "dev"
  project_name = "my-project"
}
```

### 2. High-Availability MySQL Database

```hcl
module "mysql_ha" {
  source = "../../tf-plans/aws_rds"

  region               = "us-east-1"
  instance_name_prefix = "prod-mysql"
  
  # Database Engine
  engine         = "mysql"
  engine_version = "8.0.32"
  instance_class = "db.r6g.large"
  
  # Database Credentials
  db_name         = "proddb"
  master_username = "admin"
  master_password = var.db_password
  
  # Storage Configuration
  allocated_storage     = 100
  max_allocated_storage = 1000
  storage_type          = "gp3"
  storage_encrypted     = true
  
  # Network Configuration
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.db.id]
  
  # High Availability
  multi_az = true
  
  # Backup Configuration
  backup_retention_period = 30
  backup_window           = "03:00-04:00"
  skip_final_snapshot     = false
  
  # Monitoring
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 60
  enabled_cloudwatch_logs_exports       = ["error", "general", "slowquery"]
  
  # Security
  deletion_protection                 = true
  iam_database_authentication_enabled = true
  
  # Environment
  environment  = "prod"
  project_name = "my-project"
  
  tags = {
    Owner      = "DevOps Team"
    CostCenter = "Engineering"
  }
}
```

### 3. Multiple Database Instances (Scaling)

```hcl
module "multi_db" {
  source = "../../tf-plans/aws_rds"

  region               = "us-east-1"
  instance_name_prefix = "app-db"
  instance_count       = 3 # Creates app-db-1, app-db-2, app-db-3
  
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.small"
  
  db_name         = "appdb"
  master_username = "admin"
  master_password = var.db_password
  
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  environment  = "dev"
  project_name = "my-project"
}
```

### 4. Custom Database Parameters

```hcl
module "postgres_custom" {
  source = "../../tf-plans/aws_rds"

  region               = "us-east-1"
  instance_name_prefix = "postgres-custom"
  
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.medium"
  
  db_name         = "customdb"
  master_username = "admin"
  master_password = var.db_password
  
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  # Custom database parameters
  parameter_group_family = "postgres14"
  custom_parameters = [
    {
      name  = "max_connections"
      value = "200"
    },
    {
      name  = "shared_buffers"
      value = "256MB"
    },
    {
      name  = "effective_cache_size"
      value = "1GB"
    },
    {
      name  = "work_mem"
      value = "16MB"
    }
  ]
  
  environment  = "prod"
  project_name = "my-project"
}
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `master_password` | string | Master password for database (sensitive) |
| `vpc_id` | string | VPC ID where RDS will be deployed |
| `subnet_ids` | list(string) | List of subnet IDs for DB subnet group |

### Optional Configuration Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `region` | string | `"us-east-1"` | AWS region for deployment |
| `instance_count` | number | `1` | Number of RDS instances to create (1-10) |
| `instance_name_prefix` | string | `"rds-instance"` | Prefix for instance names |
| `environment` | string | `"dev"` | Environment name (dev, staging, prod) |
| `project_name` | string | `"my-project"` | Project name for tagging |

### Database Engine Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `engine` | string | `"postgres"` | Database engine (mysql, postgres, mariadb, oracle-*, sqlserver-*) |
| `engine_version` | string | `"14.7"` | Database engine version |
| `instance_class` | string | `"db.t3.micro"` | RDS instance class |
| `db_name` | string | `"mydb"` | Database name to create |
| `master_username` | string | `"admin"` | Master username |

### Storage Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `allocated_storage` | number | `20` | Initial storage allocation in GB |
| `max_allocated_storage` | number | `100` | Maximum storage for autoscaling (0 to disable) |
| `storage_type` | string | `"gp3"` | Storage type (gp2, gp3, io1, io2) |
| `storage_encrypted` | bool | `true` | Enable storage encryption |
| `kms_key_id` | string | `null` | KMS key ID for encryption (optional) |

### Network Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `security_group_ids` | list(string) | `[]` | Security group IDs for RDS instances |
| `publicly_accessible` | bool | `false` | Make instances publicly accessible |
| `multi_az` | bool | `false` | Enable Multi-AZ deployment |

### Backup Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `backup_retention_period` | number | `7` | Backup retention period in days (0-35) |
| `backup_window` | string | `"03:00-04:00"` | Preferred backup window |
| `skip_final_snapshot` | bool | `false` | Skip final snapshot on deletion |

### Maintenance Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `maintenance_window` | string | `"Mon:04:00-Mon:05:00"` | Preferred maintenance window |
| `auto_minor_version_upgrade` | bool | `true` | Enable automatic minor version upgrades |

### Monitoring Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `monitoring_interval` | number | `0` | Enhanced monitoring interval (0, 1, 5, 10, 15, 30, 60 seconds) |
| `performance_insights_enabled` | bool | `false` | Enable Performance Insights |
| `performance_insights_retention_period` | number | `7` | Performance Insights retention (7 or 731 days) |
| `enabled_cloudwatch_logs_exports` | list(string) | `[]` | CloudWatch log types to export |

### Security Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `deletion_protection` | bool | `false` | Enable deletion protection |
| `iam_database_authentication_enabled` | bool | `false` | Enable IAM database authentication |

### Advanced Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `parameter_group_family` | string | `null` | Parameter group family (auto-detected if null) |
| `custom_parameters` | list(object) | `[]` | List of custom database parameters |
| `tags` | map(string) | `{}` | Additional tags for resources |

## Outputs

| Output | Description |
|--------|-------------|
| `rds_instances` | Complete details of all RDS instances |
| `db_endpoints` | Database connection endpoints |
| `db_addresses` | Database hostnames |
| `db_arns` | Database ARNs |
| `db_ports` | Database port numbers |
| `db_resource_ids` | Database resource IDs |
| `availability_zones` | Availability zones where databases are deployed |
| `connection_strings` | Formatted connection strings (sensitive) |
| `db_subnet_groups` | Created DB subnet groups |
| `db_parameter_groups` | Created DB parameter groups |
| `latest_restorable_times` | Latest times for point-in-time recovery |
| `deployment_summary` | Summary of deployment configuration |

## Usage Examples

### Connect to Database

After deployment, retrieve the endpoint:

```bash
# Get the endpoint
terraform output db_endpoints

# Connect to PostgreSQL
psql -h <endpoint> -U admin -d myappdb

# Connect to MySQL
mysql -h <endpoint> -u admin -p myappdb
```

### Update Instance Count

```hcl
# Scale from 1 to 3 instances
module "rds" {
  source = "../../tf-plans/aws_rds"
  
  instance_count = 3 # Changed from 1
  # ... other variables
}
```

### Enable Performance Insights

```hcl
module "rds" {
  source = "../../tf-plans/aws_rds"
  
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  monitoring_interval                   = 60
  # ... other variables
}
```

## Best Practices

### Development Environment

```hcl
engine         = "postgres"
instance_class = "db.t3.micro"
multi_az       = false
backup_retention_period = 7
skip_final_snapshot     = true
deletion_protection     = false
```

### Production Environment

```hcl
engine         = "postgres"
instance_class = "db.r6g.large"
multi_az       = true
backup_retention_period = 30
skip_final_snapshot     = false
deletion_protection     = true
storage_encrypted       = true
performance_insights_enabled = true
monitoring_interval          = 60
iam_database_authentication_enabled = true
```

## Security Recommendations

1. **Use AWS Secrets Manager** for password management:
   ```hcl
   data "aws_secretsmanager_secret_version" "db_password" {
     secret_id = "prod/db/password"
   }
   
   module "rds" {
     master_password = data.aws_secretsmanager_secret_version.db_password.secret_string
   }
   ```

2. **Restrict network access** using security groups:
   ```hcl
   resource "aws_security_group" "db" {
     vpc_id = var.vpc_id
     
     ingress {
       from_port       = 5432
       to_port         = 5432
       protocol        = "tcp"
       security_groups = [aws_security_group.app.id]
     }
   }
   ```

3. **Enable encryption** for production databases
4. **Use private subnets** - never set `publicly_accessible = true` for production
5. **Enable deletion protection** for production databases

## Troubleshooting

### Connection Issues
- Verify security group rules allow inbound traffic on database port
- Check subnet routing and internet gateway configuration
- Ensure database is in "available" state

### Performance Issues
- Enable Performance Insights
- Review CloudWatch metrics
- Consider scaling instance class
- Optimize custom parameters

### Backup Issues
- Verify backup retention period is set appropriately
- Check backup window doesn't conflict with peak usage
- Ensure sufficient storage for automated backups

## Cost Estimation

- **db.t3.micro**: ~$12-15/month (dev/test)
- **db.t3.small**: ~$25-30/month (small workloads)
- **db.r6g.large**: ~$140-180/month (production)
- **Storage**: gp3 ~$0.08/GB/month
- **Backup Storage**: Free up to 100% of total database storage
- **Multi-AZ**: 2x instance cost
- **Performance Insights**: Free for 7 days retention

## License

Maintained as part of the aws.tf-modules project.
