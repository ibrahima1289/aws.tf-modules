# AWS Certificate Manager Wrapper Plan

Wrapper for [modules/security_identity_compliance/aws_certificate_manager](../../modules/security_identity_compliance/aws_certificate_manager/README.md) demonstrating safe, scalable multi-certificate usage.

## Architecture

```text
Terraform Wrapper (tf-plans/aws_certificate_manager)
                        |
                        v
      +-----------------------------------------+
      | aws_certificate_manager module          |
      | - multiple public/imported certificates |
      | - optional DNS validation resources     |
      +-----------------------------------------+
                        |
                        v
               AWS Certificate Manager (ACM)
```

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region to deploy ACM resources |

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags for all resources |
| `certificates` | `list(object)` | `[]` | ACM certificate definitions for map-based scaling |

## Files

- `main.tf` — calls the reusable module
- `variables.tf` — wrapper inputs
- `locals.tf` — created date local
- `provider.tf` — provider and Terraform versions
- `terraform.tfvars` — example values for multiple certificates
- `outputs.tf` — module output pass-throughs

## Usage

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```
