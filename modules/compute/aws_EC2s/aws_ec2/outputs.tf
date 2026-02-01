############################################
# Outputs
############################################

output "instance_ids" {
  description = "IDs of created EC2 instances"
  value       = values(aws_instance.ec2_each)[*].id
}

output "private_ips" {
  description = "Private IPs of created EC2 instances"
  value       = values(aws_instance.ec2_each)[*].private_ip
}

output "public_ips" {
  description = "Public IPs (if associated) of created EC2 instances"
  value       = values(aws_instance.ec2_each)[*].public_ip
}

output "instance_names" {
  description = "Name tags of created EC2 instances"
  value       = [for i in values(aws_instance.ec2_each) : try(i.tags["Name"], null)]
}
