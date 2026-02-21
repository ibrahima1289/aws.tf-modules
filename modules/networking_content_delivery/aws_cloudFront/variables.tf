# Input variables for the AWS CloudFront module

# Region used by the AWS provider
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

# Define one or more CloudFront distributions via a keyed map
variable "distributions" {
  type = map(object({
    comment             = string                 # Description for the distribution
    enabled             = bool                   # Whether the distribution is enabled
    is_ipv6_enabled     = optional(bool)         # Enable IPv6 (default true)
    http_version        = optional(string)       # http1.1, http2, http2and3, http3 (default http2)
    price_class         = optional(string)       # PriceClass_All, PriceClass_200, PriceClass_100
    retain_on_delete    = optional(bool)         # Retain distribution on delete
    wait_for_deployment = optional(bool)         # Wait for deployment to complete (default true)
    web_acl_id          = optional(string)       # AWS WAF web ACL ID
    aliases             = optional(list(string)) # CNAMEs for the distribution

    # Origins define where CloudFront gets content
    origins = list(object({
      origin_id           = string           # Unique identifier for the origin
      domain_name         = string           # S3 bucket or custom origin domain
      origin_path         = optional(string) # Path to prepend to requests
      connection_attempts = optional(number) # Number of connection attempts (1-3)
      connection_timeout  = optional(number) # Connection timeout in seconds (1-10)

      # Custom headers to add to origin requests
      custom_headers = optional(list(object({
        name  = string
        value = string
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
        origin_keepalive_timeout = optional(number) # 1-60 seconds
        origin_read_timeout      = optional(number) # 1-60 seconds
      }))

      # Origin shield (additional caching layer)
      origin_shield = optional(object({
        enabled              = bool
        origin_shield_region = string
      }))
    }))

    # Default cache behavior (required)
    default_cache_behavior = object({
      target_origin_id           = string         # Origin ID to route requests to
      viewer_protocol_policy     = string         # allow-all, https-only, redirect-to-https
      allowed_methods            = list(string)   # GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
      cached_methods             = list(string)   # GET, HEAD, OPTIONS
      compress                   = optional(bool) # Enable gzip compression
      smooth_streaming           = optional(bool) # Enable smooth streaming
      field_level_encryption_id  = optional(string)
      realtime_log_config_arn    = optional(string)
      cache_policy_id            = optional(string) # Managed or custom cache policy ID
      origin_request_policy_id   = optional(string)
      response_headers_policy_id = optional(string)

      # Legacy cache settings (use cache_policy_id instead when possible)
      min_ttl     = optional(number)
      default_ttl = optional(number)
      max_ttl     = optional(number)

      # Query string, cookie, and header forwarding (legacy)
      forwarded_values = optional(object({
        query_string            = bool
        headers                 = optional(list(string))
        query_string_cache_keys = optional(list(string))

        cookies = object({
          forward           = string # none, whitelist, all
          whitelisted_names = optional(list(string))
        })
      }))

      # Trusted signers for signed URLs/cookies
      trusted_signers    = optional(list(string))
      trusted_key_groups = optional(list(string))

      # Lambda@Edge function associations
      lambda_function_associations = optional(list(object({
        event_type   = string # viewer-request, origin-request, viewer-response, origin-response
        lambda_arn   = string
        include_body = optional(bool)
      })))

      # CloudFront Functions associations
      function_associations = optional(list(object({
        event_type   = string # viewer-request, viewer-response
        function_arn = string
      })))
    })

    # Ordered cache behaviors (optional, for path-specific caching)
    ordered_cache_behaviors = optional(list(object({
      path_pattern               = string
      target_origin_id           = string
      viewer_protocol_policy     = string
      allowed_methods            = list(string)
      cached_methods             = list(string)
      compress                   = optional(bool)
      smooth_streaming           = optional(bool)
      field_level_encryption_id  = optional(string)
      realtime_log_config_arn    = optional(string)
      cache_policy_id            = optional(string)
      origin_request_policy_id   = optional(string)
      response_headers_policy_id = optional(string)

      min_ttl     = optional(number)
      default_ttl = optional(number)
      max_ttl     = optional(number)

      forwarded_values = optional(object({
        query_string            = bool
        headers                 = optional(list(string))
        query_string_cache_keys = optional(list(string))

        cookies = object({
          forward           = string
          whitelisted_names = optional(list(string))
        })
      }))

      trusted_signers    = optional(list(string))
      trusted_key_groups = optional(list(string))

      lambda_function_associations = optional(list(object({
        event_type   = string
        lambda_arn   = string
        include_body = optional(bool)
      })))

      function_associations = optional(list(object({
        event_type   = string
        function_arn = string
      })))
    })))

    # Custom error responses
    custom_error_responses = optional(list(object({
      error_code            = number           # HTTP error code (400-599)
      response_code         = optional(number) # Custom response code
      response_page_path    = optional(string) # Path to custom error page
      error_caching_min_ttl = optional(number) # Minimum TTL for error caching
    })))

    # Viewer certificate configuration
    viewer_certificate = optional(object({
      acm_certificate_arn            = optional(string) # ACM certificate ARN (us-east-1)
      iam_certificate_id             = optional(string) # IAM certificate ID
      cloudfront_default_certificate = optional(bool)   # Use default *.cloudfront.net cert
      minimum_protocol_version       = optional(string) # TLSv1, TLSv1.2_2021, etc.
      ssl_support_method             = optional(string) # sni-only, vip, static-ip
    }))

    # Logging configuration
    logging_config = optional(object({
      bucket          = string           # S3 bucket for logs (must end in .s3.amazonaws.com)
      include_cookies = optional(bool)   # Include cookies in logs
      prefix          = optional(string) # Log file prefix
    }))

    # Geographic restrictions
    restrictions = optional(object({
      geo_restriction = object({
        restriction_type = string                 # whitelist, blacklist, none
        locations        = optional(list(string)) # ISO 3166-1-alpha-2 country codes
      })
    }))

    # Origin groups for failover
    origin_groups = optional(list(object({
      origin_id = string # Unique ID for the origin group

      failover_criteria = object({
        status_codes = list(number) # HTTP status codes that trigger failover
      })

      members = list(object({
        origin_id = string # Must match an origin ID
      }))
    })))

    # Optional per-distribution tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of CloudFront distributions keyed by unique names"
}
