# AWS Aurora Terraform Module

This Terraform module creates and manages AWS Aurora database clusters with support for Aurora MySQL and Aurora PostgreSQL, including Serverless v1, Serverless v2, provisioned, and global database configurations.

## Features

- ✅ **Multi-Engine Support**: Aurora MySQL, Aurora PostgreSQL
- ✅ **Multi-Cluster Deployment**: Create and manage multiple Aurora clusters with a single configuration
- ✅ **Serverless v1**: Auto-scaling database with automatic pause/resume
- ✅ **Serverless v2**: Instantly scalable compute with ACU-based pricing (0.5-128 ACUs)
- ✅ **Provisioned Clusters**: Traditional instance-based deployment with reader instances
- ✅ **Global Databases**: Multi-region, low-latency global replication
- ✅ **High Availability**: Multi-AZ deployment with automatic failover
- ✅ **Backtrack**: Rewind database to a previous point in time (MySQL only)
- ✅ **I/O-Optimized Storage**: Predictable pricing for high I/O workloads
- ✅ **Custom Endpoints**: Create custom reader endpoints for specific workload routing
- ✅ **Security**: Encryption at rest (KMS), IAM authentication, VPC integration
- ✅ **Monitoring**: CloudWatch logs, Performance Insights, Enhanced Monitoring
- ✅ **Data API**: HTTP-based query interface for Serverless v1

## Aurora vs RDS

| Feature | Aurora | RDS |
|---------|--------|-----|
| **Architecture** | Cluster-based (distributed storage) | Single instance |
| **Storage** | Automatically grows up to 128 TB | Manual scaling up to 64 TB |
| **Replicas** | Up to 15 read replicas (same cluster) | Up to 15 read replicas (separate instances) |
| **Failover** | < 30 seconds (automatic) | 60-120 seconds |
| **Performance** | 5x MySQL, 3x PostgreSQL | Standard performance |
| **Backtrack** | Yes (MySQL only) | No |
| **Global Database** | Yes (multi-region) | Read replicas only |
| **Serverless** | v1 and v2 available | Not available |
| **Pricing** | Instance + I/O + storage | Instance + storage |

## Architecture

Aurora uses a unique cloud-native architecture that separates storage from compute, providing superior performance, availability, and scalability compared to traditional databases.

### Aurora Cluster Components

```
┌───────────────────────────────────────────────────────────────────────┐
│                        Aurora DB Cluster                              │
│                                                                       │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐           │
│  │  Writer        │  │  Reader        │  │  Reader        │           │
│  │  Instance      │  │  Instance      │  │  Instance      │           │
│  │  (Primary)     │  │  (Replica 1)   │  │  (Replica 2)   │           │
│  │                │  │                │  │                │           │
│  │ Promotion      │  │ Promotion      │  │ Promotion      │           │
│  │ Tier: 0        │  │ Tier: 1        │  │ Tier: 2        │           │
│  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘           │
│          │                   │                   │                    │
│          └───────────────────┼───────────────────┘                    │
│                              │                                        │
│                    ┌─────────▼───────────┐                            │
│                    │  Cluster Volume     │                            │
│                    │  (Shared Storage)   │                            │
│                    │                     │                            │
│                    │  ┌────────────────┐ │                            │
│                    │  │ AZ 1 (2 copies)| │                            │
│                    │  ├────────────────┤ │                            │
│                    │  │ AZ 2 (2 copies)| │                            │
│                    │  ├────────────────┤ │                            │
│                    │  │ AZ 3 (2 copies)| │                            │
│                    │  └────────────────┘ │                            │
│                    │                     │                            |
|                    └─────────────────────┘                            │
│                              |                                        |
|             ┌────────────────▼──────────────┐                         |
|             │  • 6-way replication          |                         │
│             │  • Auto-scales to 128 TB      |                         │
│             │  • Self-healing               |                         │
│             │  • Continuous backup to S3    |                         │
│             └───────────────────────────────┘                         │
│                                                                       |
└───────────────────────────────────────────────────────────────────────┘
       
┌───────────────────────────────────────────────────────────────────────────────────────────┐
│  Endpoints:                                                                               │
│  • Cluster Endpoint (writer): my-cluster.cluster-xxxxx.region.rds.amazonaws.com           |
│  • Reader Endpoint (load-balanced): my-cluster.cluster-ro-xxxxx.region.rds.amazonaws.com  |
│  • Instance Endpoints: my-cluster-instance-1.xxxxx.region.rds.amazonaws.com               |
│  • Custom Endpoints: my-custom-endpoint.cluster-custom-xxxxx.region.rds.amazonaws.com     |
└───────────────────────────────────────────────────────────────────────────────────────────┘
```

