locals {
  # Step 1: Add immutable created date stamp at wrapper level.
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
