locals {
  # Compute a stable date stamp for wrapper-level tag injection.
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
