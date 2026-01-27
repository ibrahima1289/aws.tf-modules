###############################################
# Outputs for the Route 53 module
###############################################

output "zone_id" {
  description = "The Route 53 hosted zone ID."
  value       = aws_route53_zone.route53.zone_id
}

output "zone_arn" {
  description = "The ARN of the Route 53 hosted zone."
  value       = aws_route53_zone.route53.arn
}

output "name_servers" {
  description = "Name servers assigned to the hosted zone (public zones only)."
  value       = aws_route53_zone.route53.name_servers
}

output "zone_name" {
  description = "DNS name of the hosted zone."
  value       = aws_route53_zone.route53.name
}

output "is_private" {
  description = "Whether the hosted zone is private."
  value       = var.is_private
}

output "standard_tags" {
  description = "Standard tags (including CreatedDate) applied to resources."
  value       = local.standard_tags
}

output "basic_record_ids" {
  description = "Map of IDs for non-alias records created by this module."
  value       = { for k, r in aws_route53_record.basic : k => r.id }
}

output "alias_record_ids" {
  description = "Map of IDs for alias records created by this module."
  value       = { for k, r in aws_route53_record.alias : k => r.id }
}
