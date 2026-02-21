# Example configuration for CloudFront distributions

region = "us-east-1"

tags = {
  Environment = "production"
  ManagedBy   = "Terraform"
}

distributions = {
  # S3 static website distribution with caching
  s3_website = {
    comment             = "CloudFront distribution for S3 static website"
    enabled             = true
    is_ipv6_enabled     = false
    http_version        = "http2"
    price_class         = "PriceClass_100" # North America and Europe
    wait_for_deployment = true

    # S3 origin configuration
    origins = [
      {
        origin_id   = "S3-my-website-bucket"
        domain_name = "my-website-bucket.s3.amazonaws.com"

        # S3 origin with Origin Access Identity
        s3_origin_config = {
          origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
        }
      }
    ]

    # Default cache behavior
    default_cache_behavior = {
      target_origin_id       = "S3-my-website-bucket"
      viewer_protocol_policy = "redirect-to-https"
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
      compress               = true

      # Use AWS managed cache policy (CachingOptimized)
      cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    }

    # Custom error responses for SPA (redirect 404 to index.html)
    custom_error_responses = [
      {
        error_code            = 404
        response_code         = 200
        response_page_path    = "/index.html"
        error_caching_min_ttl = 300
      },
      {
        error_code            = 403
        response_code         = 200
        response_page_path    = "/index.html"
        error_caching_min_ttl = 300
      }
    ]

    tags = {
      Purpose = "StaticWebsite"
    }
  }

  # # API origin with custom domain and ACM certificate
  # api_cdn = {
  #   comment         = "CloudFront distribution for API with custom domain"
  #   enabled         = true
  #   is_ipv6_enabled = true
  #   http_version    = "http2and3"
  #   price_class     = "PriceClass_All"
  #   aliases         = ["api.example.com"]

  #   # Custom origin (API Gateway or ALB)
  #   origins = [
  #     {
  #       origin_id   = "API-Gateway"
  #       domain_name = "abc123.execute-api.us-east-1.amazonaws.com"
  #       origin_path = "/prod"

  #       custom_origin_config = {
  #         http_port              = 80
  #         https_port             = 443
  #         origin_protocol_policy = "https-only"
  #         origin_ssl_protocols   = ["TLSv1.2"]
  #       }

  #       # Custom headers for origin authentication
  #       custom_headers = [
  #         {
  #           name  = "X-Custom-Header"
  #           value = "my-secret-value"
  #         }
  #       ]
  #     }
  #   ]

  #   # Default cache behavior with cache policy
  #   default_cache_behavior = {
  #     target_origin_id       = "API-Gateway"
  #     viewer_protocol_policy = "https-only"
  #     allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  #     cached_methods         = ["GET", "HEAD"]
  #     compress               = true

  #     # Use managed CachingDisabled policy for APIs
  #     cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  #     # Forward all headers/query strings to origin
  #     origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  #   }

  #   # ACM certificate for custom domain (must be in us-east-1)
  #   viewer_certificate = {
  #     acm_certificate_arn      = "arn:aws:acm:us-east-1:123456789012:certificate/abc123"
  #     ssl_support_method       = "sni-only"
  #     minimum_protocol_version = "TLSv1.2_2021"
  #   }

  #   tags = {
  #     Purpose = "API"
  #   }
  # }

  # # Multi-origin distribution with failover and path-based routing
  # multi_origin = {
  #   comment         = "CloudFront with multiple origins and failover"
  #   enabled         = true
  #   is_ipv6_enabled = true

  #   # Primary and secondary S3 origins for failover
  #   origins = [
  #     {
  #       origin_id   = "S3-Primary"
  #       domain_name = "primary-bucket.s3.amazonaws.com"

  #       s3_origin_config = {
  #         origin_access_identity = "origin-access-identity/cloudfront/PRIMARY123"
  #       }
  #     },
  #     {
  #       origin_id   = "S3-Secondary"
  #       domain_name = "secondary-bucket.s3.us-west-2.amazonaws.com"

  #       s3_origin_config = {
  #         origin_access_identity = "origin-access-identity/cloudfront/SECONDARY456"
  #       }
  #     },
  #     {
  #       origin_id   = "Custom-API"
  #       domain_name = "api.example.com"

  #       custom_origin_config = {
  #         origin_protocol_policy = "https-only"
  #         origin_ssl_protocols   = ["TLSv1.2"]
  #       }
  #     }
  #   ]

  #   # Origin group for S3 failover
  #   origin_groups = [
  #     {
  #       origin_id = "S3-Failover-Group"

  #       failover_criteria = {
  #         status_codes = [403, 404, 500, 502, 503, 504]
  #       }

  #       members = [
  #         { origin_id = "S3-Primary" },
  #         { origin_id = "S3-Secondary" }
  #       ]
  #     }
  #   ]

  #   # Default cache behavior uses failover group
  #   default_cache_behavior = {
  #     target_origin_id       = "S3-Failover-Group"
  #     viewer_protocol_policy = "redirect-to-https"
  #     allowed_methods        = ["GET", "HEAD"]
  #     cached_methods         = ["GET", "HEAD"]
  #     compress               = true

  #     cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  #   }

  #   # Path-based routing for API requests
  #   ordered_cache_behaviors = [
  #     {
  #       path_pattern           = "/api/*"
  #       target_origin_id       = "Custom-API"
  #       viewer_protocol_policy = "https-only"
  #       allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  #       cached_methods         = ["GET", "HEAD"]

  #       cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  #       origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
  #     }
  #   ]

  #   # Access logging to S3
  #   logging_config = {
  #     bucket          = "my-cloudfront-logs.s3.amazonaws.com"
  #     include_cookies = false
  #     prefix          = "cloudfront-logs/"
  #   }

  #   tags = {
  #     Purpose = "MultiOrigin"
  #   }
  # }

  # # Distribution with geographic restrictions and legacy cache settings
  # geo_restricted = {
  #   comment         = "CloudFront with geographic restrictions"
  #   enabled         = true
  #   is_ipv6_enabled = false

  #   origins = [
  #     {
  #       origin_id   = "Custom-Origin"
  #       domain_name = "origin.example.com"

  #       custom_origin_config = {
  #         origin_protocol_policy = "https-only"
  #         origin_ssl_protocols   = ["TLSv1.2"]
  #       }
  #     }
  #   ]

  #   # Default cache behavior with legacy forwarded_values
  #   default_cache_behavior = {
  #     target_origin_id       = "Custom-Origin"
  #     viewer_protocol_policy = "https-only"
  #     allowed_methods        = ["GET", "HEAD", "OPTIONS"]
  #     cached_methods         = ["GET", "HEAD", "OPTIONS"]
  #     compress               = true

  #     # Legacy cache settings (not using cache_policy_id)
  #     min_ttl     = 0
  #     default_ttl = 3600
  #     max_ttl     = 86400

  #     # Legacy forwarded values
  #     forwarded_values = {
  #       query_string = true
  #       headers      = ["Host", "Origin"]

  #       cookies = {
  #         forward = "none"
  #       }
  #     }
  #   }

  #   # Whitelist only US and Canada
  #   restrictions = {
  #     geo_restriction = {
  #       restriction_type = "whitelist"
  #       locations        = ["US", "CA"]
  #     }
  #   }

  #   tags = {
  #     Purpose = "GeoRestricted"
  #   }
  # }
}
