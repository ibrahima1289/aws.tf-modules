# Terraform AWS Security Group Module

This module creates an AWS Security Group with customizable ingress and egress rules. It allows for dynamic configuration based on provided variables, making it flexible for various use cases.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "security_group" {
  source      = "path/to/terraform-aws-security-group"
  name        = "example-sg"
  description = "Example Security Group"
  vpc_id      = "vpc-12345678"
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    },
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    },
  ]
  tags = {
    Name = "example-sg"
  }
}
```

## Input Variables

| Name          | Description                                   | Type                | Default |
|---------------|-----------------------------------------------|---------------------|---------|
| `name`       | The name of the security group.              | `string`            | n/a     |
| `description`| A description of the security group.         | `string`            | n/a     |
| `vpc_id`     | The VPC ID where the security group will be created. | `string`            | n/a     |
| `ingress_rules` | A list of ingress rules for the security group. | `list(object({ from_port = number, to_port = number, protocol = string, cidr_blocks = list(string), description = optional(string) }))` | `[]` |
| `egress_rules` | A list of egress rules for the security group. | `list(object({ from_port = number, to_port = number, protocol = string, cidr_blocks = list(string), description = optional(string) }))` | `[]` |
| `tags`       | A map of tags to assign to the security group. | `map(string)`       | `{}`    |

## Outputs

| Name                | Description                                   |
|---------------------|-----------------------------------------------|
| `id`                | The ID of the created security group.        |
| `arn`               | The ARN of the created security group.       |

## Example

```hcl
module "my_security_group" {
  source      = "path/to/terraform-aws-security-group"
  name        = "my-sg"
  description = "My Security Group"
  vpc_id      = "vpc-abcdef12"
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["192.168.1.0/24"]
      description = "Allow SSH access"
    },
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    },
  ]
  tags = {
    Name = "my-sg"
  }
}
```

## License

This module is licensed under the MIT License. See the LICENSE file for more information.