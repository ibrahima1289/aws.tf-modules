# AWS RDS Terraform Module

This Terraform module creates and manages AWS RDS (Relational Database Service) instances with support for all available database engines including MySQL, PostgreSQL, MariaDB, Oracle, and SQL Server.

## Features

- ✅ **Multi-Engine Support**: MySQL, PostgreSQL, MariaDB, Oracle (EE, SE2, SE1, SE), SQL Server (EE, SE, EX, Web)
- ✅ **Multi-Instance Deployment**: Create and manage multiple RDS instances with a single configuration
- ✅ **Comprehensive Configuration**: Support for all RDS parameters and features
- ✅ **Storage Autoscaling**: Automatic storage scaling with configurable limits
- ✅ **High Availability**: Multi-AZ deployment support
- ✅ **Backup & Recovery**: Automated backups, snapshots, and point-in-time recovery
- ✅ **Security**: Encryption at rest, IAM authentication, VPC security groups
- ✅ **Monitoring**: CloudWatch logs, Performance Insights, Enhanced Monitoring
- ✅ **Custom Parameter/Option Groups**: Support for database-specific configurations
- ✅ **Read Replicas**: Create read replicas for read-heavy workloads
- ✅ **Blue/Green Deployments**: Safe deployment strategy for updates

## Supported Database Engines

| Engine | Supported Versions | License Model |
|--------|-------------------|---------------|
| PostgreSQL | 11.x - 15.x | PostgreSQL License |
| MySQL | 5.7.x, 8.0.x | GPL |
| MariaDB | 10.4.x - 10.6.x | GPL |
| Oracle Database | 12.2, 19c, 21c | BYOL / License Included |
| SQL Server | 2016, 2017, 2019, 2022 | License Included |

## Usage

### Basic Example

```hcl
module "rds" {
  source = "../../modules/databases/relational/aws_rds"

  region = "us-east-1"

  # Create a single PostgreSQL instance
  rds_instances = {
    "my-postgres-db" = {
      engine         = "postgres"
      engine_version = "14.7"
      instance_class = "db.t3.micro"
      
      username = "dbadmin"
      password = "ChangeMe123!" # Use AWS Secrets Manager in production
      db_name  = "myappdb"
      
      allocated_storage = 20
      storage_encrypted = true
      
      db_subnet_group_name   = "my-db-subnet-group"
      vpc_security_group_ids = ["sg-0123456789abcdef0"]
      
      backup_retention_period = 7
      multi_az                = false
    }
  }

  # Create DB subnet group
  db_subnet_groups = {
    "my-db-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222"]
    }
  }
}
```

### Multi-Instance Example

```hcl
module "rds" {
  source = "../../modules/databases/relational/aws_rds"

  region = "us-east-1"

  # Create multiple database instances
  rds_instances = {
    "app-db-primary" = {
      engine         = "mysql"
      engine_version = "8.0.32"
      instance_class = "db.r6g.large"
      
      username = "admin"
      password = var.db_password
      db_name  = "appdb"
      
      allocated_storage     = 100
      max_allocated_storage = 1000
      storage_type          = "gp3"
      storage_encrypted     = true
      
      db_subnet_group_name   = "app-db-subnet-group"
      vpc_security_group_ids = ["sg-0123456789abcdef0"]
      
      multi_az                = true
      backup_retention_period = 30
      deletion_protection     = true
      
      performance_insights_enabled = true
      monitoring_interval          = 60
    }
    
    "app-db-replica" = {
      engine              = "mysql"
      instance_class      = "db.r6g.large"
      replicate_source_db = "app-db-primary"
      
      storage_encrypted = true
      multi_az          = false
      
      vpc_security_group_ids = ["sg-0123456789abcdef0"]
    }
  }

  db_subnet_groups = {
    "app-db-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]
    }
  }
}
```

### Oracle Database Example

