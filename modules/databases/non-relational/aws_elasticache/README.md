# AWS ElastiCache Terraform Module

This module creates and manages AWS ElastiCache clusters and replication groups. It supports **Redis**, **Memcached**, and **Valkey** engines with flexible configuration for standalone clusters, high-availability replication groups, and cluster mode.

## Features

- **Multi-engine Support**: Redis, Memcached, and Valkey
- **Flexible Deployment**: Standalone clusters or replication groups with automatic failover
- **Cluster Mode**: Support for Redis cluster mode (sharded)
- **Encryption**: At-rest and in-transit encryption with optional KMS keys
- **High Availability**: Multi-AZ deployments with automatic failover
- **Scaling**: Configurable number of cache nodes, shards, and replicas
- **Snapshots**: Automated backup and restore for Redis
- **Logging**: CloudWatch Logs and Kinesis Firehose integration for Redis
- **Authentication**: Redis AUTH tokens and RBAC with user groups
- **Consistent Tagging**: Automatically adds `CreatedDate` tag to all resources

## Usage

### Basic Memcached Cluster

```hcl
module "elasticache" {
  source = "../../modules/databases/non-relational/aws_elasticache"

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
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

### Redis with Replication and Automatic Failover

```hcl
module "elasticache" {
  source = "../../modules/databases/non-relational/aws_elasticache"

  region = "us-east-1"

  replication_groups = {
    redis-ha = {
      replication_group_id = "redis-ha-dev"
      description          = "Redis HA cluster"
      engine               = "redis"
      engine_version       = "7.1"
      node_type            = "cache.t3.micro"

      num_cache_clusters         = 2
      multi_az_enabled           = true
      automatic_failover_enabled = true

      subnet_group_name  = "my-subnet-group"
      security_group_ids = ["sg-0123456789"]

      at_rest_encryption_enabled = true
      transit_encryption_enabled = true
      auth_token                 = "SecureToken123456"

      snapshot_retention_limit = 7
    }
  }

  tags = {
    Environment = "production"
  }
}
```

### Redis Cluster Mode (Sharded)

```hcl
module "elasticache" {
  source = "../../modules/databases/non-relational/aws_elasticache"

  region = "us-east-1"

