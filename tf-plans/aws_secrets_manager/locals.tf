locals {
  # Compute a stable date stamp used for wrapper-level resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step: Load secret resource-based policies from external JSON files.
  # Keeping policies in separate files avoids inline JSON in tfvars and
  # makes IAM policy changes easier to review in version control.
  policies = {
    app-config = file("${path.module}/policies/app-config-policy.json")
  }

  # Step: Merge file-based policies into the secrets list before passing to the module.
  # Any secret whose key matches a policies entry gets its policy overridden with the file content.
  # Secrets without a matching key pass through unchanged.
  secrets_with_policies = [
    for s in var.secrets : merge(s, {
      policy = lookup(local.policies, s.key, s.policy)
    })
  ]
}
