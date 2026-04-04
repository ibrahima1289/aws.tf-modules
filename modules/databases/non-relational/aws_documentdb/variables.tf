// Input variables for AWS DocumentDB module

variable "region" {
  description = "AWS region to deploy DocumentDB resources."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all DocumentDB resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")
    error_message = "tags must include at minimum 'Environment' and 'Owner' keys for cost allocation and governance."
  }
}

variable "clusters" {
  description = "Map of DocumentDB clusters to create (key is a logical name). Each cluster provisions a subnet group, optional custom parameter group, the cluster itself, and one or more instances."
  type = map(object({
    # ── Cluster identity ──────────────────────────────────────────────────
    cluster_identifier = string # Unique identifier for the cluster

    # ── Engine ────────────────────────────────────────────────────────────
    engine_version = optional(string) # "4.0" | "5.0" (default: "5.0")

    # ── Master credentials ────────────────────────────────────────────────
    master_username = string # Admin username for the cluster
    master_password = string # Admin password (use SSM/Secrets Manager in production)

    # ── Compute ───────────────────────────────────────────────────────────
    instance_class = string           # e.g. "db.t3.medium", "db.r5.large", "db.r6g.xlarge"
    instance_count = optional(number) # Number of instances (1 = single-node, 3+ = HA); default 1

    # ── Networking ────────────────────────────────────────────────────────
    subnet_ids             = list(string)     # Subnets (≥ 2 AZs recommended for HA)
    vpc_security_group_ids = list(string)     # Security groups controlling inbound access
    port                   = optional(number) # MongoDB listener port; default 27017

    # ── Subnet group ─────────────────────────────────────────────────────
    subnet_group_name        = optional(string) # Custom name; defaults to "<cluster_identifier>-subnet-group"
    subnet_group_description = optional(string) # Custom description

    # ── Storage ───────────────────────────────────────────────────────────
    storage_encrypted = optional(bool)   # Encrypt the cluster volume at rest; default true
    kms_key_id        = optional(string) # CMK ARN; uses AWS-managed key when null
    storage_type      = optional(string) # "standard" (default) | "iopt1" (I/O-Optimized)

    # ── Backup and maintenance ────────────────────────────────────────────
    backup_retention_period      = optional(number) # Days to retain automated backups (1–35); default 7
    preferred_backup_window      = optional(string) # "HH:MM-HH:MM" UTC; default "03:00-04:00"
    preferred_maintenance_window = optional(string) # "ddd:HH:MM-ddd:HH:MM" UTC; default "sun:05:00-sun:06:00"
    skip_final_snapshot          = optional(bool)   # Skip final snapshot on deletion; default true
    final_snapshot_identifier    = optional(string) # Name for final snapshot when skip_final_snapshot = false
    snapshot_identifier          = optional(string) # Restore cluster from this snapshot ARN/identifier

    # ── Parameter group ───────────────────────────────────────────────────
    parameter_group_name   = optional(string) # Custom name; defaults to "<cluster_identifier>-params"
    parameter_group_family = optional(string) # "docdb4.0" | "docdb5.0"; auto-derived from engine_version
    parameters = optional(list(object({
      name         = string           # Parameter name (e.g. "tls", "audit_logs")
      value        = string           # Parameter value
      apply_method = optional(string) # "immediate" | "pending-reboot" (default)
    })))

    # ── Operational settings ──────────────────────────────────────────────
    deletion_protection             = optional(bool, true)        # Prevent accidental deletion; default true
    apply_immediately               = optional(bool)         # Apply changes immediately; default false
    auto_minor_version_upgrade      = optional(bool)         # Auto-apply minor engine upgrades; default true
    enabled_cloudwatch_logs_exports = optional(list(string)) # ["audit"] | ["audit","profiler"]

    # ── Per-cluster tags ──────────────────────────────────────────────────
    tags = optional(map(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, c in var.clusters :
      c.kms_key_id == null || can(regex("^arn:aws[a-z-]*:kms:", c.kms_key_id))
    ])
    error_message = "kms_key_id must be a valid KMS key ARN (e.g. arn:aws:kms:us-east-1:123456789012:key/...)."
  }
}
