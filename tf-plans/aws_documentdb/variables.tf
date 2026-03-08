// Input variables for AWS DocumentDB wrapper plan

variable "region" {
  description = "AWS region to deploy DocumentDB resources."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all DocumentDB resources."
  type        = map(string)
  default     = {}
}

# Initial credentials used to seed Secrets Manager secrets on first apply.
# Keys must match the keys in var.clusters that have a secret_name set.
# NEVER set this in terraform.tfvars — pass it via environment variable only:
#   export TF_VAR_initial_credentials='{"dev-cluster":{"username":"docdbadmin","password":"Secret1!"}}'
variable "initial_credentials" {
  description = "Bootstrap credentials written to Secrets Manager on first apply. Keys match cluster keys. Pass via TF_VAR env var only — never in tfvars. Subsequent rotations are managed outside Terraform."
  type = map(object({
    username = string
    password = string
  }))
  default   = {}
  sensitive = true
}

variable "clusters" {
  description = "Map of DocumentDB clusters to create (key is a logical name). Each cluster provisions a subnet group, optional custom parameter group, the cluster itself, and one or more instances."
  type = map(object({
    # ── Cluster identity ──────────────────────────────────────────────────
    cluster_identifier = string

    # ── Engine ────────────────────────────────────────────────────────────
    engine_version = optional(string) # "4.0" | "5.0" (default: "5.0")

    # ── Master credentials ────────────────────────────────────────────────
    # Provide either (a) master_username + master_password directly, or
    # (b) secret_name pointing to a Secrets Manager secret whose JSON contains
    #     {"username": "...", "password": "..."}.
    # Direct values take precedence over the secret when both are supplied.
    master_username = optional(string) # Required if secret_name is not set
    master_password = optional(string) # Required if secret_name is not set
    secret_name     = optional(string) # Secrets Manager secret name or ARN

    # ── Compute ───────────────────────────────────────────────────────────
    instance_class = string           # e.g. "db.t3.medium", "db.r5.large"
    instance_count = optional(number) # 1 = single-node, 3 = HA (1 primary + 2 replicas)

    # ── Networking ────────────────────────────────────────────────────────
    subnet_ids             = list(string)
    vpc_security_group_ids = list(string)
    port                   = optional(number) # Default: 27017

    # ── Subnet group ─────────────────────────────────────────────────────
    subnet_group_name        = optional(string)
    subnet_group_description = optional(string)

    # ── Storage ───────────────────────────────────────────────────────────
    storage_encrypted = optional(bool)   # Default: true
    kms_key_id        = optional(string) # CMK ARN; uses AWS-managed key when null
    storage_type      = optional(string) # "standard" (default) | "iopt1" (I/O-Optimized)

    # ── Backup and maintenance ────────────────────────────────────────────
    backup_retention_period      = optional(number) # Days (1–35); default 7
    preferred_backup_window      = optional(string) # "HH:MM-HH:MM" UTC
    preferred_maintenance_window = optional(string) # "ddd:HH:MM-ddd:HH:MM" UTC
    skip_final_snapshot          = optional(bool)   # Default: true
    final_snapshot_identifier    = optional(string)
    snapshot_identifier          = optional(string) # Restore from this snapshot

    # ── Parameter group ───────────────────────────────────────────────────
    parameter_group_name   = optional(string)
    parameter_group_family = optional(string) # "docdb4.0" | "docdb5.0"; auto-derived if unset
    parameters = optional(list(object({
      name         = string
      value        = string
      apply_method = optional(string) # "immediate" | "pending-reboot"
    })))

    # ── Operations ────────────────────────────────────────────────────────
    deletion_protection             = optional(bool)
    apply_immediately               = optional(bool)
    auto_minor_version_upgrade      = optional(bool)
    enabled_cloudwatch_logs_exports = optional(list(string)) # ["audit"] | ["audit","profiler"]

    # ── Per-cluster tags ──────────────────────────────────────────────────
    tags = optional(map(string))
  }))
  default = {}
}
