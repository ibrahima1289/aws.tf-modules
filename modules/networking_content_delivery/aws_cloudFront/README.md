# AWS CloudFront Terraform Module

This module provisions AWS CloudFront distributions for content delivery with support for multiple origins, cache behaviors, SSL certificates, and advanced features like origin failover, Lambda@Edge, and geographic restrictions.

## Requirements
- Terraform >= 1.3
- AWS Provider >= 5.0

## Features
- Create multiple CloudFront distributions via a keyed map
- Support for S3 and custom origins (HTTP/HTTPS)
- Origin groups for automatic failover
- Path-based routing with ordered cache behaviors
- Modern cache policies and legacy forwarded values
- SSL/TLS certificates (ACM, IAM, or default CloudFront certificate)
- Custom error responses for SPAs and error handling
- Access logging to S3
- Geographic restrictions (whitelist/blacklist)
- Lambda@Edge and CloudFront Functions
- Origin Shield for improved cache hit ratio
- Global and per-distribution tags, including `CreatedDate`

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region for the provider |
| tags | map(string) | no | Global tags applied to all distributions |
| distributions | map(object) | no | Map of CloudFront distributions; see schema below |

### `distributions` object schema
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| comment | string | yes | - | Description for the distribution |
| enabled | bool | yes | - | Whether the distribution is enabled |
| is_ipv6_enabled | bool | no | `true` | Enable IPv6 support |
| http_version | string | no | `http2` | `http1.1`, `http2`, `http2and3`, `http3` |
| price_class | string | no | `PriceClass_100` | Price class for edge locations |
| retain_on_delete | bool | no | `false` | Retain distribution on Terraform destroy |
| wait_for_deployment | bool | no | `true` | Wait for deployment to complete |
| web_acl_id | string | no | `null` | AWS WAF web ACL ID |
| aliases | list(string) | no | `[]` | Alternate domain names (CNAMEs) |
| origins | list(object) | yes | - | Origin configurations (see below) |
| default_cache_behavior | object | yes | - | Default cache behavior (see below) |
| ordered_cache_behaviors | list(object) | no | `[]` | Path-specific cache behaviors |
| custom_error_responses | list(object) | no | `[]` | Custom error page configurations |
| viewer_certificate | object | no | CloudFront default | SSL/TLS certificate config |
| logging_config | object | no | `null` | Access logging to S3 |
| restrictions | object | no | No restrictions | Geographic restrictions |
| origin_groups | list(object) | no | `[]` | Origin groups for failover |
| tags | map(string) | no | `{}` | Per-distribution tags |

### `origins` nested object
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| origin_id | string | yes | - | Unique identifier for the origin |
| domain_name | string | yes | - | S3 bucket or custom domain |
| origin_path | string | no | `null` | Path prefix for requests |
| connection_attempts | number | no | `null` | Connection attempts (1-3) |
| connection_timeout | number | no | `null` | Timeout in seconds (1-10) |
| custom_headers | list(object) | no | `null` | Custom headers for origin requests |
| s3_origin_config | object | no | `null` | S3 origin configuration (OAI) |
| custom_origin_config | object | no | `null` | Custom origin configuration |
| origin_shield | object | no | `null` | Origin Shield configuration |

#### `s3_origin_config` nested object
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| origin_access_identity | string | yes | CloudFront OAI path (e.g., `origin-access-identity/cloudfront/ABC123`) |

#### `custom_origin_config` nested object
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| http_port | number | no | `80` | HTTP port |
| https_port | number | no | `443` | HTTPS port |
| origin_protocol_policy | string | yes | - | `http-only`, `https-only`, `match-viewer` |
| origin_ssl_protocols | list(string) | yes | - | `TLSv1`, `TLSv1.1`, `TLSv1.2`, `SSLv3` |
| origin_keepalive_timeout | number | no | `null` | Keepalive timeout (1-60 seconds) |
| origin_read_timeout | number | no | `null` | Read timeout (1-60 seconds) |

