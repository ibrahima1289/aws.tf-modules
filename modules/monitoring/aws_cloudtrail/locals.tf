
locals {
  # Stamp every resource with the calendar date it was first created
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Convert trails list → map keyed by trail name for stable for_each iteration
  trails_map = { for t in var.trails : t.name => t }
}
