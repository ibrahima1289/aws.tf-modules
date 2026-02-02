# AWS Network Load Balancer (NLB) Terraform Module

Creates NLBs with target groups and listeners. Applies safe defaults, avoids null values, and adds a created date tag.

## Requirements
- Terraform >= 1.3
- AWS Provider >= 5.0

## Inputs

| Name | Type | Required | Default | Description |
|------|------|---------:|---------|-------------|
| region | string | yes | - | AWS region |
| tags | map(string) | no | `{}` | Global tags applied to all resources |
| nlb_name | string | no | `null` | Single NLB name (optional when not using `nlbs`) |
| subnets | list(string) | no | `[]` | Subnet IDs for the NLB (single mode) |
| internal | bool | no | `false` | Internal vs internet-facing |
| ip_address_type | string | no | `ipv4` | `ipv4` or `dualstack` |
| enable_deletion_protection | bool | no | `true` | Prevent accidental deletion |
| cross_zone_load_balancing | bool | no | `true` | Enable cross-zone LB |
| access_logs | object | no | `{ enabled=false }` | S3 logs: `{ enabled, bucket?, prefix? }` |
| target_groups | list(object) | no | `[]` | Target groups (single mode) with health check & stickiness |
| listeners | list(object) | no | `[]` | Listeners (single mode), default forward target group |
| nlbs | list(object) | no | `[]` | Optional: define multiple NLBs with nested target groups and listeners |

### `target_groups` schema (single or inside `nlbs`)
- `name` (string, required)
- `vpc_id` (string, required)
- `port` (number, required)
- `protocol` (string, required) — `TCP`, `TLS`, `UDP`, `TCP_UDP`
- `target_type` (string, optional) — `instance` (default), `ip`, or `lambda`
- `preserve_client_ip` (bool, optional; only for `target_type=ip`)
- `deregistration_delay` (number, optional, default 300)
- `health_check` (object, optional): `enabled?`, `port?`, `protocol?` (TCP/HTTP/HTTPS), `path?` (HTTP/HTTPS), `interval?`, `timeout?`, `healthy_threshold?`, `unhealthy_threshold?`, `matcher?` (HTTP/HTTPS)
- `stickiness` (object, optional): `enabled?`, `type?` (default `source_ip`), `duration?` (default 3600)
- `tags` (map(string), optional)

### `listeners` schema (single or inside `nlbs`)
- `port` (number, required)
- `protocol` (string, required) — `TCP`, `TLS`, `UDP`, `TCP_UDP`
- `ssl_policy` (string, optional; TLS only)
- `certificate_arn` (string, optional; required for TLS)
- `default_forward_target_group` (string, required) — target group name

## Outputs
- `lb_arns` (map of NLB name → ARN)
- `lb_dns_names` (map of NLB name → DNS name)
- `lb_zone_ids` (map of NLB name → Hosted Zone ID)
- `target_group_arns` (map of `<nlb_name>:<tg_name>` → TG ARN)
- `listener_arns` (map of `<nlb_name>:<port>` → listener ARN)

## Usage (Multi-NLB)
```hcl
module "aws_nlb" {
  source = "../../modules/compute/aws_elb/aws_nlb"

  region = var.region
  tags   = { Environment = "dev" }

  nlbs = [
    {
      name            = "nlb-1"
      subnets         = var.subnet_ids
      internal        = false
      access_logs     = { enabled = false }
      target_groups   = [ { name = "tg-1", vpc_id = var.vpc_id, port = 80, protocol = "TCP" } ]
      listeners       = [ { port = 80, protocol = "TCP", default_forward_target_group = "tg-1" } ]
    },
    {
      name            = "nlb-2"
      subnets         = var.subnet_ids
      internal        = true
      access_logs     = { enabled = true, bucket = "my-logs", prefix = "nlb-2" }
      target_groups   = [ { name = "tg-2", vpc_id = var.vpc_id, port = 443, protocol = "TLS" } ]
      listeners       = [ {
        port                         = 443,
        protocol                     = "TLS",
        ssl_policy                   = "ELBSecurityPolicy-TLS13-1-2-2021-06",
        certificate_arn              = var.acm_cert_arn,
        default_forward_target_group = "tg-2"
      } ]
    }
  ]
}
```

## Notes
- Access logs require `access_logs.enabled=true` and a bucket with proper ACL/policy for LB log delivery.
- TLS listeners require `certificate_arn` and may specify `ssl_policy`.
- For multiple NLBs, use map outputs: `lb_dns_names["<nlb-name>"]` and `lb_zone_ids["<nlb-name>"]`.
