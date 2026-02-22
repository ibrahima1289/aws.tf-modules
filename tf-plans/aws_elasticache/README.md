# AWS ElastiCache Wrapper

This wrapper provides a simplified interface to the AWS ElastiCache root module. It demonstrates how to create and manage ElastiCache clusters (Memcached, Redis, Valkey) and replication groups with various configurations.

## Quick Start

1. Configure your variables in `terraform.tfvars` (see examples below)
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Review the plan:
   ```bash
   terraform plan
   ```
4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Usage Examples

The `terraform.tfvars` file includes examples for:
- **Memcached cluster**: Multi-node caching with cross-AZ deployment
- **Standalone Redis**: Single-node Redis cluster with snapshots
- **Redis HA**: High-availability replication group with automatic failover
- **Redis Cluster Mode**: Sharded Redis with multiple node groups
- **Valkey**: Redis-compatible engine with replication

## Configuration

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region to deploy resources |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `clusters` | `map(object)` | `{}` | Map of standalone ElastiCache clusters (Memcached, Redis, or Valkey without replication) |
| `replication_groups` | `map(object)` | `{}` | Map of ElastiCache replication groups (Redis/Valkey with replication and HA) |

See the [root module README](../../modules/databases/non-relational/aws_elasticache/README.md) for detailed variable documentation.

## Example: Memcached Cluster

```hcl
region = "us-east-1"

clusters = {
  memcached-cache = {
    cluster_id      = "memcached-dev"
    engine          = "memcached"
    engine_version  = "1.6.17"
    node_type       = "cache.t3.micro"
    num_cache_nodes = 2
    az_mode         = "cross-az"

    subnet_group_name  = "my-subnet-group"
    security_group_ids = ["sg-0123456789"]

    tags = {
      Name = "memcached-cache-dev"
    }
  }
}
```

## Example: Redis with High Availability

```hcl
region = "us-east-1"

replication_groups = {
  redis-ha = {
    replication_group_id = "redis-ha-prod"
    description          = "Production Redis HA cluster"
    engine               = "redis"
    engine_version       = "7.1"
    node_type            = "cache.r6g.large"

    # Replication: 1 primary + 2 replicas
    num_cache_clusters         = 3
    multi_az_enabled           = true
    automatic_failover_enabled = true

    # Networking
    subnet_group_name  = "my-subnet-group"
    security_group_ids = ["sg-0123456789"]

    # Encryption
    at_rest_encryption_enabled = true
    transit_encryption_enabled = true
    transit_encryption_mode    = "required"
    auth_token                 = "SecureToken123456789"

    # Backups
    snapshot_retention_limit = 7
    snapshot_window          = "03:00-05:00"
    maintenance_window       = "sun:05:00-sun:07:00"

    # Logging
    log_delivery_configuration = [
      {
        destination      = "redis-slow-log-group"
        destination_type = "cloudwatch-logs"
        log_format       = "json"
        log_type         = "slow-log"
      }
    ]

    tags = {
      Environment = "production"
      HA          = "true"
    }
  }
}
```

## Example: Redis Cluster Mode (Sharded)

```hcl
region = "us-east-1"

replication_groups = {
  redis-cluster = {
    replication_group_id = "redis-cluster-prod"
    description          = "Sharded Redis cluster"
    engine               = "redis"
    engine_version       = "7.1"
    node_type            = "cache.r6g.large"

    # Cluster mode: 3 shards, 2 replicas per shard
    num_node_groups         = 3
    replicas_per_node_group = 2
    multi_az_enabled        = true
    automatic_failover_enabled = true

    # Networking
    subnet_group_name  = "my-subnet-group"
    security_group_ids = ["sg-0123456789"]

    # Encryption
    at_rest_encryption_enabled = true
    transit_encryption_enabled = true

    snapshot_retention_limit = 5

    tags = {
      Environment = "production"
      ClusterMode = "enabled"
    }
  }
}
```

## Example: Valkey Replication Group

