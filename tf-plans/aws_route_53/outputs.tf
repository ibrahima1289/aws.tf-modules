###############################################
# Useful outputs for downstream consumption
###############################################

output "zone_ids" {
  description = "Map of hosted zone IDs keyed by the wrapper's zone keys."
  value       = { for k, m in module.route53 : k => m.zone_id }
}

output "name_servers" {
  description = "Map of public zone name servers keyed by the wrapper's zone keys."
  value       = { for k, m in module.route53 : k => m.name_servers }
}