```hcl
module "oracle_rds" {
  source = "../../modules/databases/relational/aws_rds"

  region = "us-east-1"

  rds_instances = {
    "oracle-prod-db" = {
      engine         = "oracle-ee"
      engine_version = "19.0.0.0.ru-2023-01.rur-2023-01.r1"
      instance_class = "db.m6i.xlarge"
      license_model  = "bring-your-own-license"
      
      username = "admin"
      password = var.oracle_password
      
      allocated_storage     = 200
      max_allocated_storage = 1000
      storage_type          = "io1"
      iops                  = 3000
      storage_encrypted     = true
      
      db_subnet_group_name   = "oracle-subnet-group"
      vpc_security_group_ids = ["sg-oracle"]
      
      multi_az                = true
      backup_retention_period = 35
      deletion_protection     = true
      
      option_group_name    = "oracle-options"
      parameter_group_name = "oracle-params"
    }
  }

  db_subnet_groups = {
    "oracle-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222"]
    }
  }

  option_groups = {
    "oracle-options" = {
      engine_name          = "oracle-ee"
      major_engine_version = "19"
      options = [
        {
          option_name = "STATSPACK"
        }
      ]
    }
  }

  parameter_groups = {
    "oracle-params" = {
      family = "oracle-ee-19"
      parameters = [
        {
          name  = "open_cursors"
          value = "2000"
        }
      ]
    }
  }
}
```

### SQL Server Example

