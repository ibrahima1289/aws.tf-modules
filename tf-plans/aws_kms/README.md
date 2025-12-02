# AWS KMS Module Wrapper Plan

This plan wraps the `modules/security_identity_compliance/aws_kms` module to demonstrate usage.

## Files
- `main.tf`: Invokes the module.
- `variables.tf`: Declares wrapper variables.
- `provider.tf`: AWS provider config.
- `terraform.tfvars`: Example variable values.
- `outputs.tf`: Exposes module outputs.

## Usage
```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```
