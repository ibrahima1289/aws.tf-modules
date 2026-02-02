# Outputs: key identifiers and endpoints
output "lb_arns" {
  description = "Map of NLB name to ARN."
  value       = module.aws_nlb.lb_arns
}

output "lb_dns_names" {
  description = "Map of NLB name to DNS name."
  value       = module.aws_nlb.lb_dns_names
}

output "lb_zone_ids" {
  description = "Map of NLB name to hosted zone ID for Route53 aliases."
  value       = module.aws_nlb.lb_zone_ids
}

output "target_group_arns" {
  description = "Map of '<nlb_name>:<tg_name>' to target group ARN."
  value       = module.aws_nlb.target_group_arns
}

output "listener_arns" {
  description = "Map of '<nlb_name>:<port>' to listener ARN."
  value       = module.aws_nlb.listener_arns
}
