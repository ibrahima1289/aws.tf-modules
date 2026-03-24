# AWS Certificate Manager Wrapper Plan

Wrapper for [modules/security_identity_compliance/aws_certificate_manager](../../modules/security_identity_compliance/aws_certificate_manager/README.md) demonstrating safe, scalable multi-certificate usage.

## Architecture

```text
Terraform Wrapper (tf-plans/aws_certificate_manager)
                        |
                        v
      +-----------------------------------------+
    | aws_certificate_manager module           |
    | - public, private, imported certs        |
    | - optional DNS validation resources      |
    | - ACM-managed renewal for eligible certs |
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

## Rotation Notes

- `AMAZON_ISSUED` certificates renew automatically in ACM.
- `PRIVATE_ISSUED` certificates from ACM Private CA also support ACM-managed renewal.
- `IMPORTED` certificates do not auto-rotate; replace them manually during certificate rotation.

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
