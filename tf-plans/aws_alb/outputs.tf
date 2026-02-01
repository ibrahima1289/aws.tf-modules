# Outputs: key identifiers and endpoints
output "lb_arn" {
  description = "ARN of the ALB."
  value       = module.aws_alb.lb_arn
}

output "lb_dns_name" {
  description = "DNS name of the ALB."
  value       = module.aws_alb.lb_dns_name
}

output "lb_zone_id" {
  description = "Hosted Zone ID of the ALB for Route53 aliases."
  value       = module.aws_alb.lb_zone_id
}

output "target_group_arns" {
  description = "Map of target group name to ARN."
  value       = module.aws_alb.target_group_arns
}

output "listener_arns" {
  description = "Map of listener port to ARN."
  value       = module.aws_alb.listener_arns
}

# Multi-ALB outputs
output "lb_arns" {
  description = "Map of ALB name to ARN (when using multiple ALBs)."
  value       = module.aws_alb.lb_arns
}

output "lb_dns_names" {
  description = "Map of ALB name to DNS name (when using multiple ALBs)."
  value       = module.aws_alb.lb_dns_names
}

output "lb_zone_ids" {
  description = "Map of ALB name to Hosted Zone ID (when using multiple ALBs)."
  value       = module.aws_alb.lb_zone_ids
}
