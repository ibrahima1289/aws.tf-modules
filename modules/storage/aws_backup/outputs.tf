# ── Vault outputs ─────────────────────────────────────────────────────────────

output "vault_ids" {
  description = "Map of vault key → Backup vault ID."
  value       = { for k, v in aws_backup_vault.vault : k => v.id }
}

output "vault_arns" {
  description = "Map of vault key → Backup vault ARN."
  value       = { for k, v in aws_backup_vault.vault : k => v.arn }
}

output "vault_names" {
  description = "Map of vault key → Backup vault name."
  value       = { for k, v in aws_backup_vault.vault : k => v.name }
}

# ── Plan outputs ──────────────────────────────────────────────────────────────

output "plan_ids" {
  description = "Map of plan key → Backup plan ID."
  value       = { for k, v in aws_backup_plan.plan : k => v.id }
}

output "plan_arns" {
  description = "Map of plan key → Backup plan ARN."
  value       = { for k, v in aws_backup_plan.plan : k => v.arn }
}

output "plan_versions" {
  description = "Map of plan key → Backup plan version string."
  value       = { for k, v in aws_backup_plan.plan : k => v.version }
}

# ── Selection outputs ─────────────────────────────────────────────────────────

output "selection_ids" {
  description = "Map of selection key → Backup selection ID."
  value       = { for k, v in aws_backup_selection.selection : k => v.id }
}
