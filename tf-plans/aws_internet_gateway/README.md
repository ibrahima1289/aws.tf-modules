# TF Plan: AWS Internet Gateway

Wrapper plan that instantiates the `aws_internet_gateway` module. This plan parameterizes region, VPC, and tags, and passes them to the module. No data sources are used.

## Usage

```hcl
# provider.tf
provider "aws" {
  region = var.region
}

# main.tf
module "internet_gateway" {
  source = "../../modules/networking_content_delivery/aws_internet_gateway"

  region                 = var.region
  vpc_id                 = var.vpc_id
  enable_internet_gateway = true
  name                    = "app-igw"
  tags = {
    Environment = "dev"
  }
}

# variables.tf
variable "region" { type = string }
variable "vpc_id" { type = string }
```

## Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| region | string | Yes | n/a | AWS region to deploy resources in. |
| vpc_id | string | Conditionally | `null` | VPC ID to attach IGW to; required when `enable_internet_gateway` is `true`. |
| enable_internet_gateway | bool | No | `true` | Whether to create the IGW. |
| name | string | No | `null` | Optional `Name` tag value. |
| tags | map(string) | No | `{}` | Additional tags merged and forwarded to the module. |

## Outputs

| Name | Description |
|------|-------------|
| internet_gateway_id | ID of the created IGW |
| internet_gateway_arn | ARN of the created IGW |

## Notes
- The wrapper adds a `created_date` tag via `locals.tf`.
- No data sources are used in either the wrapper or the module.
