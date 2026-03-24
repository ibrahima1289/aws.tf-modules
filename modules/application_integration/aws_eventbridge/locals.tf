locals {
  # Step 1: Compute a one-time date stamp used for resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build common tags merged into every resource created by this module.
  common_tags = merge(
    var.tags,
    { created_date = local.created_date }
  )

  # Step 3: Convert the event_buses list to a stable map keyed by bus.key.
  # Used as the for_each argument on aws_cloudwatch_event_bus.
  buses_map = { for b in var.event_buses : b.key => b }

  # Step 4: Convert the rules list to a stable map keyed by rule.key.
  # Used as the for_each argument on aws_cloudwatch_event_rule.
  rules_map = { for r in var.rules : r.key => r }

  # Step 5: Flatten all targets across all rules into a single map.
  # Each entry inherits the parent rule's key and bus_name so targets can
  # reference their rule and event bus without additional lookups.
  # Key format: "<rule_key>_<target_key>" guarantees uniqueness.
  targets_map = {
    for entry in flatten([
      for r in var.rules : [
        for t in coalesce(r.targets, []) : merge(t, {
          rule_key = r.key
          bus_name = r.bus_name
        })
      ]
    ]) : "${entry.rule_key}_${entry.target_key}" => entry
  }

  # Step 6: Convert the archives list to a stable map keyed by archive.key.
  # Used as the for_each argument on aws_cloudwatch_event_archive.
  archives_map = { for a in var.archives : a.key => a }
}
