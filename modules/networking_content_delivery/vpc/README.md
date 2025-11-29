# AWS VPC Module

This module creates an AWS VPC and public/private subnets supporting both IPv4 and IPv6.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "vpc" {
  source = "../modules/networking_content_delivery/vpc"

  vpc_cidr_block = "10.0.0.0/16"
  defined_name   = "my-vpc" # Optional: Name for the VPC (used as the Name tag)
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  # Set these to true if using IPv6 CIDRs
  public_subnet_is_ipv6  = false
  private_subnet_is_ipv6 = false
  tags = {
    Environment = "dev"
    Owner       = "team"
  }
}
```

> Set `public_subnet_is_ipv6` or `private_subnet_is_ipv6` to true if you are using IPv6 CIDRs for those subnets. All other variables are optional and default to null or empty.

## Variables

### Required Variables
- `vpc_cidr_block`: The IPv4 CIDR block for the VPC (unless using IPAM)
- `public_subnet_cidrs`: List of CIDR blocks for public subnets (IPv4 or IPv6)
- `private_subnet_cidrs`: List of CIDR blocks for private subnets (IPv4 or IPv6)

### Optional Variables
- `defined_name`: Name for the VPC (used as the Name tag, default: null)
- `enable_dns_support`: Enable DNS support (default: null)
- `enable_dns_hostnames`: Enable DNS hostnames (default: null)
- `instance_tenancy`: Tenancy option for instances (default: null)
- `assign_generated_ipv6_cidr_block`: Assign an Amazon-provided IPv6 CIDR block (default: null)
- `ipv4_ipam_pool_id`: IPv4 IPAM pool ID (default: null)
- `ipv4_netmask_length`: Netmask length for IPv4 (default: null)
- `ipv6_ipam_pool_id`: IPv6 IPAM pool ID (default: null)
- `ipv6_cidr_block`: IPv6 CIDR block (default: null)
- `ipv6_cidr_block_network_border_group`: IPv6 network border group (default: null)
- `ipv6_netmask_length`: Netmask length for IPv6 (default: null)
- `tags`: Map of tags to assign (default: empty)
- `public_subnet_is_ipv6`: Set to true if public_subnet_cidrs are IPv6 (default: false)
- `private_subnet_is_ipv6`: Set to true if private_subnet_cidrs are IPv6 (default: false)

---

### Example Directory

#### `example/main.tf`
```hcl
module "vpc" {
  source                = "../"
  vpc_cidr_block        = var.vpc_cidr_block
  defined_name          = var.defined_name
  public_subnet_cidrs   = var.public_subnet_cidrs
  public_subnet_is_ipv6 = var.public_subnet_is_ipv6
  private_subnet_cidrs  = var.private_subnet_cidrs
  private_subnet_is_ipv6 = var.private_subnet_is_ipv6
  tags                  = var.tags
}
```