# AWS Gateway Load Balancer (GWLB) Terraform Module

Creates GWLBs with target groups and listeners. Applies safe defaults, avoids null values, and adds a created date tag.

## Requirements
- Terraform >= 1.3
- AWS Provider >= 5.0

## Inputs

| Name | Type | Required | Default | Description |
|------|------|---------:|---------|-------------|
| region | string | yes | - | AWS region |
| tags | map(string) | no | `{}` | Global tags applied to all resources |
| glb_name | string | no | `null` | Single GWLB name (optional when not using `glbs`) |
| subnets | list(string) | no | `[]` | Subnet IDs for the GWLB (single mode) |
| internal | bool | no | `false` | Internal vs internet-facing |
| enable_deletion_protection | bool | no | `true` | Prevent accidental deletion |
| access_logs | object | no | `{ enabled=false }` | S3 logs: `{ enabled, bucket?, prefix? }` |
| target_groups | list(object) | no | `[]` | Target groups (single mode) with TCP health checks |
| listeners | list(object) | no | `[]` | Listeners (single mode), default forward target group |
| glbs | list(object) | no | `[]` | Optional: define multiple GWLBs with nested target groups and listeners |

### `target_groups` schema (single or inside `glbs`)
- `name` (string, required)
- `vpc_id` (string, required)
- `port` (number, required)
- `protocol` (string, required) — `GENEVE` (typically 6081)
- `target_type` (string, optional) — `ip` (default) or `instance`
- `health_check` (object, optional): `enabled?`, `port?`, `protocol?` (TCP), `interval?`, `timeout?`, `healthy_threshold?`, `unhealthy_threshold?`
- `tags` (map(string), optional)

### `listeners` schema (single or inside `glbs`)
- `port` (number, required)
- `protocol` (string, required) — `GENEVE`
- `default_forward_target_group` (string, required) — target group name

## Outputs
- `lb_arns` (map of GWLB name → ARN)
- `lb_dns_names` (map of GWLB name → DNS name)
- `lb_zone_ids` (map of GWLB name → Hosted Zone ID)
- `target_group_arns` (map of `<glb_name>:<tg_name>` → TG ARN)
- `listener_arns` (map of `<glb_name>:<port>` → listener ARN)

## Usage (Multi-GLB)
```hcl
module "aws_glb" {
  source = "../../modules/compute/aws_elb/aws_glb"

  region = var.region
  tags   = { Environment = "dev" }

  glbs = [
    {
      name            = "gwlb-1"
      subnets         = var.subnet_ids
      internal        = true
      access_logs     = { enabled = false }
      target_groups   = [ { name = "tg-1", vpc_id = var.vpc_id, port = 6081, protocol = "GENEVE" } ]
      listeners       = [ { port = 6081, protocol = "GENEVE", default_forward_target_group = "tg-1" } ]
    }
  ]
}
```

## Notes
- Gateway Load Balancers forward traffic via GENEVE encapsulation (port 6081).
- Health checks for GWLB target groups support TCP only.
- For multiple GWLBs, use map outputs: `lb_dns_names["<glb-name>"]` and `lb_zone_ids["<glb-name>"]`.
