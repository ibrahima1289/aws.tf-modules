# Example: heterogeneous instances (uncomment to use and set instance_count = 0)
region = "us-east-2"
ami_id = "ami-050352a65e954abb1"

instances = [
  {
    region                      = "us-east-2"
    ami_id                      = "ami-0f5fcdfbd140e4ab7"
    instance_type               = "t3.micro"
    subnet_id                   = "subnet-07a1eccf768a7c102"
    security_group_ids          = ["sg-05a0cd1476ee53080"]
    key_name                    = null
    associate_public_ip_address = false
    name                        = "web-a"
    user_data                   = null
  },
  {
    region                      = "us-east-2"
    ami_id                      = "ami-0f5fcdfbd140e4ab7"
    instance_type               = "t3.small"
    name                        = "web-b"
    associate_public_ip_address = false
    subnet_id                   = "subnet-07a1eccf768a7c102"
    security_group_ids          = ["sg-05a0cd1476ee53080"]
  }
]
