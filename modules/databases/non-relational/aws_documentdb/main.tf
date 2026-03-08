// Root module for AWS DocumentDB cluster management
// Supports creating multiple MongoDB-compatible clusters with configurable instances,
// subnet groups, parameter groups, encryption, automated backups, and CloudWatch log exports

# ---------------------------------------------------------------------------
# DocumentDB Subnet Groups
# ---------------------------------------------------------------------------

# Create one subnet group per cluster to control VPC placement and AZ distribution
resource "aws_docdb_subnet_group" "subnet_group" {
  for_each = local.clusters

  # Default name derived from the cluster identifier when not specified
  name        = coalesce(each.value.subnet_group_name, "${each.value.cluster_identifier}-subnet-group")
  description = coalesce(each.value.subnet_group_description, "Subnet group for DocumentDB cluster ${each.value.cluster_identifier}")

  # Subnets should span at least two AZs; three AZs are recommended for HA clusters
  subnet_ids = each.value.subnet_ids

  tags = merge(local.common_tags, var.tags, each.value.tags, {
    Name = coalesce(each.value.subnet_group_name, "${each.value.cluster_identifier}-subnet-group")
  })
}

# ---------------------------------------------------------------------------
# DocumentDB Cluster Parameter Groups
# ---------------------------------------------------------------------------

# A custom parameter group is only created when the caller provides explicit parameters
# (e.g. to enable TLS or configure audit logging levels)
resource "aws_docdb_cluster_parameter_group" "param_group" {
  for_each = {
    for key, cluster in local.clusters : key => cluster
    if length(cluster.parameters) > 0
  }

  # Name defaults to "<cluster_identifier>-params" when not explicitly supplied
  name        = coalesce(each.value.parameter_group_name, "${each.value.cluster_identifier}-params")
  description = "Custom parameter group for DocumentDB cluster ${each.value.cluster_identifier}"

  # Family must match the engine version: docdb4.0 or docdb5.0 (auto-derived in locals)
  family = each.value.parameter_group_family

  # Apply each user-supplied parameter override
  dynamic "parameter" {
    for_each = each.value.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = coalesce(parameter.value.apply_method, "pending-reboot")
    }
  }

  tags = merge(local.common_tags, var.tags, each.value.tags, {
    Name = coalesce(each.value.parameter_group_name, "${each.value.cluster_identifier}-params")
  })

  # Recreate the parameter group before destroying the old one to avoid dependency errors
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------
# DocumentDB Clusters
# ---------------------------------------------------------------------------

# Core cluster resource; storage is automatically replicated 6× across 3 AZs
resource "aws_docdb_cluster" "cluster" {
  for_each = local.clusters

  # ── Identity ─────────────────────────────────────────────────────────────
  cluster_identifier = each.value.cluster_identifier

  # ── Engine ───────────────────────────────────────────────────────────────
  engine         = "docdb"
  engine_version = each.value.engine_version

  # ── Master credentials ────────────────────────────────────────────────────
  # Store passwords in AWS Secrets Manager or SSM Parameter Store; avoid plain text in tfvars
  master_username = each.value.master_username
  master_password = each.value.master_password

  # ── Networking ────────────────────────────────────────────────────────────
  db_subnet_group_name   = aws_docdb_subnet_group.subnet_group[each.key].name
  vpc_security_group_ids = each.value.vpc_security_group_ids
  port                   = each.value.port

  # ── Storage encryption ────────────────────────────────────────────────────
  # Encryption at rest is enabled by default; KMS ARN is optional (AWS-managed key used when null)
  storage_encrypted = each.value.storage_encrypted
  kms_key_id        = each.value.storage_encrypted ? each.value.kms_key_id : null

  # Storage type: "standard" for general workloads; "iopt1" for I/O-intensive production clusters
  storage_type = each.value.storage_type

  # ── Backup settings ───────────────────────────────────────────────────────
  backup_retention_period      = each.value.backup_retention_period
  preferred_backup_window      = each.value.preferred_backup_window
  preferred_maintenance_window = each.value.preferred_maintenance_window

  # When skip_final_snapshot = false a named snapshot is created before deletion
  skip_final_snapshot       = each.value.skip_final_snapshot
  final_snapshot_identifier = each.value.skip_final_snapshot ? null : coalesce(each.value.final_snapshot_identifier, "${each.value.cluster_identifier}-final-snapshot")

  # Restore from an existing snapshot; leave null to provision a fresh cluster
  snapshot_identifier = each.value.snapshot_identifier

  # ── Parameter group ───────────────────────────────────────────────────────
  # Points to the custom group when parameters were provided; otherwise uses the AWS default
  db_cluster_parameter_group_name = length(each.value.parameters) > 0 ? aws_docdb_cluster_parameter_group.param_group[each.key].name : null

  # ── Operations ────────────────────────────────────────────────────────────
  deletion_protection = each.value.deletion_protection
  apply_immediately   = each.value.apply_immediately

  # ── Logging ───────────────────────────────────────────────────────────────
  # Supported exports: "audit" (DDL/DML activity) and "profiler" (slow-query profiling)
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  tags = merge(local.common_tags, var.tags, each.value.tags, {
    Name = each.value.cluster_identifier
  })
}

# ---------------------------------------------------------------------------
# DocumentDB Cluster Instances
# ---------------------------------------------------------------------------

# Instances are provisioned from the flattened cluster_instances map (see locals.tf).
# instance_count = 1  → single primary (dev/test)
# instance_count = 3  → 1 primary + 2 replicas (production HA)
resource "aws_docdb_cluster_instance" "instance" {
  for_each = local.cluster_instances

  # Identifier follows the pattern "<cluster_identifier>-<index>" e.g. "app-prod-1"
  identifier = "${each.value.cluster_identifier}-${each.value.instance_index}"

  # Bind the instance to its parent cluster
  cluster_identifier = aws_docdb_cluster.cluster[each.value.cluster_key].cluster_identifier

  # Compute class determines CPU and memory (same class applied to all instances in the cluster)
  instance_class = each.value.instance_class
  engine         = "docdb"

  # Promotion tier controls failover priority: 0 = highest, 15 = lowest
  # Instance 1 (index=1) gets tier 0 and will be elected primary first during failover
  promotion_tier = each.value.instance_index - 1

  # Inherit cluster-level operational settings
  preferred_maintenance_window = local.clusters[each.value.cluster_key].preferred_maintenance_window
  apply_immediately            = local.clusters[each.value.cluster_key].apply_immediately
  auto_minor_version_upgrade   = local.clusters[each.value.cluster_key].auto_minor_version_upgrade

  tags = merge(local.common_tags, var.tags, local.clusters[each.value.cluster_key].tags, {
    Name = "${each.value.cluster_identifier}-${each.value.instance_index}"
  })
}
