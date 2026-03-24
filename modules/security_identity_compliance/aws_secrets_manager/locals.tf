locals {
  # Step 1: Record the date when Terraform is run to tag resources consistently.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build common tags shared by all Secrets Manager resources in this module call.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert the input list to a stable map keyed by secret.key for use with for_each.
  secrets_map = { for s in var.secrets : s.key => s }

  # Step 4: Select only secrets that carry a static string value.
  # Secrets managed by rotation or external processes intentionally omit secret_string.
  secrets_with_string_map = {
    for key, s in local.secrets_map : key => s
    if s.secret_string != null && trimspace(s.secret_string) != ""
  }

  # Step 5: Select only secrets that have a rotation Lambda configured.
  secrets_with_rotation_map = {
    for key, s in local.secrets_map : key => s
    if s.rotation_lambda_arn != null && trimspace(s.rotation_lambda_arn) != ""
  }

  # Step 6: Select only secrets that have a resource-based policy to attach.
  secrets_with_policy_map = {
    for key, s in local.secrets_map : key => s
    if s.policy != null && trimspace(s.policy) != ""
  }

  # Step 7: Collect sorted list of secret keys that have rotation enabled for output reporting.
  rotation_enabled_keys = sort(keys(local.secrets_with_rotation_map))
}
