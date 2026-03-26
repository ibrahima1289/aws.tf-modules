# ── Vault outputs ─────────────────────────────────────────────────────────────

output "vault_ids" {
  description = "Map of vault key → Backup vault ID."
  value       = module.backup.vault_ids
}

output "vault_arns" {
  description = "Map of vault key → Backup vault ARN."
  value       = module.backup.vault_arns
}

output "vault_names" {
  description = "Map of vault key → Backup vault name."
  value       = module.backup.vault_names
}

# ── Plan outputs ──────────────────────────────────────────────────────────────

output "plan_ids" {
  description = "Map of plan key → Backup plan ID."
  value       = module.backup.plan_ids
}

output "plan_arns" {
  description = "Map of plan key → Backup plan ARN."
  value       = module.backup.plan_arns
}

output "plan_versions" {
  description = "Map of plan key → Backup plan version string."
  value       = module.backup.plan_versions
}

# ── Selection outputs ─────────────────────────────────────────────────────────

output "selection_ids" {
  description = "Map of selection key → Backup selection ID."
  value       = module.backup.selection_ids
}
