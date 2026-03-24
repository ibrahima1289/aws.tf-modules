# AWS Certificate Manager Terraform Module

Reusable Terraform module for AWS Certificate Manager (ACM) supporting multiple public, private CA-issued, and imported certificates with optional DNS validation resources.

## Architecture

```text
Terraform Module (aws_certificate_manager)
                 |
                 v
    +-----------------------------------------+
    | aws_acm_certificate                     |
    | - AMAZON_ISSUED  (auto-renews)          |
    | - PRIVATE_ISSUED (auto-renews via PCA)  |
    | - IMPORTED       (manual rotation)      |
    +-----------------------------------------+
                 |
                 v
    +------------------------------------------+
    | aws_acm_certificate_validation (optional)|
    | - DNS validation using FQDN records      |
    +------------------------------------------+
                 |
          certificate_arns output
                 |
       ┌─────────┴──────────┬──────────────────┐
       v                    v                  v
  +---------+   +--------------------+   +------------+
  |   ALB   |   |    CloudFront      |   | API Gateway|
  | HTTPS   |   | viewer_certificate |   | domain name|
  | listener|   +--------------------+   +------------+
  +---------+
```

## Input Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `region` | `string` | ✅ Yes | n/a | AWS region where ACM resources are managed |
| `tags` | `map(string)` | No | `{}` | Common tags applied to all ACM resources |
| `certificates` | `list(object)` | No | `[]` | List of ACM certificate definitions — see object fields below |

### `certificates` object fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | `string` | ✅ Yes | n/a | Unique identifier used as the `for_each` map key |
| `type` | `string` | No | `"AMAZON_ISSUED"` | Certificate type: `AMAZON_ISSUED`, `PRIVATE_ISSUED`, or `IMPORTED` |
| `domain_name` | `string` | ✅ `AMAZON_ISSUED` / `PRIVATE_ISSUED` | `""` | Primary domain name (FQDN) for the certificate |
| `certificate_authority_arn` | `string` | ✅ `PRIVATE_ISSUED` only | `""` | ARN of the ACM Private CA used to issue and renew the certificate |
| `validation_method` | `string` | No | `"DNS"` | Domain ownership validation method: `DNS` or `EMAIL` (`AMAZON_ISSUED` only) |
| `subject_alternative_names` | `list(string)` | No | `[]` | Additional domain names (SANs) to include in the certificate |
| `key_algorithm` | `string` | No | `"RSA_2048"` | Key algorithm: `RSA_2048`, `RSA_4096`, `EC_prime256v1`, `EC_secp384r1`, etc. |
| `certificate_transparency_logging_preference` | `string` | No | `""` | CT logging: `ENABLED`, `DISABLED`, or `""` (`AMAZON_ISSUED` only) |
| `certificate_body` | `string` | ✅ `IMPORTED` only | `""` | PEM-encoded certificate body |
| `private_key` | `string` | ✅ `IMPORTED` only | `""` | PEM-encoded private key matching the certificate |
| `certificate_chain` | `string` | No | `""` | PEM-encoded issuing CA certificate chain (`IMPORTED` only) |
| `validate_certificate` | `bool` | No | `false` | When `true`, creates an `aws_acm_certificate_validation` resource |
| `validation_record_fqdns` | `list(string)` | ✅ when `validate_certificate = true` | `[]` | DNS validation FQDNs supplied by your DNS provider after domain validation |
| `tags` | `map(string)` | No | `{}` | Resource-level tags merged with common `tags` and `created_date` |

## Outputs

| Name | Description |
|------|-------------|
| `certificate_arns` | Map of certificate key → ACM certificate ARN |
| `certificate_statuses` | Map of certificate key → ACM certificate status |
| `managed_certificate_domains` | Map of ACM-managed certificate key → primary domain |
| `validated_certificate_arns` | Map of certificate keys validated by Terraform |
| `auto_renewing_certificate_arns` | Map of certificates renewed automatically by ACM |

## Renewal and Rotation

| Certificate Type | Auto Renewal | Notes |
|------------------|-------------|-------|
| `AMAZON_ISSUED` | ✅ Yes | ACM renews eligible public certificates automatically 60 days before expiry |
| `PRIVATE_ISSUED` | ✅ Yes | ACM renews via Private CA automatically |
| `IMPORTED` | ❌ No | You must re-import a new cert before expiry — set a CloudWatch alarm on `DaysToExpiry` |

