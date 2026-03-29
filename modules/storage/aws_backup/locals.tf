locals {
  # ── Timestamp ─────────────────────────────────────────────────────────────────
  # Captured once per plan so all resources share the same created_date tag.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # ── Common tags ────────────────────────────────────────────────────────────────
  # Merge caller-supplied tags with the auto-generated created_date stamp.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # ── Resource maps (stable keys for for_each) ──────────────────────────────────
  # Convert each input list to a map keyed by the caller-supplied .key field.
  vaults_map     = { for v in var.vaults : v.key => v }
  plans_map      = { for p in var.plans : p.key => p }
  selections_map = { for s in var.selections : s.key => s }
}
