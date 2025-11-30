output "security_group_name" {
  value = aws_security_group.sg.name
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "security_group_description" {
  value = aws_security_group.sg.description
}

output "security_group_vpc_id" {
  value = aws_security_group.sg.vpc_id
}