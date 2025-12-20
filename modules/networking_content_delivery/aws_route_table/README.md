# AWS Route Tables (Flexible Module)

Creates one or more AWS Route Tables within a given VPC, with optional routes to common targets (IGW, NAT, TGW, VPC Peering, ENI, Instance, Egress-only gateway, Local GW, VPC Endpoint, Prefix Lists). Each route table can be associated to subnets either via explicit IDs or by selecting a subnet group (`public` or `private`). Optionally set one table as the VPC's main route table.

No data sources are used; all inputs are provided via variables.

## Usage

```hcl
module "route_table" {
  source = "../../modules/networking_content_delivery/aws_route_table"

  # Required
  region = var.region
  vpc_id = var.vpc_id

  # Multiple route tables
  route_tables = [
    {
      name   = "public-rt"
      tags   = { Environment = "dev" }
      routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
          gateway_id             = var.internet_gateway_id
        }
      ]
      subnet_group = "public" # or provide explicit subnet_ids = [ ... ]
      set_as_main  = false
    },
    {
      name   = "private-rt"
      routes = [
        {
          destination_cidr_block = "10.0.0.0/16"
          transit_gateway_id     = var.tgw_id
        }
      ]
      subnet_group = "private"
    }
  ]

  # Subnet groups support
  public_subnet_ids  = var.public_subnet_ids
  private_subnet_ids = var.private_subnet_ids
}
```

## Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| region | string | Yes | n/a | AWS region to deploy resources in. |
| vpc_id | string | Yes | n/a | ID of the VPC. |
| route_tables | list(object) | No | `[]` | List of route table definitions. Each object supports: `name`, `tags`, `routes` (list), `subnet_group` (`public` or `private`) or `subnet_ids` (list), and `set_as_main` (bool). |
| public_subnet_ids | list(string) | No | `[]` | Subnet IDs used when a route table sets `subnet_group = "public"`. |
| private_subnet_ids | list(string) | No | `[]` | Subnet IDs used when a route table sets `subnet_group = "private"`. |
| name | string | No | `null` | Fallback single-table `Name` tag. Used only when `route_tables` is empty. |
| tags | map(string) | No | `{}` | Fallback single-table tags. Used only when `route_tables` is empty. |
| routes | list(object) | No | `[]` | Fallback single-table routes list. Used only when `route_tables` is empty. Each route supports one target from: `gateway_id`, `nat_gateway_id`, `transit_gateway_id`, `vpc_peering_connection_id`, `egress_only_gateway_id`, `network_interface_id`, `local_gateway_id`, `vpc_endpoint_id`. |
| subnet_ids | list(string) | No | `[]` | Fallback single-table subnet associations. Used only when `route_tables` is empty. |
| set_as_main | bool | No | `false` | Fallback single-table main association. Used only when `route_tables` is empty. |

## Outputs

| Name | Description |
|------|-------------|
| route_table_ids | Map of route table keys to IDs. |
| association_subnet_ids | Map of route table keys to associated subnet IDs. |
| route_keys | Keys identifying created route entries per table. |

## Notes
- The module adds a `created_date` tag (ISO-8601) via `locals.tf`.
- No data sources are used; pass all IDs explicitly (e.g., IGW ID, NAT GW ID, etc.).
- Ensure each route object sets exactly one target attribute.
- Output map keys correspond to each route table's `name` if provided; otherwise they use an auto-generated key `rt-<index>`.
