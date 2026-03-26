# ── Volume outputs ────────────────────────────────────────────────────────────

output "volume_ids" {
  description = "Map of volume key → EBS volume ID."
  value       = { for k, v in aws_ebs_volume.volume : k => v.id }
}

output "volume_arns" {
  description = "Map of volume key → EBS volume ARN."
  value       = { for k, v in aws_ebs_volume.volume : k => v.arn }
}

output "volume_types" {
  description = "Map of volume key → volume type (gp3, io2, st1, etc.)."
  value       = { for k, v in aws_ebs_volume.volume : k => v.type }
}

output "volume_sizes" {
  description = "Map of volume key → volume size in GiB."
  value       = { for k, v in aws_ebs_volume.volume : k => v.size }
}

output "volume_availability_zones" {
  description = "Map of volume key → Availability Zone."
  value       = { for k, v in aws_ebs_volume.volume : k => v.availability_zone }
}

# ── Attachment outputs ────────────────────────────────────────────────────────

output "attachment_volume_ids" {
  description = "Map of attachment key → attached volume ID."
  value       = { for k, v in aws_volume_attachment.attachment : k => v.volume_id }
}

output "attachment_device_names" {
  description = "Map of attachment key → device name inside the instance."
  value       = { for k, v in aws_volume_attachment.attachment : k => v.device_name }
}

# ── Snapshot outputs ──────────────────────────────────────────────────────────

output "snapshot_ids" {
  description = "Map of snapshot key → EBS snapshot ID."
  value       = { for k, v in aws_ebs_snapshot.snapshot : k => v.id }
}

output "snapshot_arns" {
  description = "Map of snapshot key → EBS snapshot ARN."
  value       = { for k, v in aws_ebs_snapshot.snapshot : k => v.arn }
}
