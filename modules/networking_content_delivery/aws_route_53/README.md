# AWS Route 53 Terraform Module

Manage Route 53 hosted zones and records with safe defaults, clear tagging (including an immutable CreatedDate), and scalable patterns. The module avoids passing null-only arguments by splitting alias vs non-alias records and using dynamic blocks for optional routing policies.

## Features

- Public or private hosted zones (with one or more VPC associations for private)
- Records: A, AAAA, CNAME, TXT, MX, NS, SRV, CAA, PTR, SPF
- Alias records and routing policies: weighted, latency, failover, geolocation, CIDR, multivalue
- Optional query logging to CloudWatch Logs
- Safety: `prevent_destroy` on hosted zones (default true) and `force_destroy` default false
- Standard tags merged everywhere with CreatedDate stamped via `time_static`

## Usage

```hcl
provider "aws" {
  region = var.region
}

module "route53" {
  source = "../../modules/networking_content_delivery/aws_route_53"
  zone_name  = "example.com"
  is_private = false

  records = {
    root_a = {
      name    = "example.com"
      type    = "A"
      ttl     = 300
      records = ["203.0.113.10"]
    }

    www_cname = {
      name    = "www"
      type    = "CNAME"
      ttl     = 300
      records = ["example.com"]
    }

    alb_alias = {
      name = "app"
      type = "A"
      alias = {
        name    = "dualstack.alb-xyz.us-east-1.elb.amazonaws.com"
        zone_id = "Z35SXDOTRQ7X7K"
      }
    }
  }
}
```

### Private zone example

```hcl
module "corp_zone" {
  source = "../../modules/networking_content_delivery/aws_route_53"
  zone_name  = "corp.local"
  is_private = true
  vpc_associations = [
    { vpc_id = "vpc-0123456789abcdef0" }
  ]

  records = {
    api = { name = "api", type = "A", ttl = 60, records = ["10.0.0.50"] }
  }
}
```

## Inputs

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | string | — | — | Provider is configured by the caller (wrapper); module does not accept `region`. |
| `zone_name` | string | yes | — | DNS name of the hosted zone. |
| `is_private` | bool | no | `false` | Create a private hosted zone when true. |
| `comment` | string | no | `"Managed by Terraform"` | Hosted zone description/comment. |
| `force_destroy` | bool | no | `false` | Allow destroying a zone even if records remain (use with caution). |
| `delegation_set_id` | string | no | — | Delegation Set ID for reusable name servers (public zones only). |
| `vpc_associations` | list(object) | no | `[]` | VPCs associated with private zones. Object: `{ vpc_id, region? }`. |
| `enable_query_log` | bool | no | `false` | Enable Route 53 query logging. |
| `cloudwatch_log_group_arn` | string | no | — | CloudWatch Log Group ARN for query logs (required when logging is enabled). |
| `allow_overwrite` | bool | no | `false` | Allow overwriting existing records with same name/type. |
| `prevent_destroy` | bool | — | — | Not configurable; module sets lifecycle `prevent_destroy = true` for safety. |
| `tags` | map(string) | no | `{}` | Additional tags merged with standard tags (includes `CreatedDate`). |
| `records` | map(object) | no | `{}` | Map of DNS records to create; see Record Object below. |

### Record Object (per entry in `records`)

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | yes | — | Record name (relative or FQDN). |
| `type` | string | yes | — | One of `A`, `AAAA`, `CNAME`, `TXT`, `MX`, `NS`, `SRV`, `CAA`, `PTR`, `SPF`. |
| `ttl` | number | no (non-alias) | `300` | TTL for non-alias records (module defaults to `300` when omitted). |
| `records` | list(string) | no (non-alias) | `[]` | Values for non-alias records. |
| `alias.name` | string | yes (alias) | — | DNS name of alias target. |
| `alias.zone_id` | string | yes (alias) | — | Hosted zone ID of alias target. |
| `alias.evaluate_target_health` | bool | no | `false` | Evaluate target health for alias. |
| `set_identifier` | string | no | — | Identifier used by certain routing policies. |
| `weighted_routing_policy.weight` | number | no | — | Weight for weighted routing. |
| `latency_routing_policy.region` | string | no | — | AWS region for latency-based routing. |
| `failover_routing_policy.type` | string | no | — | `PRIMARY` or `SECONDARY` for failover routing. |
| `geolocation_routing_policy.continent` | string | no | — | Continent code for geolocation routing. |
| `geolocation_routing_policy.country` | string | no | — | Country code for geolocation routing. |
| `geolocation_routing_policy.subdivision` | string | no | — | Subdivision (state/province) code for geolocation routing. |
| `cidr_routing_policy.collection_id` | string | no | — | CIDR collection ID referenced by the record. |
| `cidr_routing_policy.location_name` | string | no | — | CIDR location name defined within the collection. |
| `multivalue_answer_routing_policy` | bool | no | — | Enable multi-value answers. |
| `health_check_id` | string | no | — | Health check to attach to the record. |

Notes:
- Alias records must not set `ttl` or `records`.
- Only one routing policy type should be applied per record.

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `zone_id` | string | Hosted zone ID. |
| `zone_arn` | string | Hosted zone ARN. |
| `zone_name` | string | DNS name of the hosted zone. |
| `is_private` | bool | Whether the hosted zone is private. |
| `name_servers` | list(string) | Name servers (public zones only). |
| `standard_tags` | map(string) | Effective standard tags (includes `CreatedDate`). |
| `basic_record_ids` | map(string) | IDs for non-alias records, keyed by record key. |
| `alias_record_ids` | map(string) | IDs for alias records, keyed by record key. |
