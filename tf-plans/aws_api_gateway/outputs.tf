# Expose module outputs at the wrapper level

output "api_ids" {
  value       = module.api_gw.api_ids
  description = "Map of API key to API ID"
}

output "integration_ids" {
  value       = module.api_gw.integration_ids
  description = "Map of integration composite key to integration ID"
}

output "route_ids" {
  value       = module.api_gw.route_ids
  description = "Map of route composite key to route ID"
}

output "stage_arns" {
  value       = module.api_gw.stage_arns
  description = "Map of API key to stage ARN"
}

# Convenience output to quickly view endpoints
output "api_endpoints" {
  value       = module.api_gw.api_endpoints
  description = "Map of API key to endpoint URL"
}