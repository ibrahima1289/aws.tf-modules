# ── Volume outputs ────────────────────────────────────────────────────────────

output "volume_ids" {
  description = "Map of volume key → EBS volume ID."
  value       = module.ebs.volume_ids
}

output "volume_arns" {
  description = "Map of volume key → EBS volume ARN."
  value       = module.ebs.volume_arns
}

output "volume_types" {
  description = "Map of volume key → volume type."
  value       = module.ebs.volume_types
}

output "volume_sizes" {
  description = "Map of volume key → size in GiB."
  value       = module.ebs.volume_sizes
}

output "volume_availability_zones" {
  description = "Map of volume key → Availability Zone."
  value       = module.ebs.volume_availability_zones
}

# ── Attachment outputs ────────────────────────────────────────────────────────

output "attachment_volume_ids" {
  description = "Map of attachment key → attached volume ID."
  value       = module.ebs.attachment_volume_ids
}

output "attachment_device_names" {
  description = "Map of attachment key → device name inside the instance."
  value       = module.ebs.attachment_device_names
}

# ── Snapshot outputs ──────────────────────────────────────────────────────────

output "snapshot_ids" {
  description = "Map of snapshot key → EBS snapshot ID."
  value       = module.ebs.snapshot_ids
}

output "snapshot_arns" {
  description = "Map of snapshot key → EBS snapshot ARN."
  value       = module.ebs.snapshot_arns
}
