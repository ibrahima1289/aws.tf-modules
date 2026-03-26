locals {
  # ── Timestamp ────────────────────────────────────────────────────────────────
  # Captured once per plan so all resources share the same created_date tag.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # ── Common tags ───────────────────────────────────────────────────────────────
  # Merge caller-supplied tags with the auto-generated created_date stamp.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # ── Resource maps (stable keys for for_each) ─────────────────────────────────
  # Convert each input list to a map keyed by the caller-supplied .key field.
  workgroups_map    = { for w in var.workgroups : w.key => w }
  databases_map     = { for d in var.databases : d.key => d }
  named_queries_map = { for q in var.named_queries : q.key => q }
  data_catalogs_map = { for c in var.data_catalogs : c.key => c }
}
