locals {
  # Stamp the wrapper-level tags with today's date
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