```hcl
module "sqlserver_rds" {
  source = "../../modules/databases/relational/aws_rds"

  region = "us-east-1"

  rds_instances = {
    "sqlserver-app-db" = {
      engine         = "sqlserver-se"
      engine_version = "15.00.4236.7.v1"
      instance_class = "db.m5.large"
      license_model  = "license-included"
      
      username = "admin"
      password = var.sqlserver_password
      
      allocated_storage = 100
      storage_type      = "gp3"
      storage_encrypted = true
      
      timezone = "Central Standard Time"
      
      db_subnet_group_name   = "sqlserver-subnet-group"
      vpc_security_group_ids = ["sg-sqlserver"]
      
      backup_retention_period = 7
      multi_az                = true
    }
  }

  db_subnet_groups = {
    "sqlserver-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222"]
    }
  }
}
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | string | AWS region where RDS instances will be created |
| `rds_instances` | map(object) | Map of RDS instance configurations (see structure below) |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `db_subnet_groups` | map(object) | `{}` | Map of DB subnet groups to create |
| `parameter_groups` | map(object) | `{}` | Map of DB parameter groups to create |
| `option_groups` | map(object) | `{}` | Map of DB option groups to create |

### RDS Instance Object Structure

Each instance in the `rds_instances` map supports the following attributes:

#### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `engine` | string | Database engine (mysql, postgres, mariadb, oracle-ee, oracle-se2, sqlserver-ee, etc.) |
| `engine_version` | string | Database engine version |
| `instance_class` | string | RDS instance type (e.g., db.t3.micro, db.r6g.large) |
| `username` | string | Master username for the database |
| `password` | string | Master password (use AWS Secrets Manager in production) |
| `allocated_storage` | number | Initial storage allocation in GB |

#### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `db_name` | string | `null` | Name of the database to create |
| `max_allocated_storage` | number | `null` | Maximum storage for autoscaling in GB |
| `storage_type` | string | `"gp3"` | Storage type (gp2, gp3, io1, io2) |
| `storage_encrypted` | bool | `true` | Enable storage encryption |
| `kms_key_id` | string | `null` | KMS key ID for encryption |
| `iops` | number | `null` | Provisioned IOPS (for io1/io2) |
| `storage_throughput` | number | `null` | Storage throughput in MB/s (for gp3) |
| `db_subnet_group_name` | string | `null` | DB subnet group name |
| `vpc_security_group_ids` | list(string) | `null` | VPC security group IDs |
| `publicly_accessible` | bool | `false` | Make instance publicly accessible |
| `availability_zone` | string | `null` | Specific AZ for single-AZ deployment |
| `multi_az` | bool | `false` | Enable Multi-AZ deployment |
| `port` | number | `null` | Database port (auto-detected if not specified) |
| `parameter_group_name` | string | `null` | DB parameter group name |
| `option_group_name` | string | `null` | DB option group name |
| `character_set_name` | string | `null` | Character set (Oracle/SQL Server) |
| `timezone` | string | `null` | Timezone (SQL Server) |
| `license_model` | string | `null` | License model |
| `backup_retention_period` | number | `7` | Backup retention in days (0-35) |
| `backup_window` | string | `null` | Preferred backup window |
| `copy_tags_to_snapshot` | bool | `true` | Copy tags to snapshots |
| `skip_final_snapshot` | bool | `false` | Skip final snapshot on deletion |
| `final_snapshot_identifier` | string | `null` | Final snapshot identifier |
| `snapshot_identifier` | string | `null` | Snapshot ID to restore from |
| `maintenance_window` | string | `null` | Preferred maintenance window |
| `auto_minor_version_upgrade` | bool | `true` | Enable automatic minor version upgrades |
| `apply_immediately` | bool | `false` | Apply changes immediately |
| `enabled_cloudwatch_logs_exports` | list(string) | `[]` | CloudWatch log types to export |
| `monitoring_interval` | number | `0` | Enhanced monitoring interval (0, 1, 5, 10, 15, 30, 60) |
| `monitoring_role_arn` | string | `null` | IAM role ARN for enhanced monitoring |
| `performance_insights_enabled` | bool | `false` | Enable Performance Insights |
| `performance_insights_retention_period` | number | `7` | Performance Insights retention (7 or 731 days) |
| `iam_database_authentication_enabled` | bool | `false` | Enable IAM database authentication |
| `deletion_protection` | bool | `false` | Enable deletion protection |
| `replicate_source_db` | string | `null` | Source DB identifier for read replicas |
| `tags` | map(string) | `{}` | Additional tags for the instance |

## Outputs

| Output | Description |
|--------|-------------|
| `rds_instances` | Map of all RDS instance attributes |
| `db_instance_endpoints` | Map of connection endpoints |
| `db_instance_addresses` | Map of database addresses (hostname) |
| `db_instance_arns` | Map of database ARNs |
| `db_instance_resource_ids` | Map of database resource IDs |
| `db_instance_ports` | Map of database ports |
| `db_instance_availability_zones` | Map of availability zones |
| `db_subnet_groups` | Map of created DB subnet groups |
| `db_parameter_groups` | Map of created DB parameter groups |
| `db_option_groups` | Map of created DB option groups |
| `connection_strings` | Map of formatted connection strings (sensitive) |
| `latest_restorable_times` | Map of latest restorable times for PITR |

## Important Notes

### Security Best Practices

1. **Never hardcode passwords** - Use AWS Secrets Manager or Parameter Store
2. **Enable encryption** - Always set `storage_encrypted = true` for production
3. **Use private subnets** - Set `publicly_accessible = false`
4. **Enable deletion protection** - Set `deletion_protection = true` for production databases
5. **Use VPC security groups** - Restrict access to specific IP ranges or security groups
6. **Enable Multi-AZ** - For production databases requiring high availability

### Backup & Recovery

1. Set appropriate `backup_retention_period` (7-35 days for production)
2. Configure `backup_window` to avoid peak usage times
3. Enable `copy_tags_to_snapshot` for better resource tracking
4. Set `skip_final_snapshot = false` for production databases

### Performance Optimization

1. Choose appropriate `instance_class` based on workload
2. Enable `performance_insights_enabled` for performance monitoring
3. Use `gp3` storage type for better price/performance ratio
4. Enable `max_allocated_storage` for automatic storage scaling
5. Configure appropriate `iops` and `storage_throughput` for gp3/io1/io2

### Cost Optimization

1. Use `db.t3` instances for development/testing
2. Enable storage autoscaling to avoid over-provisioning
3. Set appropriate backup retention periods
4. Use `auto_minor_version_upgrade` to get security patches automatically
5. Consider Reserved Instances for production workloads

## Engine-Specific Considerations

### PostgreSQL
- Recommended for ACID compliance and advanced features
- CloudWatch logs: `["postgresql"]`
- Supports logical replication

### MySQL
- Wide ecosystem support
- CloudWatch logs: `["audit", "error", "general", "slowquery"]`
- Consider Aurora MySQL for better scalability

### MariaDB
- Drop-in MySQL replacement
- Better performance in some scenarios

### Oracle
- Requires larger instance types (minimum db.t3.medium)
- Choose license model: `bring-your-own-license` or `license-included`
- Use option groups for Oracle features

### SQL Server
- Requires larger instance types (minimum db.t3.small)
- License included in cost
- Set `timezone` parameter
- Limited backup retention (max 35 days)

## License

This module is maintained as part of the aws.tf-modules project.

## Author

Created: ${local.created_date}
Managed by: Terraform
