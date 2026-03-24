locals {
  # Step 1: Capture the run date for consistent created_date tagging across all resources.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Merge caller-supplied tags with the immutable created_date tag.
  # Every resource in this module uses local.common_tags as its tag base.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert the rule_groups list to a stable map keyed by `key`.
  # Using a map (not a list) enables for_each, which avoids in-place
  # destroy/recreate when items are reordered.
  rule_groups_map = { for rg in var.rule_groups : rg.key => rg }

  # Step 4: Convert the policies list to a stable map keyed by `key`.
  policies_map = { for p in var.policies : p.key => p }

  # Step 5: Convert the firewalls list to a stable map keyed by `key`.
  firewalls_map = { for f in var.firewalls : f.key => f }

  # Step 6: Derive a sub-map of firewalls that have logging configured.
  # Only firewalls with a non-null logging block get a logging_configuration resource.
  firewalls_with_logging_map = {
    for k, v in local.firewalls_map : k => v
    if v.logging != null
  }
}
