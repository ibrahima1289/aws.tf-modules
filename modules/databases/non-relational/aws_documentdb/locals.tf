// Locals for AWS DocumentDB module
// Computes: created date tag, common tags, normalised cluster settings, and flattened instance map

locals {
  # ISO-8601 date stamp used as the CreatedDate tag on every resource
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Common tags applied alongside per-resource and per-cluster tags
  common_tags = {
    ManagedBy   = "Terraform"
    Module      = "aws_documentdb"
    CreatedDate = local.created_date
  }

  # Normalise each cluster entry with sensible defaults to keep main.tf free of nulls.
  # Per-cluster values always override the defaults; derived values (e.g. parameter_group_family)
  # are computed after the user value is resolved.
  clusters = {
    for key, c in var.clusters : key => {
      cluster_identifier = c.cluster_identifier

      # Engine defaults to the latest GA version
      engine_version = coalesce(c.engine_version, "5.0")

      master_username = c.master_username
      master_password = c.master_password

      instance_class = c.instance_class
      # A single-node deployment is the minimum; increase for HA (recommended: 3)
      instance_count = coalesce(c.instance_count, 1)

      subnet_ids             = c.subnet_ids
      vpc_security_group_ids = c.vpc_security_group_ids
      port                   = coalesce(c.port, 27017)

      subnet_group_name        = c.subnet_group_name
      subnet_group_description = c.subnet_group_description

      storage_encrypted = coalesce(c.storage_encrypted, true)
      kms_key_id        = c.kms_key_id
      storage_type      = coalesce(c.storage_type, "standard")

      backup_retention_period      = coalesce(c.backup_retention_period, 7)
      preferred_backup_window      = coalesce(c.preferred_backup_window, "03:00-04:00")
      preferred_maintenance_window = coalesce(c.preferred_maintenance_window, "sun:05:00-sun:06:00")
      skip_final_snapshot          = coalesce(c.skip_final_snapshot, true)
      final_snapshot_identifier    = c.final_snapshot_identifier
      snapshot_identifier          = c.snapshot_identifier

      parameter_group_name = c.parameter_group_name
      # Derive the parameter group family from the engine version when not explicitly set
      # docdb4.0 → "docdb4.0", docdb5.0 → "docdb5.0"
      parameter_group_family = coalesce(c.parameter_group_family, "docdb${coalesce(c.engine_version, "5.0")}")
      parameters             = coalesce(c.parameters, [])

      deletion_protection             = coalesce(c.deletion_protection, false)
      apply_immediately               = coalesce(c.apply_immediately, false)
      auto_minor_version_upgrade      = coalesce(c.auto_minor_version_upgrade, true)
      enabled_cloudwatch_logs_exports = coalesce(c.enabled_cloudwatch_logs_exports, ["audit"])

      tags = coalesce(c.tags, {})
    }
  }

  # Flatten the per-cluster instance_count into a single map that for_each can iterate.
  # Keys are "<cluster_key>-<index>", e.g. "prod-1", "prod-2", "prod-3".
  cluster_instances = merge([
    for cluster_key, cluster in local.clusters : {
      for i in range(1, cluster.instance_count + 1) :
      "${cluster_key}-${i}" => {
        cluster_key        = cluster_key
        cluster_identifier = cluster.cluster_identifier
        instance_class     = cluster.instance_class
        instance_index     = i
      }
    }
  ]...)
}
