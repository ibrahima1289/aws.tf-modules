# AWS Application Load Balancer (ALB) Terraform Module

Creates an ALB with target groups, listeners, and optional listener rules. Applies safe defaults, avoids null values, and adds a created date tag.

## Requirements
- Terraform \>= 1.3
- AWS Provider \>= 5.0

## Inputs

| Name | Type | Required | Default | Description |
|------|------|---------:|---------|-------------|
| region | string | yes | - | AWS region |
| tags | map(string) | no | `{}` | Global tags applied to all resources |
| lb_name | string | yes | - | Load balancer name |
| subnets | list(string) | yes | - | Subnet IDs for the ALB |
| security_groups | list(string) | no | `[]` | Security groups attached to the ALB |
| internal | bool | no | `false` | Internal vs internet-facing |
| ip_address_type | string | no | `ipv4` | `ipv4` or `dualstack` |
| enable_deletion_protection | bool | no | `true` | Prevent accidental deletion |
| enable_http2 | bool | no | `true` | Enable HTTP/2 |
| drop_invalid_header_fields | bool | no | `true` | Drop invalid headers |
| idle_timeout | number | no | `60` | Idle timeout seconds |
| access_logs | object | no | `{ enabled=false }` | S3 logs: `{ enabled, bucket?, prefix? }` |
| target_groups | list(object) | no | `[]` | Target groups with health check & stickiness options |
| listeners | list(object) | no | `[]` | Listeners, default forward TG, optional rules |
| albs | list(object) | no | `[]` | Optional: define multiple ALBs with nested target groups and listeners |

### `target_groups` schema
- `name` (string, required)
- `vpc_id` (string, required)
- `port` (number, required)
- `protocol` (string, required) — `HTTP` or `HTTPS`
- `target_type` (string, optional) — `instance` (default), `ip`, or `lambda`
- `deregistration_delay` (number, optional, default 300)
- `health_check` (object, optional): `enabled?`, `path?`, `interval?`, `timeout?`, `healthy_threshold?`, `unhealthy_threshold?`, `matcher?`
- `stickiness` (object, optional): `enabled?`, `type?` (default `lb_cookie`), `duration?` (default 86400)
- `tags` (map(string), optional)

### `listeners` schema
- `port` (number, required)
- `protocol` (string, required) — `HTTP` or `HTTPS`
- `ssl_policy` (string, optional)
- `certificate_arn` (string, optional; required if `protocol=HTTPS`)
- `default_forward_target_group` (string, required) — target group name
- `additional_rules` (list(object), optional)
  - `priority` (number, required)
  - `conditions` (object)
    - `host_headers` (list(string), optional)
    - `path_patterns` (list(string), optional)
  - `action_forward_target_group` (string, required)

## Outputs
- Single-ALB:
  - `lb_arn`
  - `lb_dns_name`
  - `lb_zone_id`
- Multi-ALB:
  - `lb_arns` (map of ALB name → ARN)
  - `lb_dns_names` (map of ALB name → DNS name)
  - `lb_zone_ids` (map of ALB name → Hosted Zone ID)
- Always:
  - `target_group_arns` (map of `<alb_name>:<tg_name>` → TG ARN)
  - `listener_arns` (map of `<alb_name>:<port>` → listener ARN)

## Usage
```hcl
module "aws_alb" {
  source = "../../modules/compute/aws_elb/aws_alb"

  # Provider & tags
  region = var.region
  tags   = { Environment = "dev" }

  # ALB basics
  lb_name    = "my-app-alb"
  subnets    = var.subnet_ids
  security_groups = var.alb_security_group_ids
  internal   = false

  # Target groups
  target_groups = [
    {
      name     = "tg-web"
      vpc_id   = var.vpc_id
      port     = 80
      protocol = "HTTP"
      health_check = {
        enabled           = true
        path              = "/health"
        interval          = 30
        timeout           = 5
        healthy_threshold = 5
        matcher           = "200-399"
      }
    }
  ]

  # Listeners
  listeners = [
    {
      port                          = 80
      protocol                      = "HTTP"
      default_forward_target_group  = "tg-web"
      additional_rules = [
        {
          priority = 10
          conditions = {
            path_patterns = ["/api/*"]
          }
          action_forward_target_group = "tg-web"
        }
      ]
    }
  ]
}
```

### Multi-ALB Usage
```hcl
module "aws_alb" {
  source = "../../modules/compute/aws_elb/aws_alb"

  region = var.region
  tags   = { Environment = "dev" }

  # Define multiple ALBs
  albs = [
    {
      name            = "app-alb-1"
      subnets         = var.subnet_ids
      security_groups = var.alb_security_group_ids
      internal        = false
      access_logs = { enabled = false }
      target_groups = [
        { name = "tg-web-1", vpc_id = var.vpc_id, port = 80, protocol = "HTTP" }
      ]
      listeners = [
        { port = 80, protocol = "HTTP", default_forward_target_group = "tg-web-1" }
      ]
    },
    {
      name            = "app-alb-2"
      subnets         = var.subnet_ids
      security_groups = var.alb_security_group_ids
      internal        = true
      access_logs = { enabled = true, bucket = "my-logs", prefix = "alb-2" }
      target_groups = [
        { name = "tg-web-2", vpc_id = var.vpc_id, port = 443, protocol = "HTTPS" }
      ]
      listeners = [
        {
          port                         = 443
          protocol                     = "HTTPS"
          ssl_policy                   = "ELBSecurityPolicy-2016-08"
          certificate_arn              = var.acm_cert_arn
          default_forward_target_group = "tg-web-2"
        }
      ]
    }
  ]
}
```

## Notes
- Access logs require `access_logs.enabled=true` and a bucket with proper ACL/policy for ALB log delivery.
- HTTPS listeners require `certificate_arn` and a suitable `ssl_policy` (defaults provided).
- For multiple ALBs, use map outputs: `lb_dns_names["<alb-name>"]` and `lb_zone_ids["<alb-name>"]`.
