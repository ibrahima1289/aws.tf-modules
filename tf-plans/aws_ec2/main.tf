module "ec2" {
  source = "../../modules/compute/aws_EC2s/aws_ec2"

  region                      = var.region
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  instance_count              = var.instance_count
  instances                   = var.instances
  subnet_id                   = var.subnet_id
  security_group_ids          = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring
  name                        = var.name
  tags                        = var.tags
  user_data                   = var.user_data
}
