# AWS CloudFront Wrapper (Examples)

This plan demonstrates using the AWS CloudFront module to provision content delivery networks for S3 static websites, APIs, and multi-origin configurations with failover.

## Files
- provider.tf: Providers (AWS)
- variables.tf: Plan inputs (region, tags, distributions)
- main.tf: Wires inputs to the module
- outputs.tf: Exposes module outputs
- terraform.tfvars: Example configuration

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region (use us-east-1 for global CloudFront) |
| tags | map(string) | no | Global tags |
| distributions | map(object) | no | CloudFront distributions to create (see module README) |

### Quick Reference

**Origin Types:**
- **S3**: Static content, requires Origin Access Identity (OAI)
- **Custom**: APIs, load balancers, custom HTTP/HTTPS servers

**Cache Policies (Managed):**
- `658327ea-f89d-4fab-a63d-7e88639e58f6`: CachingOptimized (static content)
- `4135ea2d-6df8-44a3-9df3-4b5a84be39ad`: CachingDisabled (APIs)
- `b2884449-e4de-46a7-ac36-70bc7f1ddd6d`: CachingOptimizedForUncompressedObjects

**Price Classes:**
- `PriceClass_100`: North America and Europe (lowest cost)
- `PriceClass_200`: Most locations (excludes South America, AU/NZ)
- `PriceClass_All`: All edge locations (best performance)

**Viewer Protocol Policies:**
- `allow-all`: HTTP and HTTPS allowed
- `redirect-to-https`: Redirect HTTP to HTTPS
- `https-only`: Only HTTPS allowed

## Example tfvars
```hcl
region = "us-east-1"

distributions = {
  website = {
    comment = "My S3 static website"
    enabled = true

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
      
      cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }

    # SPA support (redirect 404 to index.html)
    custom_error_responses = [
      {
        error_code         = 404
        response_code      = 200
        response_page_path = "/index.html"
      }
    ]
  }
}
```

## Usage
1. **Create Origin Access Identity** (for S3 origins):
   ```sh
   aws cloudfront create-cloud-front-origin-access-identity \
     --cloud-front-origin-access-identity-config \
     "CallerReference=$(date +%s),Comment=My OAI"
   ```
   Update S3 bucket policy to allow OAI access.

2. **Create ACM Certificate** (for custom domains, in us-east-1):
   ```sh
   aws acm request-certificate --region us-east-1 \
     --domain-name example.com \
     --subject-alternative-names www.example.com \
     --validation-method DNS
   ```

3. **Customize `terraform.tfvars`** with your origins, domains, and cache settings

4. **Initialize and apply**:
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```

5. **Wait for deployment**: CloudFront distributions take 15-20 minutes to deploy

6. **Update DNS**: Create Route 53 alias record pointing to CloudFront domain

## Common Patterns

### S3 Static Website with Custom Domain
```hcl
distributions = {
  website = {
    comment = "Static website CDN"
    enabled = true
    aliases = ["www.example.com"]

    origins = [{
      origin_id   = "S3-Website"
      domain_name = "my-bucket.s3.amazonaws.com"
      s3_origin_config = {
        origin_access_identity = "origin-access-identity/cloudfront/ABC123"
      }
    }]

    default_cache_behavior = {
      target_origin_id       = "S3-Website"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }

    viewer_certificate = {
      acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abc"
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }

    # SPA support
    custom_error_responses = [{
      error_code         = 404
      response_code      = 200
      response_page_path = "/index.html"
    }]
  }
}
```

### API Distribution (No Caching)
```hcl
distributions = {
  api = {
    comment = "API CDN"
    enabled = true
    aliases = ["api.example.com"]

    origins = [{
      origin_id   = "API-Gateway"
      domain_name = "abc123.execute-api.us-east-1.amazonaws.com"
      origin_path = "/prod"
      
      custom_origin_config = {
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }]

    default_cache_behavior = {
      target_origin_id       = "API-Gateway"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      
      # CachingDisabled for APIs
      cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
      origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AllViewer
    }

    viewer_certificate = {
      acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abc"
      ssl_support_method       = "sni-only"
      minimum_protocol_version = "TLSv1.2_2021"
    }
  }
}
```

### Multi-Origin with Failover
```hcl
distributions = {
  multi = {
    comment = "Multi-origin with failover"
    enabled = true

    origins = [
      {
        origin_id   = "Primary"
        domain_name = "primary.s3.amazonaws.com"
        s3_origin_config = {
          origin_access_identity = "origin-access-identity/cloudfront/PRIMARY"
        }
      },
      {
        origin_id   = "Secondary"
        domain_name = "secondary.s3.us-west-2.amazonaws.com"
        s3_origin_config = {
          origin_access_identity = "origin-access-identity/cloudfront/SECONDARY"
        }
      }
    ]

    origin_groups = [{
      origin_id = "S3-Failover"
      failover_criteria = {
        status_codes = [403, 404, 500, 502, 503, 504]
      }
      members = [
        { origin_id = "Primary" },
        { origin_id = "Secondary" }
      ]
    }]

    default_cache_behavior = {
      target_origin_id       = "S3-Failover"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }
  }
}
```

### Path-Based Routing
```hcl
distributions = {
  hybrid = {
    comment = "Static site + API"
    enabled = true

    origins = [
      {
        origin_id   = "S3-Static"
        domain_name = "static.s3.amazonaws.com"
        s3_origin_config = {
          origin_access_identity = "origin-access-identity/cloudfront/STATIC"
        }
      },
      {
        origin_id   = "API"
        domain_name = "api.example.com"
        custom_origin_config = {
          origin_protocol_policy = "https-only"
          origin_ssl_protocols   = ["TLSv1.2"]
        }
      }
    ]

    # Default: serve static content
    default_cache_behavior = {
      target_origin_id       = "S3-Static"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true
      cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }

    # /api/* requests go to API origin
    ordered_cache_behaviors = [{
      path_pattern           = "/api/*"
      target_origin_id       = "API"
      viewer_protocol_policy = "https-only"
      allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods         = ["GET", "HEAD"]
      cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    }]
  }
}
```

## Required Resources
- **S3 Bucket** (for S3 origins)
- **Origin Access Identity** (for S3 bucket access)
- **ACM Certificate** (for custom domains, must be in us-east-1)
- **Route 53 Hosted Zone** (for DNS records)
- **WAF Web ACL** (optional, for security rules)

## Notes
- **Deployment Time**: 15-20 minutes for initial deployment and updates
- **Cache Invalidation**: Use AWS CLI to invalidate cached content:
  ```sh
  aws cloudfront create-invalidation \
    --distribution-id E123456789ABC \
    --paths "/*"
  ```
- **Monitoring**: View CloudFront metrics in CloudWatch (requests, bytes, error rates)
- **Costs**: Based on data transfer and requests; use price classes to optimize
