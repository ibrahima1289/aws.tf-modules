# Outputs: key identifiers and endpoints
output "lb_arn" {
  description = "ARN of the ALB."
  value       = length(var.albs) == 0 ? aws_lb.alb[var.lb_name].arn : null
}

output "lb_dns_name" {
  description = "DNS name of the ALB."
  value       = length(var.albs) == 0 ? aws_lb.alb[var.lb_name].dns_name : null
}

output "lb_zone_id" {
  description = "Hosted Zone ID of the ALB for Route53 aliases."
  value       = length(var.albs) == 0 ? aws_lb.alb[var.lb_name].zone_id : null
}

output "target_group_arns" {
  description = "Map of target group name to ARN."
  value       = { for k, tg in aws_lb_target_group.tg : k => tg.arn }
}

output "listener_arns" {
  description = "Map of listener port to ARN."
  value       = { for k, l in aws_lb_listener.listener : k => l.arn }
}

# Multi-ALB outputs
output "lb_arns" {
  description = "Map of ALB name to ARN (when using multiple ALBs)."
  value       = { for name, alb in aws_lb.alb : name => alb.arn }
}

output "lb_dns_names" {
  description = "Map of ALB name to DNS name (when using multiple ALBs)."
  value       = { for name, alb in aws_lb.alb : name => alb.dns_name }
}

output "lb_zone_ids" {
  description = "Map of ALB name to Hosted Zone ID (when using multiple ALBs)."
  value       = { for name, alb in aws_lb.alb : name => alb.zone_id }
}
