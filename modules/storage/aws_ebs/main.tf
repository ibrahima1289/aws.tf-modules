# ── AWS EBS module ─────────────────────────────────────────────────────────────
# Creates EBS volumes, optional volume-to-EC2 attachments, and optional
# point-in-time snapshots.  All resource types support multiple instances via
# for_each; keys are provided by the caller in each list entry's .key field.

# ── Step 1: EBS Volumes ────────────────────────────────────────────────────────
# Core persistent block-storage volumes.  Volume type, size, IOPS, throughput,
# and encryption are all configurable per-volume.
resource "aws_ebs_volume" "volume" {
  for_each = local.volumes_map

  # Availability Zone — must match any EC2 instance that will attach this volume.
  availability_zone = each.value.availability_zone

  # Volume type determines performance characteristics and pricing tier.
  type = each.value.type

  # Volume size in GiB.  Ignored when restoring from a snapshot (snapshot sets minimum).
  size = each.value.size

  # ── Performance ──────────────────────────────────────────────────────────────
  # iops: provisioned for io1/io2 (required) and gp3 (optional, 3 000 baseline).
  # Omit (null) for gp2, st1, sc1 — the provider ignores null for these types.
  iops = each.value.iops

  # throughput: valid only for gp3 volumes (MiB/s); provider ignores for others.
  throughput = each.value.throughput

  # ── Encryption ───────────────────────────────────────────────────────────────
  # Always encrypt by default; uses AWS-managed key when kms_key_id is null.
  encrypted  = each.value.encrypted
  kms_key_id = each.value.kms_key_id

  # ── Multi-Attach ─────────────────────────────────────────────────────────────
  # Attach one volume to multiple EC2 instances (io1/io2 only).
  # Requires a cluster-aware file system to prevent data corruption.
  multi_attach_enabled = each.value.multi_attach_enabled

  # ── Restore from Snapshot ────────────────────────────────────────────────────
  # Populate the volume with data from an existing snapshot.
  # Null means create a blank volume.
  snapshot_id = each.value.snapshot_id

  # ── Lifecycle ─────────────────────────────────────────────────────────────────
  # Capture a snapshot automatically before the volume is destroyed.
  final_snapshot = each.value.final_snapshot

  # Merge common tags, volume-specific tags, and the Name tag.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })

  lifecycle {
    # Guard: multi_attach_enabled is only supported for io1 and io2 volume types.
    # Terraform will report a clear error at plan time if any other type is used.
    precondition {
      condition     = !each.value.multi_attach_enabled || contains(["io1", "io2"], each.value.type)
      error_message = "multi_attach_enabled = true requires volume type io1 or io2 (volume '${each.key}' uses '${each.value.type}')."
    }
  }
}

# ── Step 2: Volume Attachments ────────────────────────────────────────────────
# Attach a managed volume to an EC2 instance via the specified device name.
# Depends implicitly on aws_ebs_volume.this[*] through volume_key resolution.
resource "aws_volume_attachment" "attachment" {
  for_each = local.attachments_map

  # Linux/Windows block device name exposed inside the instance.
  device_name = each.value.device_name

  # Resolve volume ID from the volume key provided by the caller.
  volume_id = aws_ebs_volume.volume[each.value.volume_key].id

  # EC2 instance to attach to; must be in the same AZ as the volume.
  instance_id = each.value.instance_id

  # Force detach on destroy — use with caution; may cause data loss.
  force_detach = each.value.force_detach

  # When true, Terraform will not attempt to detach the volume on destroy.
  skip_destroy = each.value.skip_destroy

  # Gracefully stop the instance before detaching; restart after.
  # Recommended for root/Windows volumes.
  stop_instance_before_detaching = each.value.stop_instance_before_detaching
}

# ── Step 3: EBS Snapshots ─────────────────────────────────────────────────────
# Create a point-in-time incremental backup of a managed volume.
# Snapshots are stored in Amazon S3 (managed by AWS) and billed per GB-month.
resource "aws_ebs_snapshot" "snapshot" {
  for_each = local.snapshots_map

  # Resolve volume ID from the volume key provided by the caller.
  volume_id = aws_ebs_volume.volume[each.value.volume_key].id

  # Human-readable description stored with the snapshot metadata.
  description = each.value.description

  # Merge common tags, snapshot-specific tags, and the Name tag.
  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}
