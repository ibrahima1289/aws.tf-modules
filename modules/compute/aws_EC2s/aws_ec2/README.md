# AWS EC2 (Simple Module)

A minimal Terraform module to create EC2 instances from an explicit `instances` list.
No data sources are used; all inputs are provided via variables.

## Usage

```hcl
module "ec2" {
  source = "../../modules/compute/aws_ec2"

  region = var.region

  # Provide one or more explicit instance configurations
  instances = [
    {
      ami_id        = var.ami_id
      instance_type = "t3.micro"
      name          = "web-1"
      subnet_id     = var.subnet_id
      security_group_ids = ["sg-0123456789abcdef0"]
    },
    {
      ami_id        = var.ami_id
      instance_type = "t3.small"
      name          = "web-2"
      associate_public_ip_address = true
    }
  ]

  # Optional defaults used when an instance omits these
  instance_type = "t3.micro"
  subnet_id     = null
  security_group_ids = []
  key_name      = null
  monitoring    = false
  name          = null
  tags = {
    Environment = "dev"
  }
}
```

## Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| region | string | Yes | n/a | AWS region to deploy EC2 instances in. |
| ami_id | string | Yes | n/a | AMI ID for the instances. |
| instance_type | string | No | `t3.micro` | Default EC2 instance type (used when instance entry omits it). |
| instances | list(object) | No | `[]` | Per-instance configurations. Each object supports: `ami_id` (required), `instance_type`, `subnet_id`, `security_group_ids`, `key_name`, `associate_public_ip_address`, `monitoring`, `name`, `tags`, `user_data`. |
| subnet_id | string | No | `null` | Default subnet ID if an instance does not set `subnet_id`. |
| security_group_ids | list(string) | No | `[]` | Default security groups if an instance does not set `security_group_ids`. |
| key_name | string | No | `null` | Default key pair for SSH/RDP. |
| associate_public_ip_address | bool | No | `false` | Default public IP association. |
| monitoring | bool | No | `false` | Default detailed monitoring. |
| name | string | No | `null` | Default `Name` tag value. |
| tags | map(string) | No | `{}` | Extra tags added to all instances. |
| user_data | string | No | `null` | Default user data script. |
| instance_count | number | No | `1` | Currently not used by the module (reserved for future count-based support). |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | IDs of created EC2 instances |
| private_ips | Private IPs of created EC2 instances |
| public_ips | Public IPs (if associated) |
| instance_names | Name tags of created EC2 instances |

## Notes
- The module adds a `created_date` tag (ISO-8601) to all resources via `locals.tf`.
- No data sources are used; supply a valid `ami_id` for your region.
- If `instances` is empty (default), no EC2 instances are created.
