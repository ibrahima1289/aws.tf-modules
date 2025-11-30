# Terraform AWS Security Group Module

This module creates an AWS Security Group with dynamic ingress and egress rules. Each rule can have a name, description, and other attributes.

### Usage

In your module call (e.g., in your wrapper's `main.tf`):

```hcl
module "security_group" {
  source       = "../modules/security_identity_compliance/security-group"
  defined_name = var.defined_name # Required: explicit name for the security group
  description  = var.description
  vpc_id       = var.vpc_id
  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
  tags          = var.tags
}
```

### Example `terraform.tfvars`

```hcl
defined_name = "custom-sg-name" # Required: explicit name for the security group
description  = "Example security group"
vpc_id       = "vpc-12345678"
ingress_rules = [
  {
    name        = "ssh-ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  },
  {
    name        = "http-ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }
]
egress_rules = [
  {
    name        = "all-egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all egress"
  }
]
tags = {
  Environment = "dev"
  Owner       = "team"
}
```

### Rule Object Structure

Each object in `ingress_rules` and `egress_rules` supports:
- `name`        (optional): Name for the rule
- `from_port`   (required): Start port
- `to_port`     (required): End port
- `protocol`    (required): Protocol (e.g., "tcp", "udp", "-1")
- `cidr_blocks` (required): List of CIDR blocks
- `description` (optional): Description for the rule

### Outputs

- `security_group_name`: The name of the security group
- `security_group_id`: The ID of the security group
- `security_group_description`: The description of the security group
- `security_group_vpc_id`: The VPC ID of the security group

> **Note:** The `defined_name` variable is required and must be set to specify the security group name. The `name` variable is no longer used. Each rule can have a `name` attribute for clarity and management.

## License

This module is licensed under the MIT License. See the LICENSE file for more information.