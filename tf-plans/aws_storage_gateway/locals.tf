locals {
  # Captured once per plan; shared with the root module via the tags merge.
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
