locals {
  # Add immutable creation date stamp at wrapper level.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Load policy content from individual JSON files under policies/<key>.json.
  # If content is supplied directly in var.policies, the file is not used.
  policies_with_content = [
    for p in var.policies : merge(p, {
      content = p.content != "" ? p.content : file("${path.module}/policies/${p.key}.json")
    })
  ]
}
