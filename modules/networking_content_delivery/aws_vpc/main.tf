data "aws_availability_zones" "available" {}
# Ensure that the public subnets are distributed across availability zones
# This is done by using the index of the CIDR in the list to determine the AZ

resource "aws_vpc" "main" {
  region                               = var.region
  cidr_block                           = var.vpc_cidr_block
  enable_dns_support                   = var.enable_dns_support
  enable_dns_hostnames                 = var.enable_dns_hostnames
  instance_tenancy                     = var.instance_tenancy
  ipv4_ipam_pool_id                    = var.ipv4_ipam_pool_id
  ipv4_netmask_length                  = var.ipv4_netmask_length
  ipv6_ipam_pool_id                    = var.ipv6_ipam_pool_id
  ipv6_cidr_block                      = var.ipv6_cidr_block
  ipv6_netmask_length                  = var.ipv6_netmask_length
  assign_generated_ipv6_cidr_block     = var.assign_generated_ipv6_cidr_block
  ipv6_cidr_block_network_border_group = var.ipv6_cidr_block_network_border_group

  tags = merge(var.tags, {
    Name = var.defined_name != null ? var.defined_name : "Default-VPC",
    created_date = local.created_date
  })
}

resource "aws_subnet" "public" {
  depends_on              = [aws_vpc.main]
  region                  = var.region
  for_each                = toset(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_is_ipv6 ? null : each.value
  ipv6_cidr_block         = var.public_subnet_is_ipv6 ? each.value : null
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.public_subnet_cidrs, each.value) % length(data.aws_availability_zones.available.names))
  tags                    = merge(var.tags, { "Name" = "Public Subnet ${each.value}", created_date = local.created_date })
}

resource "aws_subnet" "private" {
  depends_on        = [aws_vpc.main]
  region            = var.region
  for_each          = toset(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_is_ipv6 ? null : each.value
  ipv6_cidr_block   = var.private_subnet_is_ipv6 ? each.value : null
  availability_zone = element(data.aws_availability_zones.available.names, index(var.private_subnet_cidrs, each.value) % length(data.aws_availability_zones.available.names))
  tags              = merge(var.tags, { "Name" = "Private Subnet ${each.value}", created_date = local.created_date })
}
