# ── Gateway outputs ────────────────────────────────────────────────────────────

output "gateway_ids" {
  description = "Map of gateway key → Storage Gateway ID."
  value       = { for k, v in aws_storagegateway_gateway.gateway : k => v.id }
}

output "gateway_arns" {
  description = "Map of gateway key → Storage Gateway ARN."
  value       = { for k, v in aws_storagegateway_gateway.gateway : k => v.arn }
}

output "gateway_names" {
  description = "Map of gateway key → gateway display name."
  value       = { for k, v in aws_storagegateway_gateway.gateway : k => v.gateway_name }
}

# ── NFS file share outputs ─────────────────────────────────────────────────────

output "nfs_share_ids" {
  description = "Map of NFS share key → file share ID (ARN)."
  value       = { for k, v in aws_storagegateway_nfs_file_share.nfs_share : k => v.id }
}

output "nfs_share_arns" {
  description = "Map of NFS share key → file share ARN."
  value       = { for k, v in aws_storagegateway_nfs_file_share.nfs_share : k => v.arn }
}

output "nfs_share_paths" {
  description = "Map of NFS share key → NFS mount path (gateway-ip:/export-path)."
  value       = { for k, v in aws_storagegateway_nfs_file_share.nfs_share : k => v.path }
}

# ── SMB file share outputs ─────────────────────────────────────────────────────

output "smb_share_ids" {
  description = "Map of SMB share key → file share ID (ARN)."
  value       = { for k, v in aws_storagegateway_smb_file_share.smb_share : k => v.id }
}

output "smb_share_arns" {
  description = "Map of SMB share key → file share ARN."
  value       = { for k, v in aws_storagegateway_smb_file_share.smb_share : k => v.arn }
}

output "smb_share_paths" {
  description = "Map of SMB share key → SMB share path returned by the gateway."
  value       = { for k, v in aws_storagegateway_smb_file_share.smb_share : k => v.path }
}

# ── Cached volume outputs ──────────────────────────────────────────────────────

output "cached_volume_arns" {
  description = "Map of cached volume key → volume ARN."
  value       = { for k, v in aws_storagegateway_cached_iscsi_volume.cached_volume : k => v.arn }
}

output "cached_volume_target_arns" {
  description = "Map of cached volume key → iSCSI target ARN."
  value       = { for k, v in aws_storagegateway_cached_iscsi_volume.cached_volume : k => v.target_arn }
}

output "cached_volume_ids" {
  description = "Map of cached volume key → volume ID."
  value       = { for k, v in aws_storagegateway_cached_iscsi_volume.cached_volume : k => v.volume_id }
}

# ── Stored volume outputs ──────────────────────────────────────────────────────

output "stored_volume_arns" {
  description = "Map of stored volume key → volume ARN."
  value       = { for k, v in aws_storagegateway_stored_iscsi_volume.stored_volume : k => v.arn }
}

output "stored_volume_target_arns" {
  description = "Map of stored volume key → iSCSI target ARN."
  value       = { for k, v in aws_storagegateway_stored_iscsi_volume.stored_volume : k => v.target_arn }
}

output "stored_volume_ids" {
  description = "Map of stored volume key → volume ID."
  value       = { for k, v in aws_storagegateway_stored_iscsi_volume.stored_volume : k => v.volume_id }
}

# ── Tape pool outputs ──────────────────────────────────────────────────────────

output "tape_pool_ids" {
  description = "Map of tape pool key → pool ID (ARN)."
  value       = { for k, v in aws_storagegateway_tape_pool.tape_pool : k => v.id }
}

output "tape_pool_arns" {
  description = "Map of tape pool key → pool ARN."
  value       = { for k, v in aws_storagegateway_tape_pool.tape_pool : k => v.arn }
}