  replication_groups = {
    redis-cluster = {
      replication_group_id = "redis-cluster-dev"
      description          = "Redis cluster mode"
      engine               = "redis"
      engine_version       = "7.1"
      node_type            = "cache.r6g.large"

      num_node_groups         = 3
      replicas_per_node_group = 2
      multi_az_enabled        = true
      automatic_failover_enabled = true

      subnet_group_name  = "my-subnet-group"
      security_group_ids = ["sg-0123456789"]

      at_rest_encryption_enabled = true
      transit_encryption_enabled = true
    }
  }
}
```

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region to deploy ElastiCache resources |

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Global tags applied to all resources |
| `clusters` | `map(object)` | `{}` | Map of standalone ElastiCache clusters to create (see Cluster Variables below) |
| `replication_groups` | `map(object)` | `{}` | Map of ElastiCache replication groups to create (see Replication Group Variables below) |

## Cluster Variables (for `clusters` map)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `cluster_id` | `string` | Yes | - | Unique identifier for the cluster |
| `engine` | `string` | Yes | - | Cache engine: `redis`, `memcached`, or `valkey` |
| `node_type` | `string` | Yes | - | Instance type (e.g., `cache.t3.micro`) |
| `engine_version` | `string` | No | Latest | Engine version |
| `num_cache_nodes` | `number` | No | `1` | Number of cache nodes |
| `parameter_group_name` | `string` | No | Default | Parameter group name |
| `port` | `number` | No | `6379` (Redis/Valkey) or `11211` (Memcached) | Port number |
| `subnet_group_name` | `string` | No | `null` | Subnet group name for VPC |
| `security_group_ids` | `list(string)` | No | `[]` | Security group IDs |
| `az_mode` | `string` | No | `single-az` | Availability zone mode: `single-az` or `cross-az` (Memcached only) |
| `availability_zone` | `string` | No | `null` | Specific availability zone |
| `preferred_availability_zones` | `list(string)` | No | `[]` | Preferred AZs for multi-AZ Memcached |
| `maintenance_window` | `string` | No | `null` | Weekly maintenance window (e.g., `sun:05:00-sun:07:00`) |
| `snapshot_window` | `string` | No | `null` | Daily snapshot window (Redis only) |
| `snapshot_retention_limit` | `number` | No | `0` | Number of days to retain snapshots (Redis only) |
| `final_snapshot_identifier` | `string` | No | `null` | Final snapshot name before deletion |
| `snapshot_arns` | `list(string)` | No | `[]` | ARNs of snapshots to restore from |
| `snapshot_name` | `string` | No | `null` | Name of snapshot to restore from |
| `notification_topic_arn` | `string` | No | `null` | SNS topic ARN for notifications |
| `auto_minor_version_upgrade` | `bool` | No | `true` | Enable automatic minor version upgrades |
| `apply_immediately` | `bool` | No | `false` | Apply changes immediately |
| `log_delivery_configuration` | `list(object)` | No | `null` | Log delivery settings (Redis only, see below) |
| `ip_discovery` | `string` | No | `ipv4` | IP discovery mode: `ipv4` or `ipv6` |
| `network_type` | `string` | No | `ipv4` | Network type: `ipv4`, `ipv6`, or `dual_stack` |
| `replication_group_id` | `string` | No | `null` | Replication group ID if part of a group |
| `tags` | `map(string)` | No | `{}` | Additional tags for this cluster |

## Replication Group Variables (for `replication_groups` map)

| Variable | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `replication_group_id` | `string` | Yes | - | Unique identifier for the replication group |
| `description` | `string` | Yes | - | Description of the replication group |
| `engine` | `string` | Yes | - | Cache engine: `redis` or `valkey` |
| `node_type` | `string` | Yes | - | Instance type (e.g., `cache.t3.micro`) |
| `engine_version` | `string` | No | Latest | Engine version |
| `port` | `number` | No | `6379` | Port number |
| `parameter_group_name` | `string` | No | Default | Parameter group name |
| `num_cache_clusters` | `number` | No | `null` | Number of cache clusters (cluster mode disabled) |
| `num_node_groups` | `number` | No | `null` | Number of node groups/shards (cluster mode enabled) |
| `replicas_per_node_group` | `number` | No | `1` | Number of replica nodes per shard |
| `multi_az_enabled` | `bool` | No | `false` | Enable Multi-AZ with automatic failover |
| `automatic_failover_enabled` | `bool` | No | `false` | Enable automatic failover |
| `subnet_group_name` | `string` | No | `null` | Subnet group name for VPC |
| `security_group_ids` | `list(string)` | No | `[]` | Security group IDs |
| `preferred_cache_cluster_azs` | `list(string)` | No | `[]` | Preferred AZs for cache clusters |
| `at_rest_encryption_enabled` | `bool` | No | `false` | Enable encryption at rest |
| `kms_key_id` | `string` | No | `null` | KMS key ID for encryption |
| `transit_encryption_enabled` | `bool` | No | `false` | Enable encryption in transit |
| `transit_encryption_mode` | `string` | No | `null` | Transit encryption mode: `preferred` or `required` |
| `auth_token` | `string` | No | `null` | AUTH token for Redis (min 16 chars) |
| `auth_token_update_strategy` | `string` | No | `null` | Update strategy: `SET`, `ROTATE`, or `DELETE` |
| `data_tiering_enabled` | `bool` | No | `false` | Enable data tiering (r6gd node types) |
| `maintenance_window` | `string` | No | `null` | Weekly maintenance window |
| `snapshot_window` | `string` | No | `null` | Daily snapshot window |
| `snapshot_retention_limit` | `number` | No | `0` | Number of days to retain snapshots |
| `final_snapshot_identifier` | `string` | No | `null` | Final snapshot name before deletion |
| `snapshot_arns` | `list(string)` | No | `[]` | ARNs of snapshots to restore from |
| `snapshot_name` | `string` | No | `null` | Name of snapshot to restore from |
| `notification_topic_arn` | `string` | No | `null` | SNS topic ARN for notifications |
| `auto_minor_version_upgrade` | `bool` | No | `true` | Enable automatic minor version upgrades |
| `apply_immediately` | `bool` | No | `false` | Apply changes immediately |
| `log_delivery_configuration` | `list(object)` | No | `null` | Log delivery settings (see below) |
| `user_group_ids` | `list(string)` | No | `[]` | User group IDs for RBAC (Redis 6.0+) |
| `ip_discovery` | `string` | No | `ipv4` | IP discovery mode |
| `network_type` | `string` | No | `ipv4` | Network type |
| `global_replication_group_id` | `string` | No | `null` | Global datastore ID |
| `tags` | `map(string)` | No | `{}` | Additional tags for this replication group |

### Log Delivery Configuration

For Redis clusters and replication groups, you can configure log delivery:

```hcl
log_delivery_configuration = [
  {
    destination      = "my-cloudwatch-log-group"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  },
  {
    destination      = "my-kinesis-firehose"
    destination_type = "kinesis-firehose"
    log_format       = "json"
    log_type         = "engine-log"
  }
]
```

## Outputs

### Cluster Outputs

| Output | Type | Description |
|--------|------|-------------|
| `cluster_ids` | `map(string)` | Map of logical cluster names to their cluster IDs |
| `cluster_addresses` | `map(string)` | Map of logical cluster names to their cache cluster addresses |
| `cluster_configuration_endpoints` | `map(string)` | Map of logical cluster names to configuration endpoints (Memcached only) |
| `cluster_arns` | `map(string)` | Map of logical cluster names to their ARNs |

### Replication Group Outputs

| Output | Type | Description |
|--------|------|-------------|
| `replication_group_ids` | `map(string)` | Map of logical replication group names to their IDs |
| `replication_group_arns` | `map(string)` | Map of logical replication group names to their ARNs |
| `replication_group_primary_endpoints` | `map(string)` | Map of logical replication group names to primary endpoint addresses |
| `replication_group_reader_endpoints` | `map(string)` | Map of logical replication group names to reader endpoint addresses |
| `replication_group_configuration_endpoints` | `map(string)` | Map of logical replication group names to configuration endpoints (cluster mode) |
| `replication_group_member_clusters` | `map(list(string))` | Map of logical replication group names to member cluster IDs |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.0 |

## Notes

- **Memcached** does not support replication, snapshots, or encryption. Use standalone clusters only.
- **Redis/Valkey** support both standalone clusters and replication groups.
- For high availability, use replication groups with `automatic_failover_enabled = true` and `multi_az_enabled = true`.
- Cluster mode is enabled when `num_node_groups` is specified (sharded configuration).
- AUTH tokens for Redis must be at least 16 characters and can only be set if `transit_encryption_enabled = true`.
- The `CreatedDate` tag is automatically added to all resources using the current date.

## Example

See the [wrapper README](../../../tf-plans/aws_elasticache/README.md) for complete usage examples with `terraform.tfvars`.
