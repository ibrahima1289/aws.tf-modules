# Step 1: Set region for this wrapper plan.
region = "us-east-1"

# Step 2: Define global tags used across all NACL resources.
tags = {
  project     = "network-security"
  environment = "dev"
  owner       = "cloud-team"
}

# Step 3: Create multiple NACLs with rules and subnet associations.
nacls = [
  {
    key    = "web"
    name   = "web-tier-nacl"
    vpc_id = "vpc-0123456789abcdef0"

    subnet_ids = [
      "subnet-11111111111111111",
      "subnet-22222222222222222"
    ]

    ingress_rules = [
      {
        rule_number = 100, # Rule numbers must be unique within the ACL and between 1-32766. Lower numbers have higher precedence.
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 80,
        to_port     = 80,
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110,
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 443,
        to_port     = 443,
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120,
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 1024,
        to_port     = 65535,
        cidr_block  = "0.0.0.0/0"
      }
    ]

    egress_rules = [
      {
        rule_number = 100,
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 80,
        to_port     = 80,
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110,
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 443,
        to_port     = 443,
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120,
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 1024,
        to_port     = 65535,
        cidr_block  = "0.0.0.0/0"
      }
    ]

    tags = {
      tier = "web"
    }
  },
  {
    key        = "private"
    name       = "private-tier-nacl"
    vpc_id     = "vpc-0123456789abcdef0"
    subnet_ids = ["subnet-33333333333333333"]

    ingress_rules = [
      {
        rule_number = 100,
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 3306,
        to_port     = 3306,
        cidr_block  = "10.0.0.0/16"
      },
      {
        rule_number = 200,
        protocol    = "-1", # -1 means all protocols
        rule_action = "deny",
        from_port   = 0,
        to_port     = 0,
        cidr_block  = "0.0.0.0/0"
      }
    ]

    egress_rules = [
      {
        rule_number = 100,
        protocol    = "TCP",
        rule_action = "allow",
        from_port   = 443,
        to_port     = 443,
        cidr_block  = "0.0.0.0/0"
      }
    ]

    tags = {
      tier = "private"
    }
  }
]
