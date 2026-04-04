locals {
  # ── Timestamp ──────────────────────────────────────────────────────────────────
  # Captured once per plan so all resources share the same created_date tag value.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # ── Common tags ────────────────────────────────────────────────────────────────
  # Merge caller-supplied tags with the auto-generated created_date stamp.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # ── Stable for_each maps ───────────────────────────────────────────────────────
  # Convert each input list to a map keyed by the caller-supplied .key field.
  # Using maps (rather than lists) ensures safe resource renaming and adds/removes.
  gateways_map       = { for g in var.gateways : g.key => g }
  nfs_shares_map     = { for s in var.nfs_file_shares : s.key => s }
  smb_shares_map     = { for s in var.smb_file_shares : s.key => s }
  upload_buffers_map = { for b in var.upload_buffers : b.key => b }
  cache_disks_map    = { for c in var.cache_disks : c.key => c }
  cached_volumes_map = { for v in var.cached_volumes : v.key => v }
  stored_volumes_map = { for v in var.stored_volumes : v.key => v }
  tape_pools_map     = { for p in var.tape_pools : p.key => p }
}
