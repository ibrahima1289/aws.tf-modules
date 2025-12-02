# Outputs for AWS KMS Module

output "key_ids" {
  description = "Map of key name to KMS key ID."
  value       = { for k, v in aws_kms_key.key : k => v.key_id }
}

output "key_arns" {
  description = "Map of key name to KMS key ARN."
  value       = { for k, v in aws_kms_key.key : k => v.arn }
}

output "alias_names" {
  description = "Map of key name to primary alias name (if configured)."
  value       = { for k, v in aws_kms_key.key : k => try(replace(aws_kms_alias.alias[k].name, "alias/", ""), null) }
}

output "all_aliases" {
  description = "Map of key name to all alias names (primary + additional, if any)."
  value = {
    for key_def in var.keys : key_def.name => compact(concat(
      [try(replace(aws_kms_alias.alias[key_def.name].name, "alias/", ""), null)],
      [for k2, res in aws_kms_alias.alias_additional : replace(res.name, "alias/", "") if split("|", k2)[0] == key_def.name]
    ))
  }
}
