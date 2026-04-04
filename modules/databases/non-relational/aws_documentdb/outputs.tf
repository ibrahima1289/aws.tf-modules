// Output values for AWS DocumentDB module

# ---------------------------------------------------------------------------
# Cluster outputs
# ---------------------------------------------------------------------------

# Full map of cluster details: endpoints, ARNs, and key configuration attributes
output "clusters" {
  description = "Map of DocumentDB cluster details keyed by the logical cluster name."
  sensitive   = true
  value = {
    for key, cluster in aws_docdb_cluster.cluster : key => {
      id                              = cluster.id
      arn                             = cluster.arn
      cluster_identifier              = cluster.cluster_identifier
      endpoint                        = cluster.endpoint        # Write (primary) endpoint
      reader_endpoint                 = cluster.reader_endpoint # Read (load-balanced) endpoint
      port                            = cluster.port
      engine_version                  = cluster.engine_version
      master_username                 = cluster.master_username
      storage_encrypted               = cluster.storage_encrypted
      kms_key_id                      = cluster.kms_key_id
      storage_type                    = cluster.storage_type
      backup_retention_period         = cluster.backup_retention_period
      deletion_protection             = cluster.deletion_protection
      enabled_cloudwatch_logs_exports = cluster.enabled_cloudwatch_logs_exports
      hosted_zone_id                  = cluster.hosted_zone_id
      tags_all                        = cluster.tags_all
    }
  }
}

# Cluster ARNs — useful for IAM resource policies and cross-account references
output "cluster_arns" {
  description = "Map of logical cluster keys to their ARNs."
  value = {
    for key, cluster in aws_docdb_cluster.cluster : key => cluster.arn
  }
}

# Primary (write) endpoint for each cluster — always routes to the current primary instance
output "cluster_endpoints" {
  description = "Map of logical cluster keys to their primary (write) cluster endpoints."
  value = {
    for key, cluster in aws_docdb_cluster.cluster : key => cluster.endpoint
  }
}

# Reader endpoint for each cluster — load-balanced across all available replica instances
output "reader_endpoints" {
  description = "Map of logical cluster keys to their reader (load-balanced read) endpoints."
  value = {
    for key, cluster in aws_docdb_cluster.cluster : key => cluster.reader_endpoint
  }
}

# ---------------------------------------------------------------------------
# Subnet group outputs
# ---------------------------------------------------------------------------

output "subnet_groups" {
  description = "Map of logical cluster keys to their subnet group IDs and ARNs."
  value = {
    for key, sg in aws_docdb_subnet_group.subnet_group : key => {
      id  = sg.id
      arn = sg.arn
    }
  }
}

# ---------------------------------------------------------------------------
# Parameter group outputs
# ---------------------------------------------------------------------------

# Only populated for clusters that had explicit parameters defined
output "parameter_groups" {
  description = "Map of logical cluster keys to their custom parameter group IDs and ARNs (only clusters with parameters defined)."
  value = {
    for key, pg in aws_docdb_cluster_parameter_group.param_group : key => {
      id  = pg.id
      arn = pg.arn
    }
  }
}

# ---------------------------------------------------------------------------
# Instance outputs
# ---------------------------------------------------------------------------

# Full map of instance details keyed by "<cluster_key>-<index>"
output "instances" {
  description = "Map of instance keys (format: <cluster_key>-<index>) to their details."
  value = {
    for key, instance in aws_docdb_cluster_instance.instance : key => {
      id                 = instance.id
      arn                = instance.arn
      identifier         = instance.identifier
      endpoint           = instance.endpoint
      port               = instance.port
      instance_class     = instance.instance_class
      availability_zone  = instance.availability_zone
      writer             = instance.writer # true if this is the primary instance
      promotion_tier     = instance.promotion_tier
      cluster_identifier = instance.cluster_identifier
      engine_version     = instance.engine_version
      tags_all           = instance.tags_all
    }
  }
}
