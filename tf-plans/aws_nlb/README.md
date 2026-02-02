# AWS NLB Plan (Wrapper)

Composes the NLB root module with a simple set of variables and examples.

## Files
- `providers.tf`: AWS provider and version pins.
- `variables.tf`: Inputs to the plan.
- `main.tf`: Wires the plan variables to the NLB module.
- `outputs.tf`: Pass-through outputs.
- `terraform.tfvars`: Example variables for a quick apply.

## Inputs

| Name | Type | Required | Default | Description |
|------|------|---------:|---------|-------------|
| region | string | yes | - | AWS region |
| tags | map(string) | no | `{}` | Global tags |
| vpc_id | string | yes | - | VPC ID (for target groups) |
| subnet_ids | list(string) | yes | - | Subnet IDs for NLB |
| nlb_name | string | no | `null` | Single NLB name (optional when not using `nlbs`) |
| cross_zone_load_balancing | bool | no | `true` | Enable cross-zone load balancing (single mode) |
| access_logs | object | no | `{ enabled=false }` | S3 logging `{ enabled, bucket?, prefix? }` |
| target_groups | list(object) | no | `[]` | Target groups declared (plan injects `vpc_id`) |
| listeners | list(object) | no | `[]` | Listener definitions |
| nlbs | list(object) | no | `[]` | Optional: define multiple NLBs with nested target groups and listeners |

## Usage
```bash
terraform init
terraform plan -var-file="tf-plans/aws_nlb/terraform.tfvars"
terraform apply -var-file="tf-plans/aws_nlb/terraform.tfvars"
```

### Multi-NLB Example
Define `nlbs` in `terraform.tfvars` to create multiple NLBs. The plan injects `vpc_id` into each nested `target_groups` entry automatically.

```hcl
nlbs = [
  {
    name            = "nlb-1"
    cross_zone_load_balancing = true
    subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    internal        = false
    access_logs     = { enabled = false }
    target_groups   = [ { name = "tg-1", port = 80, protocol = "TCP" } ]
    listeners       = [ { port = 80, protocol = "TCP", default_forward_target_group = "tg-1" } ]
  },
  {
    name            = "nlb-2"
    cross_zone_load_balancing = true
    subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    internal        = true
    access_logs     = { enabled = true, bucket = "my-logs-bucket", prefix = "nlb-2" }
    target_groups   = [ { name = "tg-2", port = 443, protocol = "TLS" } ]
    listeners       = [ {
      port                         = 443,
      protocol                     = "TLS",
      ssl_policy                   = "ELBSecurityPolicy-TLS13-1-2-2021-06",
      certificate_arn              = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-efgh-ijkl",
      default_forward_target_group = "tg-2"
    } ]
  }
]
```

## Notes
- Supports both single-NLB and multi-NLB via `nlbs`.
- Ensure your subnets are appropriate (public/private) based on `internal` setting.
- For Route53 aliases with multiple NLBs, use `lb_dns_names["<nlb-name>"]` and `lb_zone_ids["<nlb-name>"]`.
