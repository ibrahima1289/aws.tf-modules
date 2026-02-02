# Outputs: key identifiers and endpoints
# Multi-GLB outputs
output "lb_arns" {
  description = "Map of GWLB name to ARN."
  value       = { for name, g in aws_lb.glb : name => g.arn }
}

output "lb_dns_names" {
  description = "Map of GWLB name to DNS name."
  value       = { for name, g in aws_lb.glb : name => g.dns_name }
}

output "lb_zone_ids" {
  description = "Map of GWLB name to Hosted Zone ID for Route53 aliases."
  value       = { for name, g in aws_lb.glb : name => g.zone_id }
}

output "target_group_arns" {
  description = "Map of '<glb_name>:<tg_name>' to target group ARN."
  value       = { for key, tg in aws_lb_target_group.tg : key => tg.arn }
}

output "listener_arns" {
  description = "Map of '<glb_name>:<port>' to listener ARN."
  value       = { for key, l in aws_lb_listener.listener : key => l.arn }
}
