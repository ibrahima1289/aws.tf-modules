# Outputs: key identifiers and endpoints
# Single-NLB (present only if using wrapper single mode)
output "lb_arn" {
  description = "ARN of the NLB (single mode)."
  value       = null
}

output "lb_dns_name" {
  description = "DNS name of the NLB (single mode)."
  value       = null
}

output "lb_zone_id" {
  description = "Hosted Zone ID of the NLB for Route53 aliases (single mode)."
  value       = null
}

# Multi-NLB outputs
output "lb_arns" {
  description = "Map of NLB name to ARN."
  value       = { for name, n in aws_lb.nlb : name => n.arn }
}

output "lb_dns_names" {
  description = "Map of NLB name to DNS name."
  value       = { for name, n in aws_lb.nlb : name => n.dns_name }
}

output "lb_zone_ids" {
  description = "Map of NLB name to Hosted Zone ID for Route53 aliases."
  value       = { for name, n in aws_lb.nlb : name => n.zone_id }
}

output "target_group_arns" {
  description = "Map of '<nlb_name>:<tg_name>' to target group ARN."
  value       = { for key, tg in aws_lb_target_group.tg : key => tg.arn }
}

output "listener_arns" {
  description = "Map of '<nlb_name>:<port>' to listener ARN."
  value       = { for key, l in aws_lb_listener.listener : key => l.arn }
}
