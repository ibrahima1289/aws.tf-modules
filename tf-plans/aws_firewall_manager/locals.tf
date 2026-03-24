locals {
  # Compute a one-time created_date stamp; merged into var.tags before passing to the module.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Load managed_service_data payloads from individual JSON files under policies/.
  # Each file is keyed by the policy name used in terraform.tfvars.
  # This keeps terraform.tfvars free of inline JSON blobs.
  _service_data = {
    "shield-advanced-global"   = file("${path.module}/policies/shield-advanced-global.json")
    "wafv2-alb-managed-rules"  = file("${path.module}/policies/wafv2-alb-managed-rules.json")
    "network-firewall-prod-ou" = file("${path.module}/policies/network-firewall-prod-ou.json")
  }

  # Merge file-based service data into each policy object.
  # Falls back to the inline managed_service_data value (if any) for unknown policy names.
  policies_with_data = [
    for p in var.policies : merge(p, {
      managed_service_data = lookup(local._service_data, p.name, p.managed_service_data)
    })
  ]
}
