# AWS EC2 Plan (Wrapper)

A wrapper plan that invokes the simple EC2 module and exposes convenient variables via `terraform.tfvars`. Per-instance networking and settings are supported through the `instances` list.

## Usage

```hcl
module "ec2" {
  source = "../../modules/compute/aws_ec2"

  region                      = var.region
  ami_id                      = var.ami_id
  instance_type               = var.instance_type
  instance_count              = var.instance_count  # currently unused by module
  instances                   = var.instances       # preferred: define instances here
  subnet_id                   = var.subnet_id       # default if an instance omits subnet_id
  security_group_ids          = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring
  name                        = var.name
  tags                        = var.tags            # module adds created_date internally
  user_data                   = var.user_data
}
```

See [terraform.tfvars](terraform.tfvars) for a quick-start configuration with per-instance networking.

## Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| region | string | Yes | n/a | AWS region |
| ami_id | string | Yes | n/a | AMI ID |
| instance_type | string | No | `t3.micro` | Default instance type |
| instance_count | number | No | `1` | Currently unused by the module |
| instances | list(object) | No | `[]` | Per-instance configurations; each supports: `ami_id` (required), `instance_type`, `subnet_id`, `security_group_ids`, `key_name`, `associate_public_ip_address`, `monitoring`, `name`, `tags`, `user_data` |
| subnet_id | string | No | `null` | Default subnet if an instance does not set one |
| security_group_ids | list(string) | No | `[]` | Default security groups if an instance does not set them |
| key_name | string | No | `null` | Key pair name |
| associate_public_ip_address | bool | No | `false` | Default public IP association |
| monitoring | bool | No | `false` | Default detailed monitoring |
| name | string | No | `null` | Default `Name` tag value |
| tags | map(string) | No | `{}` | Extra tags |
| user_data | string | No | `null` | Default user data script |

## Outputs

| Name | Description |
|------|-------------|
| instance_ids | IDs of created EC2 instances |
| private_ips | Private IPs of created EC2 instances |
| public_ips | Public IPs of created EC2 instances |
| instance_names | Name tags of created EC2 instances |

## Notes
- The underlying module adds a `created_date` tag via its `locals.tf`.
- No data sources are used; provide IDs directly or extend the plan to add data lookups.