### Storage Layer (Cluster Volume)

The Aurora storage layer is purpose-built for the cloud:

- **6-Way Replication**: Data is automatically replicated 6 times across 3 Availability Zones (2 copies per AZ)
- **Quorum-Based**: Writes require acknowledgment from 4 of 6 copies; reads require 3 of 6 copies
- **Self-Healing**: Continuously scans data blocks and repairs them automatically
- **Auto-Scaling**: Grows automatically in 10 GB increments up to 128 TB without downtime
- **Log-Structured**: Redo logs are written directly to storage, reducing write latency
- **Continuous Backup**: Transaction logs continuously backed up to Amazon S3

### Compute Layer (DB Instances)

Aurora separates compute from storage for independent scaling:

- **Writer Instance** (Primary):
  - Handles all write operations (`INSERT`, `UPDATE`, `DELETE`)
  - Can also serve read queries
  - Only one writer per cluster
  - Promotion Tier 0 (highest priority for failover target)

- **Reader Instances** (Replicas):
  - Handle read-only queries (`SELECT`)
  - Up to 15 readers per cluster
  - Share the same storage volume (no replication lag for storage)
  - Typical replication lag: 10-20 milliseconds
  - Automatically promoted to writer if primary fails
  - Can have different instance classes than writer

### High Availability & Failover

**Automatic Failover Process** (< 30 seconds):
1. Aurora detects primary instance failure
2. Promotes reader with highest priority (lowest tier number)
3. Updates DNS endpoint to point to new primary
4. No data loss (shared storage volume)

**Multi-AZ Deployment**:
- Instances distributed across multiple Availability Zones
- Storage always spans 3 AZs regardless of number of instances
- Automatic failover to healthy AZ

### Global Database Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                     Aurora Global Database                       │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Primary Region (us-east-1)          Secondary Region (eu-west-1)│
│  ┌─────────────────────┐              ┌─────────────────────┐    │
│  │  Writer Instance    │              │  Reader Instances   │    │
│  │  Reader Instances   │────────────▶|  (Read-Only)         │   │
│  │                     │  Replication │                     │    │
│  │  Cluster Volume     │  < 1 second  │  Cluster Volume     │    │
│  │  (Read-Write)       │              │  (Read-Only)        │    │
│  └─────────────────────┘              └─────────────────────┘    │
│                                                                  │
│  Additional Secondary Regions (optional, up to 5 total):         │
│  ┌─────────────────────┐             ┌─────────────────────┐     │
│  │  ap-south-1         │             │  ap-northeast-1     │     │
│  │  Reader Instances   │             │  Reader Instances   │     │
│  │  Cluster Volume     │             │  Cluster Volume     │     │
│  └─────────────────────┘             └─────────────────────┘     │
│                                                                  │
│  Features:                                                       │
│  • RPO: < 1 second (data loss)                                   │
│  • RTO: < 1 minute (recovery time)                               │
│  • Write forwarding: Route writes to primary from any region     │
│  • Low-latency reads: Local reads in each region                 │
└──────────────────────────────────────────────────────────────────┘
```

### Serverless Architecture

**Serverless v2**:
```
Application ──▶ Aurora Proxy ──▶ Scaling Layer ──▶ Cluster Volume
                                 (0.5-128 ACUs)
                                 Scales in seconds
