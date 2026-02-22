// Root module for AWS ElastiCache cluster management
// Supports creating multiple ElastiCache clusters with Redis, Memcached, or Valkey engines
// Provides encryption, replication, auto-failover, and consistent configuration patterns

# ---------------------------------------------------------------------------
# ElastiCache Clusters (Redis, Memcached, Valkey)
# ---------------------------------------------------------------------------

# Create ElastiCache clusters for caching and in-memory data storage
resource "aws_elasticache_cluster" "cluster" {
  // Create one cluster per entry in the clusters map where replication is not used
  for_each = {
    for k, v in local.clusters : k => v
    if v.replication_group_id == null
  }

  // Basic cluster settings
  cluster_id           = each.value.cluster_id
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  node_type            = each.value.node_type
  num_cache_nodes      = each.value.num_cache_nodes
  parameter_group_name = each.value.parameter_group_name
  port                 = each.value.port

  // Networking
  subnet_group_name  = each.value.subnet_group_name
  security_group_ids = each.value.security_group_ids
  az_mode            = each.value.az_mode
  availability_zone  = each.value.availability_zone

  // Preferred availability zones (for multi-AZ Memcached)
  preferred_availability_zones = each.value.preferred_availability_zones

  // Maintenance and snapshots (not applicable to Memcached)
  maintenance_window        = each.value.maintenance_window
  snapshot_window           = each.value.snapshot_window
  snapshot_retention_limit  = each.value.snapshot_retention_limit
  final_snapshot_identifier = each.value.final_snapshot_identifier
  snapshot_arns             = each.value.snapshot_arns
  snapshot_name             = each.value.snapshot_name

  // Notifications and logging
  notification_topic_arn = each.value.notification_topic_arn

  // Auto-upgrade and apply settings
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  apply_immediately          = each.value.apply_immediately

  // Log delivery configuration (Redis only, dynamic block to avoid nulls)
  dynamic "log_delivery_configuration" {
    for_each = each.value.log_delivery_configuration != null ? each.value.log_delivery_configuration : []
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  // IP discovery (for network type)
  ip_discovery = each.value.ip_discovery

  // Network type (ipv4, ipv6, or dual_stack)
  network_type = each.value.network_type

  // Tags: global + per-cluster + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

# ---------------------------------------------------------------------------
# ElastiCache Replication Groups (Redis with replication/cluster mode)
# ---------------------------------------------------------------------------

# Create ElastiCache replication groups for Redis high availability and read scaling
resource "aws_elasticache_replication_group" "replication_group" {
  // Create one replication group per entry that specifies use_replication_group = true
  for_each = {
    for k, v in local.replication_groups : k => v
  }

  // Basic replication group settings
  replication_group_id = each.value.replication_group_id
  description          = each.value.description
  engine               = each.value.engine
  engine_version       = each.value.engine_version
  node_type            = each.value.node_type
  port                 = each.value.port
  parameter_group_name = each.value.parameter_group_name

  // Replication and scaling
  num_cache_clusters         = each.value.num_cache_clusters
  num_node_groups            = each.value.num_node_groups
  replicas_per_node_group    = each.value.replicas_per_node_group
  multi_az_enabled           = each.value.multi_az_enabled
  automatic_failover_enabled = each.value.automatic_failover_enabled

  // Networking
  subnet_group_name           = each.value.subnet_group_name
  security_group_ids          = each.value.security_group_ids
  preferred_cache_cluster_azs = each.value.preferred_cache_cluster_azs

  // Encryption
  at_rest_encryption_enabled = each.value.at_rest_encryption_enabled
  kms_key_id                 = each.value.kms_key_id
  transit_encryption_enabled = each.value.transit_encryption_enabled
  transit_encryption_mode    = each.value.transit_encryption_mode
  auth_token                 = each.value.auth_token
  auth_token_update_strategy = each.value.auth_token_update_strategy

  // Data tiering (for r6gd node types)
  data_tiering_enabled = each.value.data_tiering_enabled

  // Maintenance and snapshots
  maintenance_window        = each.value.maintenance_window
  snapshot_window           = each.value.snapshot_window
  snapshot_retention_limit  = each.value.snapshot_retention_limit
  final_snapshot_identifier = each.value.final_snapshot_identifier
  snapshot_arns             = each.value.snapshot_arns
  snapshot_name             = each.value.snapshot_name

  // Notifications
  notification_topic_arn = each.value.notification_topic_arn

  // Auto-upgrade and apply settings
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  apply_immediately          = each.value.apply_immediately

  // Log delivery configuration (dynamic block to avoid nulls)
  dynamic "log_delivery_configuration" {
    for_each = each.value.log_delivery_configuration != null ? each.value.log_delivery_configuration : []
    content {
      destination      = log_delivery_configuration.value.destination
      destination_type = log_delivery_configuration.value.destination_type
      log_format       = log_delivery_configuration.value.log_format
      log_type         = log_delivery_configuration.value.log_type
    }
  }

  // User group IDs (for RBAC with Redis 6.0+)
  user_group_ids = each.value.user_group_ids

  // IP discovery and network type
  ip_discovery = each.value.ip_discovery
  network_type = each.value.network_type

  // Global replication settings (for global datastores)
  global_replication_group_id = each.value.global_replication_group_id

  // Tags: global + per-replication-group + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}
