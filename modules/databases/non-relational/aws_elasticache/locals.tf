// Locals for AWS ElastiCache module (created date, normalized cluster and replication group settings)

locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Normalize cluster settings with sensible defaults
  clusters = {
    for key, c in var.clusters : key => merge(
      {
        // Default settings to avoid nulls in the resource
        engine_version       = null
        num_cache_nodes      = 1
        parameter_group_name = null
        port                 = c.engine == "memcached" ? 11211 : (c.engine == "redis" || c.engine == "valkey" ? 6379 : null)

        subnet_group_name            = null
        security_group_ids           = []
        az_mode                      = "single-az"
        availability_zone            = null
        preferred_availability_zones = []

        maintenance_window        = null
        snapshot_window           = null
        snapshot_retention_limit  = 0
        final_snapshot_identifier = null
        snapshot_arns             = []
        snapshot_name             = null

        notification_topic_arn = null

        auto_minor_version_upgrade = true
        apply_immediately          = false

        log_delivery_configuration = null

        ip_discovery = "ipv4"
        network_type = "ipv4"

        replication_group_id = null

        tags = {}
      },
      c
    )
  }

  # Normalize replication group settings with sensible defaults
  replication_groups = {
    for key, rg in var.replication_groups : key => merge(
      {
        // Default settings to avoid nulls in the resource
        engine_version       = null
        port                 = rg.engine == "redis" || rg.engine == "valkey" ? 6379 : null
        parameter_group_name = null

        num_cache_clusters         = null
        num_node_groups            = null
        replicas_per_node_group    = 1
        multi_az_enabled           = false
        automatic_failover_enabled = false

        subnet_group_name           = null
        security_group_ids          = []
        preferred_cache_cluster_azs = []

        at_rest_encryption_enabled = false
        kms_key_id                 = null
        transit_encryption_enabled = false
        transit_encryption_mode    = null
        auth_token                 = null
        auth_token_update_strategy = null

        data_tiering_enabled = false

        maintenance_window        = null
        snapshot_window           = null
        snapshot_retention_limit  = 0
        final_snapshot_identifier = null
        snapshot_arns             = []
        snapshot_name             = null

        notification_topic_arn = null

        auto_minor_version_upgrade = true
        apply_immediately          = false

        log_delivery_configuration = null

        user_group_ids = []

        ip_discovery = "ipv4"
        network_type = "ipv4"

        global_replication_group_id = null

        tags = {}
      },
      rg
    )
  }
}
