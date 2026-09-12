############################################
# EC2 Instances (Simple)
# - Creates one or more EC2 instances using count
# - No data sources, simple inputs only
############################################

resource "aws_instance" "ec2_each" {
  for_each = { for idx, inst in var.instances : tostring(idx) => inst }

  ami                         = each.value.ami_id
  instance_type               = each.value.instance_type != null ? each.value.instance_type : var.instance_type
  subnet_id                   = each.value.subnet_id != null ? each.value.subnet_id : var.subnet_id
  key_name                    = each.value.key_name != null ? each.value.key_name : var.key_name
  associate_public_ip_address = each.value.associate_public_ip_address != null ? each.value.associate_public_ip_address : var.associate_public_ip_address
  monitoring                  = each.value.monitoring != null ? each.value.monitoring : var.monitoring
  user_data                   = each.value.user_data != null ? each.value.user_data : var.user_data
  user_data_replace_on_change = true

  vpc_security_group_ids = each.value.security_group_ids != null ? each.value.security_group_ids : var.security_group_ids

  tags = merge(
    local.base_tags,
    try(each.value.tags, {}),
    (try(each.value.name, var.name) != null ? { Name = try(each.value.name, var.name) } : {})
  )
}
