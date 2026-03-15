#############################################
# Wrapper - Locals                          #
#############################################

locals {
  # Stamp the wrapper-level tags with today's date
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Load dashboard JSON bodies from the dashboards/ folder.
  # Add a new .json file there and a matching entry in this list to register it.
  # file() reads the raw JSON string at plan time — no inline heredoc needed.
  file_dashboards = [
    {
      name = "demo-overview"
      body = file("${path.module}/dashboards/demo-overview.json")
    }
  ]

  # Merge any extra dashboards passed via var.dashboards (e.g., from CI) with file-based ones.
  all_dashboards = concat(local.file_dashboards, var.dashboards)
}
