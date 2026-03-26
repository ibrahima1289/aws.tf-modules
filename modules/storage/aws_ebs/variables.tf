# ── Top-level variables ───────────────────────────────────────────────────────

variable "region" {
  description = "AWS region where EBS resources are deployed."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all taggable EBS resources."
  type        = map(string)
  default     = {}
}

# ── Volumes ────────────────────────────────────────────────────────────────────

variable "volumes" {
  description = <<-EOT
    List of EBS volumes to create.  Each entry maps to one aws_ebs_volume resource.
    Unique keys are used as for_each identifiers.

    Volume type guidance:
      gp3  — General Purpose SSD (default); best baseline cost/performance balance.
      gp2  — Legacy General Purpose SSD; prefer gp3 for new workloads.
      io1  — Provisioned IOPS SSD; up to 64,000 IOPS per volume.
      io2  — Provisioned IOPS SSD with higher durability (99.999%); up to 64,000 IOPS.
      st1  — Throughput Optimized HDD; max 500 MiB/s; not bootable.
      sc1  — Cold HDD; lowest cost; max 250 MiB/s; not bootable.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Friendly name; written as the Name tag on the volume.
    name = string

    # Availability Zone where the volume is created (must match the target EC2 AZ).
    availability_zone = string

    # Volume type: gp3, gp2, io1, io2, st1, or sc1.
    type = optional(string, "gp3")

    # Volume size in GiB.  At least one of size or snapshot_id is required.
    size = optional(number, 20)

    # Provisioned IOPS.
    # Required for io1/io2 (1–64,000).
    # Optional for gp3 (3,000 baseline; max 16,000).
    # Omit (null) for gp2, st1, sc1 to use type defaults.
    iops = optional(number, null)

    # Provisioned throughput in MiB/s — valid for gp3 only (125 baseline; max 1,000).
    # Omit (null) for all other volume types.
    throughput = optional(number, null)

    # Encrypt the volume at rest.  Defaults to true (recommended).
    encrypted = optional(bool, true)

    # ARN of a customer-managed KMS key for encryption.
    # When null, the default AWS-managed EBS key is used (requires encrypted = true).
    kms_key_id = optional(string, null)

    # Allow the volume to be attached to multiple EC2 instances simultaneously.
    # Supported only for io1 and io2 volume types.
    # Requires a cluster-aware file system on the instances.
    multi_attach_enabled = optional(bool, false)

    # Snapshot ID from which to restore this volume.
    # The size must be >= the source snapshot size.
    snapshot_id = optional(string, null)

    # Take a final snapshot before the volume is destroyed by Terraform.
    final_snapshot = optional(bool, false)

    # Per-volume tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}

# ── Volume Attachments ─────────────────────────────────────────────────────────

variable "attachments" {
  description = <<-EOT
    List of volume-to-EC2-instance attachments.  Each entry maps to one
    aws_volume_attachment resource.  The volume_key must match a key in var.volumes.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Key of the volume to attach (must match a volumes[*].key entry).
    volume_key = string

    # ID of the EC2 instance to attach the volume to.
    instance_id = string

    # Linux/Windows device name exposed inside the instance (e.g. /dev/xvdf).
    device_name = string

    # Force detach the volume even if the instance is not stopped.
    # Use only in exceptional circumstances — may cause data loss.
    force_detach = optional(bool, false)

    # Prevent Terraform from detaching the volume on destroy (orphans the attachment).
    # Useful when the volume is managed by the OS or a cluster manager.
    skip_destroy = optional(bool, false)

    # Stop the EC2 instance before detaching the volume, then restart it after.
    # Recommended for root volumes and Windows volumes.
    stop_instance_before_detaching = optional(bool, false)
  }))
  default = []
}

# ── Snapshots ──────────────────────────────────────────────────────────────────

variable "snapshots" {
  description = <<-EOT
    List of EBS snapshots to create from volumes managed by this module.
    Each entry maps to one aws_ebs_snapshot resource.
    The volume_key must match a key in var.volumes.
  EOT
  type = list(object({
    # Unique identifier used as the for_each key.
    key = string

    # Key of the source volume (must match a volumes[*].key entry).
    volume_key = string

    # Friendly name; written as the Name tag on the snapshot.
    name = string

    # Human-readable description stored with the snapshot.
    description = optional(string, "")

    # Per-snapshot tags merged with common_tags.
    tags = optional(map(string), {})
  }))
  default = []
}
