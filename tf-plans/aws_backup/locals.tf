locals {
  # Compute a one-time created_date stamp merged into var.tags before passing to the module.
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
