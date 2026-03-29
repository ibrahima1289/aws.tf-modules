# ── GuardDuty wrapper locals ───────────────────────────────────────────────────
locals {
  # Capture the current date to inject as a created_date tag via the module.
  created_date = formatdate("YYYY-MM-DD", timestamp())
}