```

**Serverless v1**:
```
Application ──▶ Aurora Proxy ──▶ Warm Pool ──▶ Cluster Volume
                                 (2-256 ACUs)
                                 Auto-pause after inactivity
```

### Endpoints and Connection Routing

| Endpoint Type | Use Case | Behavior |
|---------------|----------|----------|
| **Cluster Endpoint** | Write operations | Always routes to current writer instance |
| **Reader Endpoint** | Read scaling | Load-balances across all reader instances |
| **Instance Endpoint** | Direct access | Connects to specific instance (writer or reader) |
| **Custom Endpoint** | Workload isolation | Routes to user-defined subset of instances |

**Connection Example**:
```
Write Traffic → Cluster Endpoint → Writer Instance → Cluster Volume
Read Traffic  → Reader Endpoint  → Reader Instance → Cluster Volume
Analytics     → Custom Endpoint  → Specific Readers → Cluster Volume
```

## Supported Configurations

### Engine Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **provisioned** | Traditional instance-based with configurable read replicas | Production workloads, predictable traffic |
| **serverless** | Serverless v1 with automatic scaling and pause | Infrequent or unpredictable workloads |
| **parallelquery** | Optimized for analytical queries (MySQL only) | Analytics on operational data |
| **global** | Multi-region replication | Disaster recovery, global applications |

### Instance Classes (Provisioned Mode)

| Family | Description | Example |
|--------|-------------|---------|
| **T3/T4g** | Burstable performance | db.t3.medium, db.t4g.medium |
| **R5/R6g/R6i** | Memory-optimized | db.r6g.large, db.r6i.xlarge |
| **X2g** | Memory-optimized (high memory) | db.x2g.xlarge |
| **Serverless** | Serverless v2 (requires serverlessv2_scaling_configuration) | db.serverless |

## Usage

### Basic Provisioned Cluster (PostgreSQL)

```hcl
module "aurora" {
  source = "../../modules/databases/relational/aws_aurora"

  region = "us-east-1"

  # Create a single Aurora PostgreSQL cluster
  aurora_clusters = {
    "my-postgres-cluster" = {
      engine         = "aurora-postgresql"
      engine_version = "14.7"
      engine_mode    = "provisioned"
      
      master_username = "dbadmin"
      master_password = "ChangeMe123!" # Use AWS Secrets Manager in production
      database_name   = "myappdb"
      
      instance_class = "db.r6g.large"
      instances = {
        "writer" = {
          instance_class = "db.r6g.large"
          promotion_tier = 0
        }
        "reader-1" = {
          instance_class = "db.r6g.large"
          promotion_tier = 1
        }
      }
      
      db_subnet_group_name   = "my-db-subnet-group"
      vpc_security_group_ids = ["sg-0123456789abcdef0"]
      
      backup_retention_period = 7
      storage_encrypted       = true
    }
  }

  # Create DB subnet group
  db_subnet_groups = {
    "my-db-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]
    }
  }
}
```

### Aurora Serverless v2 (Auto-scaling)

```hcl
module "aurora_serverless_v2" {
  source = "../../modules/databases/relational/aws_aurora"

  region = "us-east-1"

  aurora_clusters = {
    "serverless-cluster" = {
      engine         = "aurora-postgresql"
      engine_version = "14.7"
      engine_mode    = "provisioned" # Serverless v2 uses provisioned mode
      
      master_username = "admin"
      master_password = var.db_password
      database_name   = "appdb"
      
      # Serverless v2 configuration
      instance_class = "db.serverless"
      instances = {
        "writer" = {}
        "reader" = {}
      }
      
      serverlessv2_scaling_configuration = {
        min_capacity = 0.5  # 0.5 ACUs minimum
        max_capacity = 4.0  # 4 ACUs maximum
      }
      
      db_subnet_group_name   = "serverless-subnet-group"
      vpc_security_group_ids = ["sg-serverless"]
      
      storage_encrypted = true
    }
  }

