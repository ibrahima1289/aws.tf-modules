// Example terraform.tfvars for AWS ElastiCache wrapper
// Demonstrates creating multiple ElastiCache clusters and replication groups

region = "us-east-1"

tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
  Project     = "ElastiCache-Demo"
}

# ---------------------------------------------------------------------------
# Standalone Clusters (Memcached, Redis, or Valkey without replication)
# ---------------------------------------------------------------------------

clusters = {
  # Example 1: Memcached cluster (simple caching)
  memcached-cache = {
    cluster_id      = "memcached-cache-dev"
    engine          = "memcached"
    engine_version  = "1.6.17"
    node_type       = "cache.t3.micro"
    num_cache_nodes = 2
    az_mode         = "cross-az"

    # Networking (replace with your VPC subnet group and security groups)
    subnet_group_name  = "my-elasticache-subnet-group"
    security_group_ids = ["sg-0123456789abcdef0"]

    # Auto-upgrade
    auto_minor_version_upgrade = true
    apply_immediately          = false

    tags = {
      Name = "memcached-cache-dev"
    }
  }

  # Example 2: Standalone Redis cluster (single node, no replication)
  redis-single = {
    cluster_id           = "redis-single-dev"
    engine               = "redis"
    engine_version       = "7.1"
    node_type            = "cache.t3.micro"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis7"

    # Networking
    subnet_group_name  = "my-elasticache-subnet-group"
    security_group_ids = ["sg-0123456789abcdef0"]

    # Snapshots (Redis only, not available for Memcached)
    snapshot_retention_limit = 5 # Retain up to 5 daily snapshots
    snapshot_window          = "03:00-05:00"
    maintenance_window       = "sun:05:00-sun:07:00"

    # Log delivery (Redis only)
    log_delivery_configuration = [
      {
        destination      = "my-cloudwatch-log-group"
        destination_type = "cloudwatch-logs"
        log_format       = "json"
        log_type         = "slow-log"
      }
    ]

    tags = {
      Name = "redis-single-dev"
    }
  }

  # Example 3: Valkey cluster (Redis-compatible)
  valkey-cache = {
    cluster_id      = "valkey-cache-dev"
    engine          = "valkey"
    engine_version  = "7.2"
    node_type       = "cache.t3.micro"
    num_cache_nodes = 1

    # Networking
    subnet_group_name  = "my-elasticache-subnet-group"
    security_group_ids = ["sg-0123456789abcdef0"]

    tags = {
      Name = "valkey-cache-dev"
    }
  }
}

# ---------------------------------------------------------------------------
# Replication Groups (Redis/Valkey with replication and high availability)
# ---------------------------------------------------------------------------

replication_groups = {
  # Example 1: Redis cluster with automatic failover (2 nodes: 1 primary + 1 replica)
  redis-ha = {
    replication_group_id = "redis-ha-dev"
    description          = "Redis HA cluster with automatic failover"
    engine               = "redis"
    engine_version       = "7.1"
    node_type            = "cache.t3.micro"

    # Replication settings (cluster mode disabled, 1 primary + 1 replica)
    num_cache_clusters         = 2
    multi_az_enabled           = true
    automatic_failover_enabled = true

    # Networking
    subnet_group_name  = "my-elasticache-subnet-group"
    security_group_ids = ["sg-0123456789abcdef0"]

    # Encryption (at rest and in transit)
    at_rest_encryption_enabled = true
    transit_encryption_enabled = true
    transit_encryption_mode    = "required"
    auth_token                 = "MySecureAuthToken123456" # Must be at least 16 characters

    # Snapshots and maintenance
    snapshot_retention_limit = 7
    snapshot_window          = "03:00-05:00"
    maintenance_window       = "sun:05:00-sun:07:00"

    # Auto-upgrade
    auto_minor_version_upgrade = true
    apply_immediately          = false

    tags = {
      Name = "redis-ha-dev"
      HA   = "true"
    }
  }

  # Example 2: Redis cluster mode enabled (sharded, 2 shards with 1 replica each)
  redis-cluster = {
    replication_group_id = "redis-cluster-dev"
    description          = "Redis cluster mode enabled with 2 shards"
    engine               = "redis"
    engine_version       = "7.1"
    node_type            = "cache.t3.micro"

    # Cluster mode settings (2 shards, 1 replica per shard)
    num_node_groups            = 2
    replicas_per_node_group    = 1
    multi_az_enabled           = true
    automatic_failover_enabled = true

    # Networking
    subnet_group_name  = "my-elasticache-subnet-group"
    security_group_ids = ["sg-0123456789abcdef0"]

    # Encryption
    at_rest_encryption_enabled = true
    transit_encryption_enabled = true

    # Snapshots
    snapshot_retention_limit = 5

    tags = {
      Name        = "redis-cluster-dev"
      ClusterMode = "enabled"
    }
  }

  # Example 3: Valkey replication group
  valkey-ha = {
    replication_group_id = "valkey-ha-dev"
    description          = "Valkey HA cluster with automatic failover"
    engine               = "valkey"
    engine_version       = "7.2"
    node_type            = "cache.t3.micro"

    # Replication settings
    num_cache_clusters         = 2
    multi_az_enabled           = true
    automatic_failover_enabled = true

    # Networking
    subnet_group_name  = "my-elasticache-subnet-group"
    security_group_ids = ["sg-0123456789abcdef0"]

    tags = {
      Name   = "valkey-ha-dev"
      Engine = "valkey"
    }
  }
}
