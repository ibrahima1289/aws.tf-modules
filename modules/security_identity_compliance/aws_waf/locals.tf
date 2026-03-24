locals {
  # Step 1: Record the date when Terraform is run for consistent resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build the common tag set merged into every taggable WAF resource.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert the web_acls list to a stable map keyed by web_acl.key.
  # Enables safe for_each iteration and predictable Terraform state addressing.
  web_acls_map = { for w in var.web_acls : w.key => w }

  # Step 4: Convert the ip_sets list to a stable map keyed by ip_set.key.
  ip_sets_map = { for i in var.ip_sets : i.key => i }

  # Step 5: Convert the regex_pattern_sets list to a stable map keyed by regex_pattern_set.key.
  regex_pattern_sets_map = { for r in var.regex_pattern_sets : r.key => r }

  # Step 6: Flatten Web ACL associations into a (web_acl_key, resource_arn) pair list.
  # This enables a clean for_each over all (acl, resource) associations without nested loops.
  web_acl_associations_flat = flatten([
    for wacl_key, wacl in local.web_acls_map : [
      for arn in coalesce(wacl.association_resource_arns, []) : {
        key          = "${wacl_key}::${arn}"
        web_acl_key  = wacl_key
        resource_arn = arn
      }
    ]
  ])

  # Step 7: Convert the flattened associations list to a map for for_each.
  web_acl_associations_map = { for a in local.web_acl_associations_flat : a.key => a }
}
