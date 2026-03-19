# AWS NACL Wrapper Plan

Wrapper for [modules/security_identity_compliance/aws_nacl](../../modules/security_identity_compliance/aws_nacl/README.md) demonstrating safe, scalable multi-NACL usage.

## Architecture

```text
Terraform Wrapper (tf-plans/aws_nacl)
                |
                v
  +------------------------------------+
  | aws_nacl module                    |
  | - multiple NACLs (for_each)        |
  | - subnet associations              |
  | - ingress/egress IPv4/IPv6 rules   |
  +------------------------------------+
                |
                v
        VPC Subnets Protected by NACLs
```

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region to deploy resources |

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags for all resources |
| `nacls` | `list(object)` | `[]` | NACL definitions with subnet associations and rules |

## Files

- `main.tf` — calls the reusable module
- `variables.tf` — wrapper inputs
- `locals.tf` — created date local
- `provider.tf` — provider and Terraform versions
- `terraform.tfvars` — example values for multiple NACLs
- `outputs.tf` — module output pass-throughs

## Usage

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```
