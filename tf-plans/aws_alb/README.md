# AWS ALB Plan (Wrapper)

Composes the ALB root module with a simple set of variables and examples.

## Files
- `providers.tf`: AWS provider and version pins.
- `variables.tf`: Inputs to the plan.
- `main.tf`: Wires the plan variables to the ALB module.
- `terraform.tfvars`: Example variables for a quick apply.

## Inputs

| Name | Type | Required | Default | Description |
|------|------|---------:|---------|-------------|
| region | string | yes | - | AWS region |
| tags | map(string) | no | `{}` | Global tags |
| vpc_id | string | yes | - | VPC ID (for target groups) |
| subnet_ids | list(string) | yes | - | Subnet IDs for ALB |
| alb_security_group_ids | list(string) | no | `[]` | Security group IDs |
| lb_name | string | yes | - | Load balancer name |
| access_logs | object | no | `{ enabled=false }` | S3 logging `{ enabled, bucket?, prefix? }` |
| target_groups | list(object) | yes | - | Target groups declared (module injects `vpc_id`) |
| listeners | list(object) | yes | - | Listener definitions |
| albs | list(object) | no | `[]` | Optional: define multiple ALBs with nested target groups and listeners |

## Usage
```bash
terraform init
terraform plan -var-file="tf-plans/aws_alb/terraform.tfvars"
terraform apply -var-file="tf-plans/aws_alb/terraform.tfvars"
```

### Multi-ALB Example
Define `albs` in `terraform.tfvars` to create multiple ALBs. The plan injects `vpc_id` into each nested `target_groups` entry automatically.

```hcl
albs = [
	{
		name            = "demo-app-alb-1"
		subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
		security_groups = ["sg-1234567890abcdef0"]
		internal        = false
		access_logs     = { enabled = false }
		target_groups   = [ { name = "tg-web-1", port = 80, protocol = "HTTP" } ]
		listeners       = [ { port = 80, protocol = "HTTP", default_forward_target_group = "tg-web-1" } ]
	},
	{
		name            = "demo-app-alb-2"
		subnets         = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
		security_groups = ["sg-1234567890abcdef0"]
		internal        = true
		access_logs     = { enabled = true, bucket = "my-logs-bucket", prefix = "alb-2" }
		target_groups   = [ { name = "tg-web-2", port = 443, protocol = "HTTPS" } ]
		listeners       = [ {
			port                         = 443,
			protocol                     = "HTTPS",
			ssl_policy                   = "ELBSecurityPolicy-2016-08",
			certificate_arn              = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-efgh-ijkl",
			default_forward_target_group = "tg-web-2"
		} ]
	}
]
```

## Notes
- Supports both single-ALB and multi-ALB via `albs`. When `albs` is provided, single-ALB outputs may be null; use maps `lb_arns`, `lb_dns_names`, `lb_zone_ids`.
- Ensure your subnets support ALB (public for internet-facing, private for internal).
- If using HTTPS, ensure ACM certificate in the ALB region and supply `certificate_arn` on the listener.
- For Route53 aliases with multiple ALBs, use `lb_dns_names["<alb-name>"]` and `lb_zone_ids["<alb-name>"]`.
