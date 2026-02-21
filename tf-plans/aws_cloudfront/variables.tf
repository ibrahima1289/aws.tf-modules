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
    comment             = string
    enabled             = bool
    is_ipv6_enabled     = optional(bool)
    http_version        = optional(string)
    price_class         = optional(string)
    retain_on_delete    = optional(bool)
    wait_for_deployment = optional(bool)
    web_acl_id          = optional(string)
    aliases             = optional(list(string))

    origins = list(object({
      origin_id           = string
      domain_name         = string
      origin_path         = optional(string)
      connection_attempts = optional(number)
      connection_timeout  = optional(number)

      custom_headers = optional(list(object({
        name  = string
        value = string
      })))

      s3_origin_config = optional(object({
        origin_access_identity = string
      }))

      custom_origin_config = optional(object({
        http_port                = optional(number)
        https_port               = optional(number)
        origin_protocol_policy   = string
        origin_ssl_protocols     = list(string)
        origin_keepalive_timeout = optional(number)
        origin_read_timeout      = optional(number)
      }))

      origin_shield = optional(object({
        enabled              = bool
        origin_shield_region = string
      }))
    }))

    default_cache_behavior = object({
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
    })

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

    custom_error_responses = optional(list(object({
      error_code            = number
      response_code         = optional(number)
      response_page_path    = optional(string)
      error_caching_min_ttl = optional(number)
    })))

    viewer_certificate = optional(object({
      acm_certificate_arn            = optional(string)
      iam_certificate_id             = optional(string)
      cloudfront_default_certificate = optional(bool)
      minimum_protocol_version       = optional(string)
      ssl_support_method             = optional(string)
    }))

    logging_config = optional(object({
      bucket          = string
      include_cookies = optional(bool)
      prefix          = optional(string)
    }))

    restrictions = optional(object({
      geo_restriction = object({
        restriction_type = string
        locations        = optional(list(string))
      })
    }))

    origin_groups = optional(list(object({
      origin_id = string

      failover_criteria = object({
        status_codes = list(number)
      })

      members = list(object({
        origin_id = string
      }))
    })))

    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of CloudFront distributions to create"
}
