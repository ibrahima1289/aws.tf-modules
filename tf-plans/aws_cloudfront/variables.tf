# Input variables for the CloudFront wrapper

# AWS region for the provider
variable "region" {
  type        = string
  description = "AWS region for the provider"
}

# Global tags applied across all resources
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Global tags applied to all CloudFront distributions"
}

# CloudFront distributions configuration (pass-through to module)
variable "distributions" {
  type = map(object({
    comment             = string                 # Description for the distribution
    enabled             = bool                   # Whether the distribution is enabled
    is_ipv6_enabled     = optional(bool)         # Enable IPv6 support (default true)
    http_version        = optional(string)       # HTTP version (http1.1, http2, http2and3, http3; default http2)
    price_class         = optional(string)       # PriceClass_All, PriceClass_200, PriceClass_100 (North America and Europe)
    retain_on_delete    = optional(bool)         # Retain distribution on delete (default false)
    wait_for_deployment = optional(bool)         # Wait for deployment to complete (default true)
    web_acl_id          = optional(string)       # AWS WAF web ACL ID to associate with the distribution
    aliases             = optional(list(string)) # CNAMEs to associate with the distribution

    # Origins define where CloudFront gets content
    origins = list(object({
      origin_id           = string           # Unique identifier for the origin
      domain_name         = string           # S3 bucket or custom origin domain
      origin_path         = optional(string) # Path to prepend to requests
      connection_attempts = optional(number) # Number of connection attempts (1-3)
      connection_timeout  = optional(number) # Connection timeout in seconds (1-10)

      # Custom headers to add to origin requests
      custom_headers = optional(list(object({
        name  = string # Header name
        value = string # Header value
      })))

      # S3 origin configuration (use for S3 buckets)
      s3_origin_config = optional(object({
        origin_access_identity = string # CloudFront OAI path
      }))

      # Custom origin configuration (use for non-S3 origins)
      custom_origin_config = optional(object({
        http_port                = optional(number) # HTTP port (default 80)
        https_port               = optional(number) # HTTPS port (default 443)
        origin_protocol_policy   = string           # http-only, https-only, match-viewer
        origin_ssl_protocols     = list(string)     # TLSv1, TLSv1.1, TLSv1.2, SSLv3
        origin_keepalive_timeout = optional(number) # Keepalive timeout (1-60 seconds)
        origin_read_timeout      = optional(number) # Read timeout (1-60 seconds)
      }))

      # Origin Shield (additional caching layer)
      origin_shield = optional(object({
        enabled              = bool   # Enable Origin Shield
        origin_shield_region = string # AWS region for Origin Shield
      }))
    }))

    # Default cache behavior (applies to all requests not matched by ordered behaviors)
    default_cache_behavior = object({
      target_origin_id           = string           # Origin ID to route requests to
      viewer_protocol_policy     = string           # allow-all, https-only, redirect-to-https
      allowed_methods            = list(string)     # HTTP methods allowed (GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE)
      cached_methods             = list(string)     # HTTP methods to cache (GET, HEAD, OPTIONS)
      compress                   = optional(bool)   # Enable gzip compression
      smooth_streaming           = optional(bool)   # Enable smooth streaming
      field_level_encryption_id  = optional(string) # Field-level encryption configuration ID
      realtime_log_config_arn    = optional(string) # Real-time log configuration ARN
      cache_policy_id            = optional(string) # Managed or custom cache policy ID (recommended)
      origin_request_policy_id   = optional(string) # Origin request policy ID
      response_headers_policy_id = optional(string) # Response headers policy ID

      # Legacy TTL settings (use cache_policy_id instead when possible)
      min_ttl     = optional(number) # Minimum TTL in seconds
      default_ttl = optional(number) # Default TTL in seconds
      max_ttl     = optional(number) # Maximum TTL in seconds

      # Legacy forwarded values (avoid if using cache_policy_id)
      forwarded_values = optional(object({
        query_string            = bool                   # Forward query strings
        headers                 = optional(list(string)) # Headers to forward to origin
        query_string_cache_keys = optional(list(string)) # Query string parameters to include in cache key

        # Cookie forwarding configuration
        cookies = object({
          forward           = string                 # none, whitelist, all
          whitelisted_names = optional(list(string)) # Cookie names to forward (if forward=whitelist)
        })
      }))

      # Trusted signers for signed URLs/cookies
      trusted_signers    = optional(list(string)) # AWS account IDs allowed to create signed URLs
      trusted_key_groups = optional(list(string)) # CloudFront key group IDs for signed URLs

      # Lambda@Edge function associations
      lambda_function_associations = optional(list(object({
        event_type   = string         # viewer-request, origin-request, viewer-response, origin-response
        lambda_arn   = string         # Lambda function ARN (must be versioned)
        include_body = optional(bool) # Include request body in function input
      })))

      # CloudFront Functions associations
      function_associations = optional(list(object({
        event_type   = string # viewer-request, viewer-response
        function_arn = string # CloudFront Function ARN
      })))
    })

    # Ordered cache behaviors (path-specific caching rules)
    ordered_cache_behaviors = optional(list(object({
      path_pattern               = string           # Path pattern (e.g., /api/*, *.jpg)
      target_origin_id           = string           # Origin ID to route matching requests to
      viewer_protocol_policy     = string           # allow-all, https-only, redirect-to-https
      allowed_methods            = list(string)     # HTTP methods allowed
      cached_methods             = list(string)     # HTTP methods to cache
      compress                   = optional(bool)   # Enable gzip compression
      smooth_streaming           = optional(bool)   # Enable smooth streaming
      field_level_encryption_id  = optional(string) # Field-level encryption configuration ID
      realtime_log_config_arn    = optional(string) # Real-time log configuration ARN
      cache_policy_id            = optional(string) # Managed or custom cache policy ID
      origin_request_policy_id   = optional(string) # Origin request policy ID
      response_headers_policy_id = optional(string) # Response headers policy ID

      # Legacy TTL settings
      min_ttl     = optional(number) # Minimum TTL in seconds
      default_ttl = optional(number) # Default TTL in seconds
      max_ttl     = optional(number) # Maximum TTL in seconds

      # Legacy forwarded values
      forwarded_values = optional(object({
        query_string            = bool                   # Forward query strings
        headers                 = optional(list(string)) # Headers to forward
        query_string_cache_keys = optional(list(string)) # Query string cache keys

        # Cookie forwarding
        cookies = object({
          forward           = string                 # none, whitelist, all
          whitelisted_names = optional(list(string)) # Cookie names to forward
        })
      }))

      # Trusted signers
      trusted_signers    = optional(list(string)) # AWS account IDs for signed URLs
      trusted_key_groups = optional(list(string)) # Key group IDs for signed URLs

      # Lambda@Edge associations
      lambda_function_associations = optional(list(object({
        event_type   = string         # Event type
        lambda_arn   = string         # Lambda ARN
        include_body = optional(bool) # Include request body
      })))

      # CloudFront Functions associations
      function_associations = optional(list(object({
        event_type   = string # Event type
        function_arn = string # Function ARN
      })))
    })))

    # Custom error responses for handling HTTP errors
    custom_error_responses = optional(list(object({
      error_code            = number           # HTTP error code (400-599)
      response_code         = optional(number) # Custom response code to return
      response_page_path    = optional(string) # Path to custom error page
      error_caching_min_ttl = optional(number) # Minimum TTL for error caching in seconds
    })))

    # Viewer certificate configuration (SSL/TLS)
    viewer_certificate = optional(object({
      acm_certificate_arn            = optional(string) # ACM certificate ARN (must be in us-east-1)
      iam_certificate_id             = optional(string) # IAM certificate ID
      cloudfront_default_certificate = optional(bool)   # Use default *.cloudfront.net cert
      minimum_protocol_version       = optional(string) # Minimum TLS version (TLSv1, TLSv1.2_2021, etc.)
      ssl_support_method             = optional(string) # sni-only, vip, static-ip
    }))

    # Logging configuration (access logs to S3)
    logging_config = optional(object({
      bucket          = string           # S3 bucket for logs (must end in .s3.amazonaws.com)
      include_cookies = optional(bool)   # Include cookies in logs
      prefix          = optional(string) # Log file prefix
    }))

    # Geographic restrictions (geo-blocking)
    restrictions = optional(object({
      geo_restriction = object({
        restriction_type = string                 # whitelist, blacklist, none
        locations        = optional(list(string)) # ISO 3166-1-alpha-2 country codes
      })
    }))

    # Origin groups for failover
    origin_groups = optional(list(object({
      origin_id = string # Unique ID for the origin group

      # Failover criteria (HTTP status codes that trigger failover)
      failover_criteria = object({
        status_codes = list(number) # HTTP status codes (e.g., [403, 404, 500, 502, 503, 504])
      })

      # Member origins (primary and secondary)
      members = list(object({
        origin_id = string # Must match an origin ID defined in origins
      }))
    })))

    tags = optional(map(string)) # Per-distribution tags
  }))
  default     = {}
  description = "Map of CloudFront distributions to create"
}
