# AWS Aurora Terraform Wrapper

Simplified wrapper for the AWS Aurora Terraform module with smart defaults and auto-configuration.

## Features

- 🚀 **Quick Start**: Deploy production-ready Aurora clusters in minutes
- 🔄 **Auto-Scaling**: Automatic instance provisioning based on cluster count
- 🧠 **Smart Defaults**: Auto-detects parameter group families and optimizes settings
- 📊 **Multi-Mode Support**: Provisioned, Serverless v1, Serverless v2, Global Database
- 🌍 **Global Ready**: Built-in support for multi-region deployments
- 🔒 **Secure by Default**: Encryption, IAM auth, private subnet deployment

## Quick Start

### 1. Configure Variables

Copy and edit `terraform.tfvars.example`:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```hcl
# Basic Configuration
cluster_identifier = "my-aurora-cluster"
engine             = "aurora-postgresql"  # or "aurora-mysql"
engine_version     = "14.7"

# Credentials (use AWS Secrets Manager in production)
master_username = "dbadmin"
master_password = "ChangeMe123!"
database_name   = "myappdb"

# Networking
vpc_id     = "vpc-0123456789abcdef0"
subnet_ids = ["subnet-111", "subnet-222", "subnet-333"]

# Scaling
cluster_count  = 1  # Number of clusters
instance_count = 2  # Number of instances per cluster (1 writer + N readers)
instance_class = "db.r6g.large"

# Security
storage_encrypted = true
kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
```

### 2. Initialize and Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 3. Connect to Your Database

```bash
# Get the cluster endpoint from outputs
terraform output cluster_endpoint

# Connect using psql (PostgreSQL)
psql -h your-cluster.cluster-xxxxx.us-east-1.rds.amazonaws.com -U dbadmin -d myappdb

# Connect using mysql (MySQL)
mysql -h your-cluster.cluster-xxxxx.us-east-1.rds.amazonaws.com -u dbadmin -p
```

## Deployment Examples

### Provisioned PostgreSQL Cluster

```hcl
cluster_identifier = "prod-postgres"
engine             = "aurora-postgresql"
engine_version     = "14.7"
engine_mode        = "provisioned"

instance_class = "db.r6g.xlarge"
instance_count = 3  # 1 writer + 2 readers

storage_encrypted = true
backup_retention_period = 14

performance_insights_enabled = true
enabled_cloudwatch_logs_exports = ["postgresql"]
```

### Serverless v2 MySQL Cluster

```hcl
cluster_identifier = "serverless-mysql"
engine             = "aurora-mysql"
engine_version     = "8.0.mysql_aurora.3.04.0"
engine_mode        = "provisioned"  # Serverless v2 uses provisioned mode

instance_class = "db.serverless"
instance_count = 2  # 1 writer + 1 reader

# Serverless v2 Scaling
serverless_v2_min_capacity = 0.5  # Minimum 0.5 ACUs
serverless_v2_max_capacity = 8.0  # Maximum 8 ACUs

storage_encrypted = true
```

### Serverless v1 Cluster (Classic)

```hcl
cluster_identifier = "serverless-v1"
engine             = "aurora-mysql"
engine_version     = "5.7.mysql_aurora.2.11.2"
engine_mode        = "serverless"

# Serverless v1 Scaling
auto_pause               = true
min_capacity             = 2
max_capacity             = 16
seconds_until_auto_pause = 300

enable_http_endpoint = true  # Enable Data API
storage_encrypted    = true
```

### MySQL with Backtrack

```hcl
cluster_identifier = "mysql-backtrack"
engine             = "aurora-mysql"
engine_version     = "8.0.mysql_aurora.3.04.0"

instance_class = "db.r6g.large"
instance_count = 3

# Enable backtrack (24 hours)
backtrack_window = 86400

enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
performance_insights_enabled = true
storage_encrypted = true
```

### I/O-Optimized Storage

```hcl
cluster_identifier = "io-optimized-cluster"
engine             = "aurora-postgresql"
engine_version     = "14.7"

instance_class = "db.r6g.xlarge"
instance_count = 2

# I/O-Optimized Storage Configuration
storage_type = "aurora-iopt1"

storage_encrypted = true
```

## Auto-Configuration Features

The wrapper automatically configures:

1. **Parameter Group Families**
   - Detects the correct family based on engine and version
   - Creates optimized parameter groups if needed

2. **Security Groups**
   - Creates security group with appropriate ingress rules
   - Configures port based on engine (3306 for MySQL, 5432 for PostgreSQL)

3. **DB Subnet Groups**
   - Automatically creates subnet group from provided subnet IDs
   - Ensures Multi-AZ deployment

4. **Instance Configuration**
   - Configures writer instance with promotion tier 0
   - Configures reader instances with increasing promotion tiers
   - Supports both provisioned and serverless instances

5. **Scaling Configuration**
   - Automatically applies Serverless v2 scaling when instance_class = "db.serverless"
   - Automatically applies Serverless v1 scaling when engine_mode = "serverless"

## Variables

### Essential Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cluster_identifier` | string | - | **Required**. Unique identifier for the Aurora cluster |
| `engine` | string | - | **Required**. Database engine (aurora-mysql or aurora-postgresql) |
| `engine_version` | string | - | **Required**. Engine version |
| `master_username` | string | - | **Required**. Master username |
| `master_password` | string | - | **Required**. Master password (use Secrets Manager) |
| `vpc_id` | string | - | **Required**. VPC ID for security group |
| `subnet_ids` | list(string) | - | **Required**. List of subnet IDs for DB subnet group |

