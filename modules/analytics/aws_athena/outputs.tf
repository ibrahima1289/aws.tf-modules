# ── Workgroup outputs ─────────────────────────────────────────────────────────

output "workgroup_names" {
  description = "Map of workgroup key → workgroup name."
  value       = { for k, v in aws_athena_workgroup.wg : k => v.name }
}

output "workgroup_arns" {
  description = "Map of workgroup key → workgroup ARN."
  value       = { for k, v in aws_athena_workgroup.wg : k => v.arn }
}

output "workgroup_states" {
  description = "Map of workgroup key → current state (ENABLED or DISABLED)."
  value       = { for k, v in aws_athena_workgroup.wg : k => v.state }
}

# ── Database outputs ──────────────────────────────────────────────────────────

output "database_names" {
  description = "Map of database key → Athena database name."
  value       = { for k, v in aws_athena_database.db : k => v.name }
}

# ── Named query outputs ───────────────────────────────────────────────────────

output "named_query_ids" {
  description = "Map of named query key → saved query ID."
  value       = { for k, v in aws_athena_named_query.query : k => v.id }
}

output "named_query_names" {
  description = "Map of named query key → saved query display name."
  value       = { for k, v in aws_athena_named_query.query : k => v.name }
}

# ── Data catalog outputs ──────────────────────────────────────────────────────

output "data_catalog_names" {
  description = "Map of data catalog key → catalog name."
  value       = { for k, v in aws_athena_data_catalog.catalog : k => v.name }
}

output "data_catalog_arns" {
  description = "Map of data catalog key → catalog ARN."
  value       = { for k, v in aws_athena_data_catalog.catalog : k => v.arn }
}