  db_subnet_groups = {
    "serverless-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222"]
    }
  }
}
```

### Aurora Serverless v1 (Classic Serverless)

```hcl
module "aurora_serverless_v1" {
  source = "../../modules/databases/relational/aws_aurora"

  region = "us-east-1"

  aurora_clusters = {
    "serverless-v1-cluster" = {
      engine         = "aurora-mysql"
      engine_version = "5.7.mysql_aurora.2.11.2"
      engine_mode    = "serverless"
      
      master_username = "admin"
      master_password = var.db_password
      database_name   = "appdb"
      
      # Serverless v1 scaling configuration
      scaling_configuration = {
        auto_pause               = true
        min_capacity             = 2    # 2 capacity units
        max_capacity             = 16   # 16 capacity units
        seconds_until_auto_pause = 300  # 5 minutes of inactivity
        timeout_action           = "RollbackCapacityChange"
      }
      
      enable_http_endpoint       = true # Enable Data API
      db_subnet_group_name       = "serverless-subnet-group"
      vpc_security_group_ids     = ["sg-serverless"]
      storage_encrypted          = true
    }
  }

  db_subnet_groups = {
    "serverless-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222"]
    }
  }
}
```

### Aurora MySQL with Backtrack

```hcl
module "aurora_mysql_backtrack" {
  source = "../../modules/databases/relational/aws_aurora"

  region = "us-east-1"

  aurora_clusters = {
    "mysql-backtrack-cluster" = {
      engine         = "aurora-mysql"
      engine_version = "8.0.mysql_aurora.3.04.0"
      engine_mode    = "provisioned"
      
      master_username = "admin"
      master_password = var.db_password
      
      instance_class = "db.r6g.large"
      instances = {
        "writer"   = { promotion_tier = 0 }
        "reader-1" = { promotion_tier = 1 }
        "reader-2" = { promotion_tier = 2 }
      }
      
      # Enable backtrack (MySQL only)
      backtrack_window = 86400 # 24 hours (in seconds)
      
      db_subnet_group_name   = "mysql-subnet-group"
      vpc_security_group_ids = ["sg-mysql"]
      
      enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
      performance_insights_enabled    = true
      storage_encrypted               = true
    }
  }

  db_subnet_groups = {
    "mysql-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]
    }
  }
}
```

### Aurora Global Database

```hcl
module "aurora_global" {
  source = "../../modules/databases/relational/aws_aurora"

  region = "us-east-1"

  # Create global cluster
  global_clusters = {
    "global-aurora-cluster" = {
      global_cluster_identifier = "global-db"
      engine                    = "aurora-postgresql"
      engine_version            = "14.7"
      database_name             = "globaldb"
      storage_encrypted         = true
      deletion_protection       = true
    }
  }

  # Primary cluster in us-east-1
  aurora_clusters = {
    "primary-cluster" = {
      engine         = "aurora-postgresql"
      engine_version = "14.7"
      engine_mode    = "global"
      
      master_username = "admin"
      master_password = var.db_password
      database_name   = "globaldb"
      
      instance_class = "db.r6g.large"
      instances = {
        "writer"   = { promotion_tier = 0 }
        "reader-1" = { promotion_tier = 1 }
      }
      
      enable_global_write_forwarding = true
      db_subnet_group_name           = "primary-subnet-group"
      vpc_security_group_ids         = ["sg-primary"]
      storage_encrypted              = true
    }
  }

  db_subnet_groups = {
    "primary-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222"]
    }
  }
}

