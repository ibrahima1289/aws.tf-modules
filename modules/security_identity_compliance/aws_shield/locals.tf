locals {
  # Step 1: Record the date when Terraform is run for consistent resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build the common tag set merged into every taggable Shield resource.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert the protections list to a stable map keyed by protection.key.
  # This enables safe for_each iteration and predictable state addressing.
  protections_map = { for p in var.protections : p.key => p }

  # Step 4: Convert the protection_groups list to a stable map keyed by group.key.
  protection_groups_map = { for g in var.protection_groups : g.key => g }
}