### `default_cache_behavior` object schema
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| target_origin_id | string | yes | - | Origin ID to route requests to |
| viewer_protocol_policy | string | yes | - | `allow-all`, `https-only`, `redirect-to-https` |
| allowed_methods | list(string) | yes | - | HTTP methods allowed |
| cached_methods | list(string) | yes | - | HTTP methods to cache |
| compress | bool | no | `null` | Enable gzip compression |
| cache_policy_id | string | no | `null` | Managed or custom cache policy ID (recommended) |
| origin_request_policy_id | string | no | `null` | Origin request policy ID |
| response_headers_policy_id | string | no | `null` | Response headers policy ID |
| min_ttl | number | no | `null` | Minimum TTL (legacy, use cache_policy_id) |
| default_ttl | number | no | `null` | Default TTL (legacy) |
| max_ttl | number | no | `null` | Maximum TTL (legacy) |
| forwarded_values | object | no | `null` | Legacy forwarding config (avoid if using cache_policy_id) |

### `viewer_certificate` object schema
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| acm_certificate_arn | string | no | `null` | ACM certificate ARN (must be in us-east-1) |
| iam_certificate_id | string | no | `null` | IAM certificate ID |
| cloudfront_default_certificate | bool | no | `null` | Use default *.cloudfront.net cert |
| minimum_protocol_version | string | no | `null` | Minimum TLS version |
| ssl_support_method | string | no | `null` | `sni-only`, `vip`, `static-ip` |

## Outputs
- `distribution_ids`: Map of distribution key -> CloudFront distribution ID
- `distribution_arns`: Map of distribution key -> ARN
- `distribution_domain_names`: Map of distribution key -> CloudFront domain (e.g., d111111abcdef8.cloudfront.net)
- `distribution_hosted_zone_ids`: Map of distribution key -> Route 53 zone ID (for alias records)
- `distribution_statuses`: Map of distribution key -> deployment status
- `distribution_etags`: Map of distribution key -> ETag

## Usage
```hcl
module "cloudfront" {
  source = "../../modules/networking_content_delivery/aws_cloudFront"
  region = var.region
  tags   = { Environment = "production" }

  distributions = {
    website = {
      comment = "My website CDN"
      enabled = true
      aliases = ["www.example.com"]

      origins = [
        {
          origin_id   = "S3-Website"
          domain_name = "my-bucket.s3.amazonaws.com"
          
          s3_origin_config = {
            origin_access_identity = "origin-access-identity/cloudfront/ABC123"
          }
        }
      ]

      default_cache_behavior = {
        target_origin_id       = "S3-Website"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS"]
        cached_methods         = ["GET", "HEAD"]
        compress               = true
        
        # Use AWS managed CachingOptimized policy
        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
      }

      viewer_certificate = {
        acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"
        ssl_support_method       = "sni-only"
        minimum_protocol_version = "TLSv1.2_2021"
      }
    }
  }
}
```

## Notes
- **ACM Certificates**: For custom domains, ACM certificates must be created in the `us-east-1` region
- **Origin Access Identity (OAI)**: Required for S3 origins to restrict direct bucket access
- **Cache Policies**: Use AWS managed cache policies (recommended) or create custom policies
  - `658327ea-f89d-4fab-a63d-7e88639e58f6`: CachingOptimized
  - `4135ea2d-6df8-44a3-9df3-4b5a84be39ad`: CachingDisabled (for APIs)
  - `b2884449-e4de-46a7-ac36-70bc7f1ddd6d`: CachingOptimizedForUncompressedObjects
- **Price Classes**:
  - `PriceClass_All`: All edge locations (best performance, highest cost)
  - `PriceClass_200`: Most edge locations (excludes South America, Australia, New Zealand)
  - `PriceClass_100`: North America and Europe only (lowest cost)
- **Deployment Time**: CloudFront distributions take 15-20 minutes to deploy/update
- **Lambda@Edge**: Functions must be in `us-east-1` and use versioned ARNs

## Common Patterns

### S3 Static Website with SPA Support
```hcl
custom_error_responses = [
  {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
]
```

### Multi-Origin with Failover
```hcl
origin_groups = [
  {
    origin_id = "S3-Failover"
    failover_criteria = {
      status_codes = [403, 404, 500, 502, 503, 504]
    }
    members = [
      { origin_id = "Primary" },
      { origin_id = "Secondary" }
    ]
  }
]
```

### Path-Based Routing
```hcl
ordered_cache_behaviors = [
  {
    path_pattern    = "/api/*"
    target_origin_id = "API-Origin"
    # ... other settings
  }
]
```

## Examples
See [tf-plans/aws_cloudfront](../../tf-plans/aws_cloudfront/README.md) for complete wrapper examples with `terraform.tfvars`.
