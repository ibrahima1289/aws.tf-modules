# AWS GWLB Plan (Wrapper)

Composes the GWLB root module with a simple set of variables and examples.

## Files
- `providers.tf`: AWS provider and version pins.
- `variables.tf`: Inputs to the plan.
- `main.tf`: Wires the plan variables to the GWLB module.
- `outputs.tf`: Pass-through outputs.
- `terraform.tfvars`: Example variables for a quick apply.

## Inputs

| Name | Type | Required | Default | Description |
|------|------|---------:|---------|-------------|
| region | string | yes | - | AWS region |
| tags | map(string) | no | `{}` | Global tags |
| vpc_id | string | yes | - | VPC ID (for target groups) |
| subnet_ids | list(string) | yes | - | Subnet IDs for GWLB |
| glb_name | string | no | `null` | Single GWLB name (optional when not using `glbs`) |
| access_logs | object | no | `{ enabled=false }` | S3 logging `{ enabled, bucket?, prefix? }` |
| target_groups | list(object) | no | `[]` | Target groups declared (plan injects `vpc_id`) |
| listeners | list(object) | no | `[]` | Listener definitions |
| glbs | list(object) | no | `[]` | Optional: define multiple GWLBs with nested target groups and listeners |

## Usage
```bash
terraform init
terraform plan -var-file="tf-plans/aws_glb/terraform.tfvars"
terraform apply -var-file="tf-plans/aws_glb/terraform.tfvars"
```

### Multi-GLB Example
Define `glbs` in `terraform.tfvars` to create multiple GWLBs. The plan injects `vpc_id` into each nested `target_groups` entry automatically.

```hcl
glbs = [
  {
    name            = "gwlb-1"
    subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    internal        = true
    access_logs     = { enabled = false }
    target_groups   = [ { name = "tg-1", port = 6081, protocol = "GENEVE" } ]
    listeners       = [ { port = 6081, protocol = "GENEVE", default_forward_target_group = "tg-1" } ]
  },
  {
    name            = "gwlb-2"
    subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    internal        = true
    access_logs     = { enabled = true, bucket = "my-logs-bucket", prefix = "gwlb-2" }
    target_groups   = [ { name = "tg-2", port = 6081, protocol = "GENEVE" } ]
    listeners       = [ { port = 6081, protocol = "GENEVE", default_forward_target_group = "tg-2" } ]
  }
]
```

## Notes
- Gateway Load Balancers forward traffic via GENEVE encapsulation (port 6081).
- Health checks for GWLB target groups support TCP.
- For multiple GWLBs, use map outputs: `lb_dns_names["<glb-name>"]` and `lb_zone_ids["<glb-name>"]`.
