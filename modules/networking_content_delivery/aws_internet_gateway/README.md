# AWS Internet Gateway (Optional Module)

A minimal Terraform module to optionally create an Internet Gateway (IGW) and attach it to a given VPC. No data sources are used; all inputs are provided via variables.

## Usage

```hcl
module "internet_gateway" {
  source = "../../modules/networking_content_delivery/aws_internet_gateway"

  # Required
  region = var.region
  vpc_id = var.vpc_id

  # Optional
  enable_internet_gateway = true
  name                    = "app-igw"
  tags = {
    Environment = "dev"
  }
}
```

## Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| region | string | Yes | n/a | AWS region to deploy the IGW in. |
| vpc_id | string | Conditionally | `null` | VPC ID to attach to. Required when `enable_internet_gateway` is `true`. |
| enable_internet_gateway | bool | No | `true` | Whether to create the IGW. If `false`, no resources are created. |
| name | string | No | `null` | Optional `Name` tag value. |
| tags | map(string) | No | `{}` | Extra tags merged into the IGW. |

## Outputs

| Name | Description |
|------|-------------|
| internet_gateway_id | ID of the created IGW (or `null` if not created). |
| internet_gateway_arn | ARN of the created IGW (or `null` if not created). |

## Notes
- The module adds a `created_date` tag (ISO-8601) via `locals.tf`.
- No data sources are used.
- If `enable_internet_gateway` is `false`, no IGW is created.