### Scaling Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cluster_count` | number | `1` | Number of Aurora clusters to create |
| `instance_count` | number | `1` | Number of instances per cluster (1 writer + N-1 readers) |
| `instance_class` | string | `"db.r6g.large"` | Instance class (use "db.serverless" for Serverless v2) |

### Serverless v2 Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `serverless_v2_min_capacity` | number | `0.5` | Minimum ACUs for Serverless v2 |
| `serverless_v2_max_capacity` | number | `1.0` | Maximum ACUs for Serverless v2 |

### Serverless v1 Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `engine_mode` | string | `"provisioned"` | Engine mode (serverless for v1) |
| `auto_pause` | bool | `false` | Auto-pause after inactivity |
| `min_capacity` | number | `2` | Minimum capacity units (2-256) |
| `max_capacity` | number | `4` | Maximum capacity units (2-256) |
| `seconds_until_auto_pause` | number | `300` | Seconds of inactivity before auto-pause |

### Storage Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `storage_type` | string | `null` | Storage type (aurora or aurora-iopt1 for I/O-Optimized) |
| `storage_encrypted` | bool | `true` | Enable storage encryption |
| `kms_key_id` | string | `null` | KMS key ID for encryption |

### Backup Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `backup_retention_period` | number | `7` | Backup retention in days (1-35) |
| `preferred_backup_window` | string | `"03:00-04:00"` | Preferred backup window (UTC) |
| `skip_final_snapshot` | bool | `false` | Skip final snapshot on deletion |

### Monitoring Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `performance_insights_enabled` | bool | `false` | Enable Performance Insights |
| `enabled_cloudwatch_logs_exports` | list(string) | `[]` | CloudWatch log types to export |
| `monitoring_interval` | number | `0` | Enhanced monitoring interval (seconds) |

### Aurora-Specific Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `backtrack_window` | number | `0` | Backtrack window in seconds (MySQL only, 0-259200) |
| `enable_http_endpoint` | bool | `false` | Enable Data API (Serverless v1 only) |
| `iam_database_authentication_enabled` | bool | `false` | Enable IAM database authentication |
| `deletion_protection` | bool | `false` | Enable deletion protection |

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | Writer endpoint for the cluster |
| `cluster_reader_endpoint` | Reader endpoint for the cluster |
| `cluster_arn` | ARN of the Aurora cluster |
| `cluster_id` | Identifier of the Aurora cluster |
| `cluster_port` | Port number for the cluster |
| `security_group_id` | ID of the created security group |
| `db_subnet_group_name` | Name of the created DB subnet group |
| `instance_endpoints` | Map of all instance endpoints |
| `writer_instance_id` | ID of the writer instance |
| `reader_instance_ids` | List of reader instance IDs |
| `deployment_summary` | Summary of the deployment configuration |

## Cost Considerations

### Provisioned Instances
- **Instance Cost**: Hourly charge based on instance class (e.g., db.r6g.large ~$0.25/hour)
- **Storage Cost**: $0.10 per GB-month (auto-scaling, up to 128 TB)
- **I/O Cost**: $0.20 per 1 million requests
- **Backup Cost**: $0.021 per GB-month (beyond retention period)

### Serverless v2
- **ACU Cost**: $0.12 per ACU-hour (min 0.5 ACU)
- **Storage Cost**: Same as provisioned
- **I/O Cost**: Same as provisioned
- **Example**: 2 ACUs 24/7 = ~$173/month

### Serverless v1
- **ACU Cost**: $0.06 per ACU-hour
- **Storage Cost**: Same as provisioned
- **I/O Cost**: Included
- **Auto-pause**: No charges when paused

### I/O-Optimized
- **Instance Cost**: ~40% higher than provisioned
- **I/O Cost**: Included (unlimited)
- **Break-even**: ~85 million I/O requests per month

## Best Practices

1. **Use Serverless v2** for development/staging environments
2. **Enable Performance Insights** for production workloads
3. **Configure backups** with appropriate retention period
4. **Use IAM authentication** for enhanced security
5. **Deploy at least 2 instances** across multiple AZs
6. **Monitor costs** using AWS Cost Explorer
7. **Test failover** procedures regularly
8. **Use I/O-Optimized** for high-throughput workloads

## Troubleshooting

### Issue: "Cluster is not in a state to create instances"
**Solution**: Wait for cluster to reach "available" state before creating instances. Run `terraform apply` again.

### Issue: "Invalid parameter group family"
**Solution**: Ensure engine_version matches the parameter group family. Check locals.tf for supported families.

### Issue: "Serverless v2 instances not scaling"
**Solution**: Verify serverless_v2_min_capacity and serverless_v2_max_capacity are set correctly.

### Issue: "Cannot connect to cluster"
**Solution**: 
1. Check security group ingress rules
2. Verify cluster is in "available" state
3. Ensure you're connecting from the correct VPC/subnet
4. Check credentials and database name

## Migration from RDS

To migrate from RDS to Aurora:

1. Create Aurora Read Replica from RDS instance
2. Promote Aurora Read Replica to standalone cluster
3. Update application connection strings
4. Decommission old RDS instance

Alternatively, use AWS Database Migration Service (DMS) for zero-downtime migration.

## Support

For issues or questions:
- Check [AWS Aurora Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/)
- Review [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)

## License

This wrapper is maintained as part of the aws.tf-modules project.