# Secondary region cluster (deploy in different region)
# module "aurora_global_secondary" {
#   source = "../../modules/databases/relational/aws_aurora"
#   region = "eu-west-1"
#   
#   aurora_clusters = {
#     "secondary-cluster" = {
#       engine         = "aurora-postgresql"
#       replication_source_identifier = "arn:aws:rds:us-east-1:123456789012:cluster:primary-cluster"
#       ...
#     }
#   }
# }
```

### Aurora I/O-Optimized

```hcl
module "aurora_io_optimized" {
  source = "../../modules/databases/relational/aws_aurora"

  region = "us-east-1"

  aurora_clusters = {
    "io-optimized-cluster" = {
      engine         = "aurora-postgresql"
      engine_version = "14.7"
      engine_mode    = "provisioned"
      
      master_username = "admin"
      master_password = var.db_password
      
      # I/O-Optimized configuration
      storage_type = "aurora-iopt1"
      
      instance_class = "db.r6g.large"
      instances = {
        "writer" = { promotion_tier = 0 }
        "reader" = { promotion_tier = 1 }
      }
      
      db_subnet_group_name   = "io-opt-subnet-group"
      vpc_security_group_ids = ["sg-io-opt"]
      storage_encrypted      = true
    }
  }

  db_subnet_groups = {
    "io-opt-subnet-group" = {
      subnet_ids = ["subnet-111", "subnet-222"]
    }
  }
}
```

## Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | string | AWS region where Aurora clusters will be created |
| `aurora_clusters` | map(object) | Map of Aurora cluster configurations (see structure below) |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `db_subnet_groups` | map(object) | `{}` | Map of DB subnet groups to create |
| `db_cluster_parameter_groups` | map(object) | `{}` | Map of DB cluster parameter groups |
| `db_parameter_groups` | map(object) | `{}` | Map of DB instance parameter groups |
| `global_clusters` | map(object) | `{}` | Map of Aurora global database configurations |

### Aurora Cluster Object Structure

#### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `engine` | string | Database engine (aurora-mysql, aurora-postgresql) |
| `master_username` | string | Master username for the database |
| `master_password` | string | Master password (use AWS Secrets Manager in production) |

#### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `engine_version` | string | Latest | Database engine version |
| `engine_mode` | string | `"provisioned"` | Engine mode (provisioned, serverless, parallelquery, global) |
| `database_name` | string | `null` | Name of the database to create |
| `instance_class` | string | `"db.r6g.large"` | Instance class for cluster members |
| `instances` | map(object) | `{}` | Map of instance configurations |
| `serverlessv2_scaling_configuration` | object | `null` | Serverless v2 scaling (min_capacity, max_capacity) |
| `scaling_configuration` | object | `null` | Serverless v1 scaling configuration |
| `db_subnet_group_name` | string | `null` | DB subnet group name |
| `vpc_security_group_ids` | list(string) | `null` | VPC security group IDs |
| `availability_zones` | list(string) | `null` | Availability zones for the cluster |
| `storage_encrypted` | bool | `true` | Enable storage encryption |
| `kms_key_id` | string | `null` | KMS key ID for encryption |
| `storage_type` | string | `null` | Storage type (aurora, aurora-iopt1) |
| `backup_retention_period` | number | `7` | Backup retention in days (1-35) |
| `preferred_backup_window` | string | `null` | Preferred backup window |
| `preferred_maintenance_window` | string | `null` | Preferred maintenance window |
| `skip_final_snapshot` | bool | `false` | Skip final snapshot on deletion |
| `enabled_cloudwatch_logs_exports` | list(string) | `[]` | CloudWatch log types to export |
| `monitoring_interval` | number | `0` | Enhanced monitoring interval (0, 1, 5, 10, 15, 30, 60) |
| `performance_insights_enabled` | bool | `false` | Enable Performance Insights |
| `performance_insights_retention_period` | number | `7` | Performance Insights retention (7 or 731 days) |
| `enable_http_endpoint` | bool | `false` | Enable Data API (Serverless v1 only) |
| `backtrack_window` | number | `0` | Backtrack window in seconds (0-259200, MySQL only) |
| `enable_global_write_forwarding` | bool | `false` | Enable global write forwarding |
| `deletion_protection` | bool | `false` | Enable deletion protection |
| `iam_database_authentication_enabled` | bool | `false` | Enable IAM database authentication |
| `db_cluster_parameter_group_name` | string | `null` | DB cluster parameter group name |
| `db_parameter_group_name` | string | `null` | DB instance parameter group name |
| `tags` | map(string) | `{}` | Additional tags for the cluster |

## Outputs

| Output | Description |
|--------|-------------|
| `aurora_clusters` | Map of all Aurora cluster attributes |
| `cluster_endpoints` | Map of cluster writer endpoints |
| `cluster_reader_endpoints` | Map of cluster reader endpoints |
| `cluster_arns` | Map of cluster ARNs |
| `cluster_resource_ids` | Map of cluster resource IDs |
| `cluster_ports` | Map of cluster ports |
| `cluster_members` | Map of cluster members |
| `aurora_instances` | Map of all Aurora instance attributes |
| `instance_endpoints` | Map of instance endpoints |
| `writer_instances` | Map of writer instance identifiers per cluster |
| `reader_instances` | Map of reader instance identifiers per cluster |
| `connection_strings` | Map of formatted connection strings (sensitive) |
| `db_subnet_groups` | Map of created DB subnet groups |
| `db_cluster_parameter_groups` | Map of created DB cluster parameter groups |
| `db_parameter_groups` | Map of created DB instance parameter groups |
| `global_clusters` | Map of created Aurora global clusters |

## Best Practices

### Cost Optimization
1. **Use Serverless v2** for variable workloads - scales down to 0.5 ACUs
2. **Enable backtrack** instead of frequent backups for MySQL workloads
3. **Use I/O-Optimized storage** for high I/O workloads (predictable pricing)
4. **Right-size instances** based on actual workload patterns
5. **Use Reserved Instances** for long-term production workloads
6. **Delete unused read replicas** during off-peak hours

### High Availability
1. **Deploy at least 2 instances** in different AZs
2. **Set appropriate promotion tiers** for failover priority
3. **Use Global Database** for disaster recovery across regions
4. **Test failover procedures** regularly
5. **Monitor replication lag** on reader instances

### Performance
1. **Use Aurora MySQL 3.x** for better performance than 5.7
2. **Enable Performance Insights** for query analysis
3. **Use custom endpoints** for workload-specific routing
4. **Optimize queries** using slow query logs
5. **Consider parallelquery mode** for analytics workloads

### Security
1. **Enable encryption at rest** using KMS
2. **Use IAM authentication** instead of passwords
3. **Deploy in private subnets** only
4. **Enable deletion protection** for production databases
5. **Rotate credentials** using AWS Secrets Manager
6. **Use VPC security groups** to restrict access

## Aurora-Specific Features

### Backtrack (MySQL only)
Rewind your database to any point within the backtrack window without restoring from a backup. Useful for:
- Recovering from user errors
- Testing schema changes
- Analyzing data at different points in time

### Global Database
Multi-region replication with typical lag of less than 1 second:
- Disaster recovery with RPO < 1 second
- Read latency reduction for global users
- Cross-region failover in < 1 minute

### Data API (Serverless v1)
HTTP-based access to your database:
- No persistent database connections required
- Perfect for Lambda functions
- Built-in JSON support

### Aurora Serverless v2
Instantly scalable compute:
- Scales in increments of 0.5 ACU
- Scales in seconds, not minutes
- Can scale to zero (with v1 only)
- No connection drops during scaling

## Resources

- **Aurora User Guide**: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/
- **Aurora Pricing**: https://aws.amazon.com/rds/aurora/pricing/
- **Aurora MySQL vs PostgreSQL**: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMySQL.Compare.html

## License

This module is maintained as part of the aws.tf-modules project.

## Author

Created: ${local.created_date}
Managed by: Terraform
