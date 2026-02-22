// Input variables for AWS ElastiCache module

variable "region" {
  description = "AWS region to use for ElastiCache resources."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all ElastiCache resources."
  type        = map(string)
  default     = {}
}

variable "clusters" {
  description = "Map of ElastiCache clusters to create (key is a logical name). Use this for standalone Memcached or Redis clusters without replication."
  type = map(object({
    cluster_id           = string
    engine               = string # "redis", "memcached", or "valkey"
    engine_version       = optional(string)
    node_type            = string
    num_cache_nodes      = optional(number)
    parameter_group_name = optional(string)
    port                 = optional(number)

    # Networking
    subnet_group_name            = optional(string)
    security_group_ids           = optional(list(string))
    az_mode                      = optional(string) # "single-az" or "cross-az" (Memcached only)
    availability_zone            = optional(string)
    preferred_availability_zones = optional(list(string))

    # Maintenance and snapshots (not for Memcached)
    maintenance_window        = optional(string)
    snapshot_window           = optional(string)
    snapshot_retention_limit  = optional(number)
    final_snapshot_identifier = optional(string)
    snapshot_arns             = optional(list(string))
    snapshot_name             = optional(string)

    # Notifications
    notification_topic_arn = optional(string)

    # Auto-upgrade
    auto_minor_version_upgrade = optional(bool)
    apply_immediately          = optional(bool)

    # Log delivery (Redis only)
    log_delivery_configuration = optional(list(object({
      destination      = string
      destination_type = string # "cloudwatch-logs" or "kinesis-firehose"
      log_format       = string # "json" or "text"
      log_type         = string # "slow-log" or "engine-log"
    })))

    # IP discovery and network type
    ip_discovery = optional(string) # "ipv4" or "ipv6"
    network_type = optional(string) # "ipv4", "ipv6", or "dual_stack"

    # Replication group ID (if this cluster should be part of a replication group)
    replication_group_id = optional(string)

    # Per-resource tags
    tags = optional(map(string))
  }))
  default = {}
}

variable "replication_groups" {
  description = "Map of ElastiCache replication groups to create (key is a logical name). Use this for Redis with replication, cluster mode, or high availability."
  type = map(object({
    replication_group_id = string
    description          = string
    engine               = string # "redis" or "valkey"
    engine_version       = optional(string)
    node_type            = string
    port                 = optional(number)
    parameter_group_name = optional(string)

    # Replication and scaling
    num_cache_clusters         = optional(number)
    num_node_groups            = optional(number)
    replicas_per_node_group    = optional(number)
    multi_az_enabled           = optional(bool)
    automatic_failover_enabled = optional(bool)

    # Networking
    subnet_group_name           = optional(string)
    security_group_ids          = optional(list(string))
    preferred_cache_cluster_azs = optional(list(string))

    # Encryption
    at_rest_encryption_enabled = optional(bool)
    kms_key_id                 = optional(string)
    transit_encryption_enabled = optional(bool)
    transit_encryption_mode    = optional(string) # "preferred" or "required"
    auth_token                 = optional(string)
    auth_token_update_strategy = optional(string) # "SET", "ROTATE", or "DELETE"

    # Data tiering (for r6gd node types)
    data_tiering_enabled = optional(bool)

    # Maintenance and snapshots
    maintenance_window        = optional(string)
    snapshot_window           = optional(string)
    snapshot_retention_limit  = optional(number)
    final_snapshot_identifier = optional(string)
    snapshot_arns             = optional(list(string))
    snapshot_name             = optional(string)

    # Notifications
    notification_topic_arn = optional(string)

    # Auto-upgrade
    auto_minor_version_upgrade = optional(bool)
    apply_immediately          = optional(bool)

    # Log delivery (Redis only)
    log_delivery_configuration = optional(list(object({
      destination      = string
      destination_type = string # "cloudwatch-logs" or "kinesis-firehose"
      log_format       = string # "json" or "text"
      log_type         = string # "slow-log" or "engine-log"
    })))

    # User group IDs (for RBAC with Redis 6.0+)
    user_group_ids = optional(list(string))

    # IP discovery and network type
    ip_discovery = optional(string) # "ipv4" or "ipv6"
    network_type = optional(string) # "ipv4", "ipv6", or "dual_stack"

    # Global replication
    global_replication_group_id = optional(string)

    # Per-resource tags
    tags = optional(map(string))
  }))
  default = {}
}