---

## Usage — Provision Certificates

```hcl
module "acm" {
  source = "../../modules/security_identity_compliance/aws_certificate_manager"

  region = var.region
  tags   = { environment = "production" }

  certificates = [
    {
      key                       = "api-example-com"
      type                      = "AMAZON_ISSUED"
      domain_name               = "api.example.com"
      validation_method         = "DNS"
      subject_alternative_names = ["www.example.com", "app.example.com"]
      key_algorithm             = "RSA_2048"
      validate_certificate      = false
      tags = { tier = "frontend" }
    },
    {
      key                       = "internal-service"
      type                      = "PRIVATE_ISSUED"
      domain_name               = "svc.internal.example.com"
      certificate_authority_arn = "arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/abc-123"
      subject_alternative_names = ["api.internal.example.com"]
      key_algorithm             = "RSA_2048"
    }
  ]
}
```

---

## Consuming the Certificate — Attach to AWS Resources

The module outputs a map of ARNs keyed by your `key` field:

```hcl
# Returns: { "api-example-com" = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123", ... }
output "certificate_arns" {
  value = module.acm.certificate_arns
}
```

### 1. Application Load Balancer — HTTPS Listener

> ⚠️ Certificate must be in the **same region** as the ALB.

```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  # Reference the cert by its key from the ACM module output map
  certificate_arn = module.acm.certificate_arns["api-example-com"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# Attach additional SAN certificates to the same listener
resource "aws_lb_listener_certificate" "extra" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = module.acm.certificate_arns["wildcard-example-com"]
}
```

### 2. CloudFront Distribution

> ⚠️ CloudFront **requires** the certificate to be in **`us-east-1`** regardless of your stack region.

```hcl
module "acm_us_east_1" {
  source = "../../modules/security_identity_compliance/aws_certificate_manager"

  # CloudFront certificates must always be in us-east-1
  region = "us-east-1"
  tags   = local.common_tags

  certificates = [{
    key              = "cdn-example-com"
    type             = "AMAZON_ISSUED"
    domain_name      = "cdn.example.com"
    validation_method = "DNS"
  }]
}

resource "aws_cloudfront_distribution" "cdn" {
  # ...existing code...

  viewer_certificate {
    acm_certificate_arn      = module.acm_us_east_1.certificate_arns["cdn-example-com"]
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
```

### 3. API Gateway — Custom Domain

```hcl
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.example.com"

  # Regional endpoint — cert must be in same region
  regional_certificate_arn = module.acm.certificate_arns["api-example-com"]

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
```

### 4. ECS / ALB — HTTPS Listener

```hcl
resource "aws_lb_listener" "ecs_https" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  # Resolve cert ARN dynamically from the ACM module — no hard-coded ARNs
  certificate_arn = module.acm.certificate_arns["api-example-com"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}
```

### 5. Cross-Module Wiring in a Shared tf-plan

```hcl
# ─── Step 1 — provision certificates ─────────────────────────────────────────
module "acm" {
  source       = "../../modules/security_identity_compliance/aws_certificate_manager"
  region       = var.region
  tags         = local.common_tags
  certificates = var.certificates
}

# ─── Step 2 — provision ALB, pass cert ARN from step 1 ───────────────────────
module "alb" {
  source = "../../modules/compute/aws_alb"
  region = var.region
  tags   = local.common_tags

  # Dynamically resolved — no hard-coded ARNs in tfvars
  https_certificate_arn = module.acm.certificate_arns["api-example-com"]
}
```

---

## Key Rules When Attaching Certificates

| Rule | Detail |
|------|--------|
| 🌍 **CloudFront region** | Certificate **must** be provisioned in `us-east-1` |
| 🌐 **ALB / API GW region** | Certificate must be in the **same region** as the resource |
| 📋 **Multiple SANs on ALB** | Use `aws_lb_listener_certificate` to attach extra certs to one listener |
| ⏳ **Validation must complete** | ACM cert must reach `ISSUED` state before attaching — use `depends_on` or `validate_certificate = true` |
| 🔄 **Imported cert rotation** | Set a [CloudWatch alarm](https://docs.aws.amazon.com/acm/latest/userguide/acm-certificate.html) on `DaysToExpiry` metric to alert before expiry |
| 🔑 **Key algorithm** | Use `EC_prime256v1` for better performance on modern clients |
