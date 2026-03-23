# AWS Certificate Manager Terraform Module

Reusable Terraform module for AWS Certificate Manager (ACM) supporting multiple public and imported certificates with optional DNS validation resources.

## Architecture

```text
Terraform Module (aws_certificate_manager)
                 |
                 v
    +-----------------------------------------+
    | aws_acm_certificate                     |
    | - AMAZON_ISSUED certificates            |
    | - IMPORTED certificates                 |
    +-----------------------------------------+
                 |
                 v
    +------------------------------------------+
    | aws_acm_certificate_validation (optional)|
    | - DNS validation using FQDN records      |
    +------------------------------------------+
```

## Required Variables

| Name | Type | Description |
|------|------|-------------|
| `region` | `string` | AWS region where ACM resources are managed |

## Optional Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `tags` | `map(string)` | `{}` | Common tags for all ACM resources |
| `certificates` | `list(object)` | `[]` | List of ACM certificate definitions |

### `certificates` object fields

| Field | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `key` | `string` | Yes | n/a | Unique key for map-based scaling |
| `type` | `string` | No | `"AMAZON_ISSUED"` | `AMAZON_ISSUED` or `IMPORTED` |
| `domain_name` | `string` | Yes (for `AMAZON_ISSUED`) | `""` | Primary domain name |
| `validation_method` | `string` | No | `"DNS"` | `DNS` or `EMAIL` for `AMAZON_ISSUED` |
| `subject_alternative_names` | `list(string)` | No | `[]` | Subject alternative names |
| `key_algorithm` | `string` | No | `"RSA_2048"` | Public certificate key algorithm |
| `certificate_transparency_logging_preference` | `string` | No | `""` | `ENABLED`, `DISABLED`, or empty |
| `certificate_body` | `string` | Yes (for `IMPORTED`) | `""` | PEM certificate body |
| `private_key` | `string` | Yes (for `IMPORTED`) | `""` | PEM private key |
| `certificate_chain` | `string` | No | `""` | PEM certificate chain |
| `validate_certificate` | `bool` | No | `false` | Create ACM validation resource when true |
| `validation_record_fqdns` | `list(string)` | Conditionally | `[]` | Required when `validate_certificate = true` |
| `tags` | `map(string)` | No | `{}` | Certificate-specific tags |

## Outputs

| Name | Description |
|------|-------------|
| `certificate_arns` | Map of certificate key to ACM certificate ARN |
| `certificate_statuses` | Map of certificate key to ACM certificate status |
| `public_certificate_domains` | Map of public certificate key to primary domain |
| `validated_certificate_arns` | Map of certificate keys validated by Terraform |

## Usage

```hcl
module "acm" {
  source = "../../modules/security_identity_compliance/aws_certificate_manager"

  region = var.region
  tags   = { environment = "dev" }

  certificates = [
    {
      key                       = "web"
      type                      = "AMAZON_ISSUED"
      domain_name               = "example.com"
      validation_method         = "DNS"
      subject_alternative_names = ["www.example.com"]
      key_algorithm             = "RSA_2048"
      validate_certificate      = false
      tags = {
        tier = "frontend"
      }
    }
  ]
}
```
