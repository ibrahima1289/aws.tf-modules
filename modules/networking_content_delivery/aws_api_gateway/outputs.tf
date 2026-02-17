# Map outputs for created APIs and related resources

output "api_ids" {
  description = "Map of API key to API ID"
  value       = { for k, v in aws_apigatewayv2_api.api : k => v.id }
}

output "api_endpoints" {
  description = "Map of API key to endpoint URL"
  value       = { for k, v in aws_apigatewayv2_api.api : k => v.api_endpoint }
}

output "integration_ids" {
  description = "Map of integration composite key to integration ID"
  value       = { for k, v in aws_apigatewayv2_integration.integration : k => v.id }
}

output "route_ids" {
  description = "Map of route composite key to route ID"
  value       = { for k, v in aws_apigatewayv2_route.route : k => v.id }
}

output "stage_arns" {
  description = "Map of API key to stage ARN (when stage provided)"
  value       = { for k, v in aws_apigatewayv2_stage.stage : k => v.arn }
}

# Custom domain outputs (when `var.domains` is configured)

output "custom_domains" {
  description = "Map of domain key to custom domain details (domain name, target domain, and zone ID)"
  value = {
    for k, v in aws_apigatewayv2_domain_name.domain :
    k => {
      domain_name           = v.domain_name
      target_domain_name    = v.domain_name_configuration[0].target_domain_name
      target_hosted_zone_id = v.domain_name_configuration[0].hosted_zone_id
    }
  }
}

output "custom_domain_records" {
  description = "Map of domain key to Route 53 record name and zone ID"
  value = {
    for k, v in aws_route53_record.domain :
    k => {
      name    = v.name
      zone_id = v.zone_id
    }
  }
}
