output "instance_ids" {
  description = "IDs of created EC2 instances"
  value       = module.ec2.instance_ids
}

output "private_ips" {
  description = "Private IPs of created EC2 instances"
  value       = module.ec2.private_ips
}

output "public_ips" {
  description = "Public IPs of created EC2 instances"
  value       = module.ec2.public_ips
}

output "instance_names" {
  description = "Name tags of created EC2 instances"
  value       = module.ec2.instance_names
}
