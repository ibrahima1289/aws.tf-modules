# ── Gateway outputs ────────────────────────────────────────────────────────────

output "gateway_ids" {
  description = "Map of gateway key → Storage Gateway ID."
  value       = module.storage_gateway.gateway_ids
}

output "gateway_arns" {
  description = "Map of gateway key → Storage Gateway ARN."
  value       = module.storage_gateway.gateway_arns
}

output "gateway_names" {
  description = "Map of gateway key → gateway display name."
  value       = module.storage_gateway.gateway_names
}

# ── NFS share outputs ──────────────────────────────────────────────────────────

output "nfs_share_ids" {
  description = "Map of NFS share key → file share ID."
  value       = module.storage_gateway.nfs_share_ids
}

output "nfs_share_arns" {
  description = "Map of NFS share key → file share ARN."
  value       = module.storage_gateway.nfs_share_arns
}

output "nfs_share_paths" {
  description = "Map of NFS share key → NFS mount path."
  value       = module.storage_gateway.nfs_share_paths
}

# ── SMB share outputs ──────────────────────────────────────────────────────────

output "smb_share_ids" {
  description = "Map of SMB share key → file share ID."
  value       = module.storage_gateway.smb_share_ids
}

output "smb_share_arns" {
  description = "Map of SMB share key → file share ARN."
  value       = module.storage_gateway.smb_share_arns
}

output "smb_share_paths" {
  description = "Map of SMB share key → SMB share path."
  value       = module.storage_gateway.smb_share_paths
}

# ── Volume outputs ─────────────────────────────────────────────────────────────

output "cached_volume_arns" {
  description = "Map of cached volume key → volume ARN."
  value       = module.storage_gateway.cached_volume_arns
}

output "cached_volume_target_arns" {
  description = "Map of cached volume key → iSCSI target ARN."
  value       = module.storage_gateway.cached_volume_target_arns
}

output "stored_volume_arns" {
  description = "Map of stored volume key → volume ARN."
  value       = module.storage_gateway.stored_volume_arns
}

output "stored_volume_target_arns" {
  description = "Map of stored volume key → iSCSI target ARN."
  value       = module.storage_gateway.stored_volume_target_arns
}

# ── Tape pool outputs ──────────────────────────────────────────────────────────

output "tape_pool_ids" {
  description = "Map of tape pool key → pool ID."
  value       = module.storage_gateway.tape_pool_ids
}

output "tape_pool_arns" {
  description = "Map of tape pool key → pool ARN."
  value       = module.storage_gateway.tape_pool_arns
}
