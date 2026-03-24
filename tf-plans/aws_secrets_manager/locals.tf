locals {
  # Compute a stable date stamp used for wrapper-level resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
