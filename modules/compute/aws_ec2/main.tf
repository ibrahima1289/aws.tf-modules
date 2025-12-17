############################################
# EC2 Instances (Simple)
# - Creates one or more EC2 instances using count
# - No data sources, simple inputs only
############################################

resource "aws_instance" "ec2_each" {
  for_each = { for idx, inst in var.instances : tostring(idx) => inst }

  ami                         = each.value.ami_id
  instance_type               = try(each.value.instance_type, var.instance_type)
  subnet_id                   = coalesce(try(each.value.subnet_id, null), var.subnet_id)
  key_name                    = try(each.value.key_name, var.key_name)
  associate_public_ip_address = try(each.value.associate_public_ip_address, var.associate_public_ip_address)
  monitoring                  = try(each.value.monitoring, var.monitoring)
  user_data                   = try(each.value.user_data, var.user_data)

  vpc_security_group_ids = coalesce(try(each.value.security_group_ids, null), var.security_group_ids)

  tags = merge(
    local.base_tags,
    try(each.value.tags, {}),
    (try(each.value.name, var.name) != null ? { Name = try(each.value.name, var.name) } : {})
  )
}
