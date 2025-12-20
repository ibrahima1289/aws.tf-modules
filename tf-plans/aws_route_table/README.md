# TF Plan: AWS Route Tables

Wrapper plan that instantiates the `aws_route_table` module. Supports creating one or many route tables, associating them with public/private subnet groups or explicit subnet IDs, and setting one as the main route table. No data sources are used.

## Usage

```hcl
# provider.tf
provider "aws" {
  region = var.region
}

# main.tf
module "route_table" {
  source = "../../modules/networking_content_delivery/aws_route_table"

  region = var.region
  vpc_id = var.vpc_id

  # Multiple route tables
  route_tables = [
    {
      name   = "public-rt"
      routes = [
        { destination_cidr_block = "0.0.0.0/0", gateway_id = var.internet_gateway_id }
      ]
      subnet_group = "public"
      set_as_main  = false
    },
    {
      name   = "private-rt"
      routes = [
        { destination_cidr_block = "10.0.0.0/16", nat_gateway_id = var.nat_gateway_id }
      ]
      subnet_group = "private"
    }
  ]

  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids
}

# variables.tf
variable "region" { type = string }
variable "vpc_id" { type = string }
variable "routes" {
  type = list(object({
    destination_cidr_block      = optional(string)
    destination_ipv6_cidr_block = optional(string)
    destination_prefix_list_id  = optional(string)

    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    transit_gateway_id        = optional(string)
    vpc_peering_connection_id = optional(string)
    egress_only_gateway_id    = optional(string)
    network_interface_id      = optional(string)
    local_gateway_id          = optional(string)
    vpc_endpoint_id           = optional(string)
  }))
}
```

## Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| region | string | Yes | n/a | AWS region to deploy resources in. |
| vpc_id | string | Yes | n/a | VPC ID where the route table(s) will be created. |
| route_tables | list(object) | No | `[]` | Route table definitions for multiple creation. Each supports `name`, `tags`, `routes`, `subnet_group` or `subnet_ids`, `set_as_main`. |
| public_subnet_ids | list(string) | No | `[]` | Subnet IDs forwarded for `subnet_group = public`. |
| private_subnet_ids | list(string) | No | `[]` | Subnet IDs forwarded for `subnet_group = private`. |
| name | string | No | `null` | Fallback `Name` for single-table use. |
| tags | map(string) | No | `{}` | Fallback tags for single-table use. |
| routes | list(object) | No | `[]` | Fallback routes for single-table use. |
| subnet_ids | list(string) | No | `[]` | Fallback subnet IDs for single-table use. |
| set_as_main | bool | No | `false` | Fallback main association for single-table use. |

## Outputs

| Name | Description |
|------|-------------|
| route_table_ids | Map of route table keys to IDs |

### Output Keys
- Keys are derived from each route table's `name` when provided.
- If `name` is not set, keys default to `rt-<index>` (e.g., `rt-0`).

## Notes
- The wrapper adds a `created_date` tag via `locals.tf`.
- No data sources are used in either the wrapper or the module.
- Route object targets supported: `gateway_id`, `nat_gateway_id`, `transit_gateway_id`, `vpc_peering_connection_id`, `egress_only_gateway_id`, `network_interface_id`, `local_gateway_id`, `vpc_endpoint_id`.
