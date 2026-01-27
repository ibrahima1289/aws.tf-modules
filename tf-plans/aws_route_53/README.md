# tf-plans: Route 53 Module Wrapper

This wrapper orchestrates multiple Route 53 hosted zones and their records using a `for_each` pattern. It aligns with safe, repeatable applies and avoids null-only arguments by mapping inputs cleanly to the module.

## Usage

```hcl
terraform {
  required_version = ">= 1.4.0"
}

provider "aws" {
  region = var.region
}

module "route53" {
  source  = "../../modules/networking_content_delivery/aws_route_53"
  for_each = var.zones
  zone_name                = each.value.zone_name
  is_private               = try(each.value.is_private, false)
  comment                  = try(each.value.comment, "Managed by Terraform")
  force_destroy            = try(each.value.force_destroy, false)
  delegation_set_id        = try(each.value.delegation_set_id, null)
  vpc_associations         = try(each.value.vpc_associations, [])
  enable_query_log         = try(each.value.enable_query_log, false)
  cloudwatch_log_group_arn = try(each.value.cloudwatch_log_group_arn, null)
  allow_overwrite          = try(each.value.allow_overwrite, false)
  tags                     = try(each.value.tags, {})
  records                  = try(each.value.records, {})
}
```

### Example input

```hcl
variable "region" { type = string }

variable "zones" {
  type = map(object({
    zone_name = string
    records  = optional(map(object({
      name    = string
      type    = string
      ttl     = optional(number)
      records = optional(list(string))
      alias   = optional(object({ name = string, zone_id = string, evaluate_target_health = optional(bool) }))
    })), {})
  }))
}

locals {
  zones = {
    public_example = {
      zone_name = "example.com"
      records = {
        root_a    = { name = "example.com", type = "A", ttl = 300, records = ["203.0.113.10"] }
        www_cname = { name = "www", type = "CNAME", ttl = 300, records = ["example.com"] }
      }
    }

    private_example = {
      zone_name  = "corp.local"
      is_private = true
      vpc_associations = [ { vpc_id = "vpc-0123456789abcdef0" } ]
      records = {
        api_a = { name = "api", type = "A", ttl = 60, records = ["10.0.0.50"] }
      }
    }
  }
}

module "route53" {
  source  = "../../modules/networking_content_delivery/aws_route_53"
  for_each = local.zones
  zone_name        = each.value.zone_name
  is_private       = try(each.value.is_private, false)
  vpc_associations = try(each.value.vpc_associations, [])
  records          = try(each.value.records, {})
}
```

## Inputs

- `region` (string, required): AWS region for provider initialization.
- `zones` (map, required): Map of zone configurations. Each item supports all module variables.

## Outputs

- `zone_ids` (map): Hosted zone IDs keyed by the `zones` keys.
- `name_servers` (map): Name servers for public zones.
