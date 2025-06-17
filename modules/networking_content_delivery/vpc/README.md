# VPC Terraform Module

This Terraform module creates a Virtual Private Cloud (VPC) in AWS along with associated networking components such as subnets.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "vpc" {
  source                = "./terraform-vpc-module"
  vpc_cidr_block        = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
  tags = {
    Name = "MyVPC"
  }
}
```

## Variables

| Name                  | Description                              | Type         | Default       | Required |
|-----------------------|------------------------------------------|--------------|---------------|----------|
| `vpc_cidr_block`      | The CIDR block for the VPC              | `string`     | n/a           | yes      |
| `public_subnet_cidrs` | List of CIDR blocks for public subnets   | `list(string)` | n/a         | yes      |
| `private_subnet_cidrs`| List of CIDR blocks for private subnets  | `list(string)` | n/a         | yes      |
| `tags`                | A map of tags to assign to resources     | `map(string)` | `{}`         | no       |

---

### Example Directory

#### `example/main.tf`
```hcl
module "vpc" {
  source                = "../"
  vpc_cidr_block        = var.vpc_cidr_block
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  tags                  = var.tags
}
```