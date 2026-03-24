locals {
  # Compute a stable date stamp used for wrapper-level resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step: Load secret resource-based policies from external JSON files.
  # Keeping policies in separate files avoids inline JSON in tfvars and
  # makes IAM policy changes easier to review in version control.
  policies = {
    app-config = file("${path.module}/policies/app-config-policy.json")
  }

  # Step: Load secret_string values from external JSON files under secrets/.
  # Keeping secret templates in separate files makes structure changes readable
  # and allows syntax highlighting and validation in the editor.
  secret_strings = {
    app-config = file("${path.module}/secrets/app-config.json")
  }

  # Step: Merge file-based policies and secret_strings into the secrets list
  # before passing to the module. Secrets without a matching key pass through unchanged.
  secrets_with_policies = [
    for s in var.secrets : merge(s, {
      policy        = lookup(local.policies, s.key, s.policy)
      secret_string = lookup(local.secret_strings, s.key, s.secret_string)
    })
  ]
}
