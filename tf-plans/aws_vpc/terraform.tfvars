region               = "us-east-2"
vpc_cidr_block       = "10.0.0.0/24"
defined_name         = "my-vpc"
public_subnet_cidrs  = ["10.0.0.0/26", "10.0.0.64/26"]
private_subnet_cidrs = ["10.0.0.128/26", "10.0.0.192/26"]
tags = {
  Environment = "dev"
  Owner       = "IT Team"
}