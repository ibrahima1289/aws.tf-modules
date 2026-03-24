locals {
  # Compute today's date once so every resource in this module receives
  # a consistent created_date tag regardless of when the apply runs.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Merge caller-supplied tags with the auto-generated created_date so that
  # every Firewall Manager resource inherits a common baseline tag set.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Convert the flat list of policy objects into a map keyed by policy name.
  # for_each requires a map; this pattern enables safe add/update/delete of
  # individual policies without re-creating unrelated ones in the same run.
  policies_map = { for p in var.policies : p.name => p }
}
