# ── Workgroup outputs ─────────────────────────────────────────────────────────

output "workgroup_names" {
  description = "Map of workgroup key → workgroup name."
  value       = module.athena.workgroup_names
}

output "workgroup_arns" {
  description = "Map of workgroup key → workgroup ARN."
  value       = module.athena.workgroup_arns
}

output "workgroup_states" {
  description = "Map of workgroup key → current state (ENABLED or DISABLED)."
  value       = module.athena.workgroup_states
}

# ── Database outputs ──────────────────────────────────────────────────────────

output "database_names" {
  description = "Map of database key → Athena database name."
  value       = module.athena.database_names
}

# ── Named query outputs ───────────────────────────────────────────────────────

output "named_query_ids" {
  description = "Map of named query key → saved query ID."
  value       = module.athena.named_query_ids
}

output "named_query_names" {
  description = "Map of named query key → saved query display name."
  value       = module.athena.named_query_names
}

# ── Data catalog outputs ──────────────────────────────────────────────────────

output "data_catalog_names" {
  description = "Map of data catalog key → catalog name."
  value       = module.athena.data_catalog_names
}

output "data_catalog_arns" {
  description = "Map of data catalog key → catalog ARN."
  value       = module.athena.data_catalog_arns
}
