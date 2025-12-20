# Example variable values for the Route Table wrapper plan

region = "ca-central-1"
vpc_id = "vpc-08101d4a1dce70809"

# Define multiple route tables by group
route_tables = [
  {
    name   = "public-rt"
    routes = [
      {
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "igw-06a7d6476a9e7f79f"
      }
    ]
    subnet_group = "public"
    set_as_main  = false
  }#,
  # {
  #   name   = "private-rt"
  #   routes = [
  #     {
  #       destination_cidr_block = "10.0.0.0/16"
  #       nat_gateway_id         = "nat-0123456789abcdef0"
  #     }
  #   ]
  #   subnet_group = "private"
  # }
]

public_subnet_ids = [
  "subnet-08d0b1eb9418fb2a0",
  "subnet-077271af49a09843c"
]

# private_subnet_ids = [
#   "subnet-fedcba9876543210",
#   "subnet-1234567890abcdef"
# ]
 
