locals {
  # Step 1: Compute a stable date stamp used for wrapper-level resource tagging.
  # This value is injected into the tags map before passing to the module,
  # ensuring every resource carries a created_date tag on first apply.
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
