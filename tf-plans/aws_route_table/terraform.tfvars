# Example variable values for the Route Table wrapper plan

region = "ca-central-1"
vpc_id = "vpc-056cd97ff3714931d"

# Define multiple route tables by group
route_tables = [
  {
    name = "public-rt"
    routes = [
      {
        destination_cidr_block = "0.0.0.0/0"
        gateway_id             = "igw-0fc39450730782e42"
      }
    ]
    subnet_group = "public"
    set_as_main  = false
  } #,
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
  "subnet-0be0da5a6707ead9f",
  "subnet-015b2eac4d7bb6880"
]

# private_subnet_ids = [
#   "subnet-fedcba9876543210",
#   "subnet-1234567890abcdef"
# ]

