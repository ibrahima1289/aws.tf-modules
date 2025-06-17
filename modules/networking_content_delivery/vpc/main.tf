data "aws_availability_zones" "available" {}
# Ensure that the public subnets are distributed across availability zones
# This is done by using the index of the CIDR in the list to determine the AZ

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = false
  enable_dns_hostnames = true
  tags                 = var.tags
}

resource "aws_subnet" "public" {
  for_each                = toset(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, index(var.public_subnet_cidrs, each.value) % length(data.aws_availability_zones.available.names))
  tags                    = merge(var.tags, { "Name" = "Public Subnet ${each.value}" })
}

resource "aws_subnet" "private" {
  for_each          = toset(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(data.aws_availability_zones.available.names, index(var.private_subnet_cidrs, each.value) % length(data.aws_availability_zones.available.names))
  tags              = merge(var.tags, { "Name" = "Private Subnet ${each.value}" })
}