# AWS NACL Terraform Module

Creates and manages one or more [AWS Network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html), including subnet associations and IPv4/IPv6 ingress/egress rules.

## Architecture

```text
                        +-----------------------+
                        |        AWS VPC        |
                        +-----------------------+
                                   |
                    +--------------+--------------+
                    |                             |
         +-------------------+         +-------------------+
         |  Network ACL A    |         |  Network ACL B    |
         |  (web tier)       |         |  (app/db tier)    |
         +-------------------+         +-------------------+
               |        |                    |         |
               v        v                    v         v
           Subnet A  Subnet B            Subnet C   Subnet D

Each NACL supports multiple ingress and egress rules.
Rules are evaluated by rule_number (lowest first).
```

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region for provider configuration |

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags applied to all NACL resources |
| `nacls` | `list(object)` | `[]` | One or more NACL definitions (`key`, `vpc_id`, `subnet_ids`, `ingress_rules`, `egress_rules`, `tags`) |

### `nacls` object fields

| Field | Type | Required | Default | Notes |
|------|------|----------|---------|-------|
| `key` | `string` | Yes | - | Unique key used by `for_each` |
| `name` | `string` | No | `""` | If empty, falls back to `key` |
| `vpc_id` | `string` | Yes | - | VPC where NACL is created |
| `subnet_ids` | `list(string)` | No | `[]` | Subnets to associate with the NACL |
| `tags` | `map(string)` | No | `{}` | Per-NACL tag overrides |
| `ingress_rules` | `list(object)` | No | `[]` | Inbound rules |
| `egress_rules` | `list(object)` | No | `[]` | Outbound rules |

### Rule object fields (`ingress_rules` / `egress_rules`)

| Field | Type | Required | Default | Notes |
|------|------|----------|---------|-------|
| `rule_number` | `number` | Yes | - | Must be unique per direction per NACL |
| `protocol` | `string` | Yes | - | Example: `"-1"`, `"6"`, `"17"` |
| `rule_action` | `string` | Yes | - | `ALLOW` or `DENY` |
| `from_port` | `number` | No | `0` | Start of port range |
| `to_port` | `number` | No | `0` | End of port range |
| `cidr_block` | `string` | No | `""` | IPv4 CIDR; set exactly one CIDR type |
| `ipv6_cidr_block` | `string` | No | `""` | IPv6 CIDR; set exactly one CIDR type |

## Outputs

| Name | Description |
|------|-------------|
| `nacl_ids` | Map of NACL key to NACL ID |
| `nacl_arns` | Map of NACL key to NACL ARN |
| `association_ids` | Map of subnet association key to association ID |
| `ingress_rule_keys` | Keys for all created ingress rules |
| `egress_rule_keys` | Keys for all created egress rules |

## Usage

```hcl
module "nacl" {
  source = "../modules/security_identity_compliance/aws_nacl"

  region = "us-east-1"

  tags = {
    environment = "dev"
    owner       = "cloud-team"
  }

  nacls = [
    {
      key        = "web"
      name       = "web-nacl"
      vpc_id     = "vpc-0123456789abcdef0"
      subnet_ids = ["subnet-11111111111111111", "subnet-22222222222222222"]
      ingress_rules = [
        { rule_number = 100, protocol = "6", rule_action = "ALLOW", from_port = 80, to_port = 80, cidr_block = "0.0.0.0/0" },
        { rule_number = 110, protocol = "6", rule_action = "ALLOW", from_port = 443, to_port = 443, cidr_block = "0.0.0.0/0" }
      ]
      egress_rules = [
        { rule_number = 100, protocol = "-1", rule_action = "ALLOW", from_port = 0, to_port = 0, cidr_block = "0.0.0.0/0" }
      ]
    }
  ]
}
```