```hcl
region = "us-east-1"

replication_groups = {
  valkey-ha = {
    replication_group_id = "valkey-ha-dev"
    description          = "Valkey HA cluster"
    engine               = "valkey"
    engine_version       = "7.2"
    node_type            = "cache.t3.micro"

    num_cache_clusters         = 2
    multi_az_enabled           = true
    automatic_failover_enabled = true

    subnet_group_name  = "my-subnet-group"
    security_group_ids = ["sg-0123456789"]

    tags = {
      Engine = "valkey"
    }
  }
}
```

## Outputs

After applying the configuration, you can access the following outputs:

```bash
# Get cluster addresses
terraform output cluster_addresses

# Get replication group primary endpoints
terraform output replication_group_primary_endpoints

# Get replication group reader endpoints
terraform output replication_group_reader_endpoints
```

## Common Patterns

### Pattern 1: Simple Caching (Memcached)
- Use `clusters` variable
- Set `engine = "memcached"`
- Configure `num_cache_nodes` for horizontal scaling
- Use `az_mode = "cross-az"` for high availability

### Pattern 2: Session Store (Redis)
- Use `replication_groups` variable
- Enable `multi_az_enabled` and `automatic_failover_enabled`
- Configure `snapshot_retention_limit` for backup
- Enable `transit_encryption_enabled` for security

### Pattern 3: High-Performance Cache (Redis Cluster Mode)
- Use `replication_groups` variable
- Set `num_node_groups` for sharding
- Set `replicas_per_node_group` for read scaling
- Enable encryption and authentication

### Pattern 4: Redis-Compatible (Valkey)
- Use `replication_groups` variable
- Set `engine = "valkey"`
- Same features as Redis (replication, encryption, etc.)

## Prerequisites

Before using this wrapper, ensure you have:

1. **VPC Subnet Group**: Create an ElastiCache subnet group
   ```bash
   aws elasticache create-cache-subnet-group \
     --cache-subnet-group-name my-subnet-group \
     --cache-subnet-group-description "My subnet group" \
     --subnet-ids subnet-12345 subnet-67890
   ```

2. **Security Groups**: Configure security groups with appropriate inbound rules
   - Memcached: Port 11211
   - Redis/Valkey: Port 6379 (or custom port)

3. **Parameter Groups** (optional): Create custom parameter groups for specific configurations
   ```bash
   aws elasticache create-cache-parameter-group \
     --cache-parameter-group-name my-redis-params \
     --cache-parameter-group-family redis7 \
     --description "My Redis parameters"
   ```

## Important Notes

- **Memcached**: Does not support replication, snapshots, or encryption. Use `clusters` variable only.
- **Redis/Valkey**: Support both `clusters` and `replication_groups`. Use replication groups for HA.
- **Cluster Mode**: Enabled when `num_node_groups` is specified. Required for sharding.
- **AUTH Tokens**: Redis AUTH tokens require `transit_encryption_enabled = true` and must be at least 16 characters.
- **Automatic Failover**: Requires `multi_az_enabled = true` and at least 2 cache clusters.
- **Cost**: Be mindful of costs when using larger instance types or multiple nodes.

## Troubleshooting

### Issue: "InvalidParameterCombination" Error

**Solution**: Ensure parameter combinations are valid:
- `automatic_failover_enabled = true` requires `multi_az_enabled = true`
- `num_cache_clusters` and `num_node_groups` are mutually exclusive
- AUTH tokens require transit encryption

### Issue: Connection Timeout

**Solution**: Check security group rules and subnet group configuration:
- Ensure security groups allow inbound traffic on the correct port
- Verify subnet group includes subnets in the correct VPC
- Check network ACLs

### Issue: Snapshot Restore Fails

**Solution**: Verify snapshot compatibility:
- Engine version must be compatible with snapshot version
- Node type must support the snapshot size
- Encryption settings must match

## Additional Resources

- [AWS ElastiCache Documentation](https://docs.aws.amazon.com/elasticache/)
- [Root Module README](../../modules/databases/non-relational/aws_elasticache/README.md)
- [Redis Best Practices](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/BestPractices.html)
- [Memcached Best Practices](https://docs.aws.amazon.com/AmazonElastiCache/latest/mem-ug/BestPractices.html)
