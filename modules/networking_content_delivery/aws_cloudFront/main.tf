# Create AWS CloudFront distributions for content delivery

# ---------------------------------------------------------------------------
# CloudFront Distributions
# ---------------------------------------------------------------------------

# Create CloudFront distributions with origins, cache behaviors, and settings
resource "aws_cloudfront_distribution" "distribution" {
  for_each = local.distributions

  # Basic configuration
  comment             = each.value.comment
  enabled             = each.value.enabled
  is_ipv6_enabled     = each.value.is_ipv6_enabled
  http_version        = each.value.http_version
  price_class         = each.value.price_class
  retain_on_delete    = each.value.retain_on_delete
  wait_for_deployment = each.value.wait_for_deployment

  # Alternate domain names (CNAMEs)
  aliases = each.value.aliases

  # AWS WAF web ACL ID for security
  web_acl_id = each.value.web_acl_id

  # Origins define where CloudFront retrieves content
  dynamic "origin" {
    for_each = each.value.origins
    content {
      origin_id   = origin.value.origin_id
      domain_name = origin.value.domain_name
      origin_path = try(origin.value.origin_path, null)

      # Connection settings
      connection_attempts = try(origin.value.connection_attempts, null)
      connection_timeout  = try(origin.value.connection_timeout, null)

      # Custom headers to send to the origin
      dynamic "custom_header" {
        for_each = try(origin.value.custom_headers, null) != null ? origin.value.custom_headers : []
        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }

      # S3 origin configuration (for S3 buckets)
      dynamic "s3_origin_config" {
        for_each = try(origin.value.s3_origin_config, null) != null ? [origin.value.s3_origin_config] : []
        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      # Custom origin configuration (for non-S3 origins)
      dynamic "custom_origin_config" {
        for_each = try(origin.value.custom_origin_config, null) != null ? [origin.value.custom_origin_config] : []
        content {
          http_port                = try(custom_origin_config.value.http_port, 80)
          https_port               = try(custom_origin_config.value.https_port, 443)
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = try(custom_origin_config.value.origin_keepalive_timeout, null)
          origin_read_timeout      = try(custom_origin_config.value.origin_read_timeout, null)
        }
      }

      # Origin Shield (additional caching layer for improved cache hit ratio)
      dynamic "origin_shield" {
        for_each = try(origin.value.origin_shield, null) != null ? [origin.value.origin_shield] : []
        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }
    }
  }

  # Origin groups for failover support
  dynamic "origin_group" {
    for_each = try(each.value.origin_groups, null) != null ? each.value.origin_groups : []
    content {
      origin_id = origin_group.value.origin_id

      # Failover criteria (HTTP status codes that trigger failover)
      failover_criteria {
        status_codes = origin_group.value.failover_criteria.status_codes
      }

      # Member origins (primary and secondary)
      dynamic "member" {
        for_each = origin_group.value.members
        content {
          origin_id = member.value.origin_id
        }
      }
    }
  }

  # Default cache behavior (applies to all requests not matched by ordered behaviors)
  default_cache_behavior {
    target_origin_id          = each.value.default_cache_behavior.target_origin_id
    viewer_protocol_policy    = each.value.default_cache_behavior.viewer_protocol_policy
    allowed_methods           = each.value.default_cache_behavior.allowed_methods
    cached_methods            = each.value.default_cache_behavior.cached_methods
    compress                  = try(each.value.default_cache_behavior.compress, null)
    smooth_streaming          = try(each.value.default_cache_behavior.smooth_streaming, null)
    field_level_encryption_id = try(each.value.default_cache_behavior.field_level_encryption_id, null)
    realtime_log_config_arn   = try(each.value.default_cache_behavior.realtime_log_config_arn, null)

    # Modern cache policies (recommended)
    cache_policy_id            = try(each.value.default_cache_behavior.cache_policy_id, null)
    origin_request_policy_id   = try(each.value.default_cache_behavior.origin_request_policy_id, null)
    response_headers_policy_id = try(each.value.default_cache_behavior.response_headers_policy_id, null)

    # Legacy TTL settings (only if not using cache_policy_id)
    min_ttl     = try(each.value.default_cache_behavior.min_ttl, null)
    default_ttl = try(each.value.default_cache_behavior.default_ttl, null)
    max_ttl     = try(each.value.default_cache_behavior.max_ttl, null)

    # Legacy forwarded values (only if not using cache_policy_id)
    dynamic "forwarded_values" {
      for_each = try(each.value.default_cache_behavior.forwarded_values, null) != null ? [each.value.default_cache_behavior.forwarded_values] : []
      content {
        query_string            = forwarded_values.value.query_string
        headers                 = try(forwarded_values.value.headers, null)
        query_string_cache_keys = try(forwarded_values.value.query_string_cache_keys, null)

        cookies {
          forward           = forwarded_values.value.cookies.forward
          whitelisted_names = try(forwarded_values.value.cookies.whitelisted_names, null)
        }
      }
    }

    # Trusted signers for signed URLs/cookies
    trusted_signers    = try(each.value.default_cache_behavior.trusted_signers, null)
    trusted_key_groups = try(each.value.default_cache_behavior.trusted_key_groups, null)

    # Lambda@Edge function associations
    dynamic "lambda_function_association" {
      for_each = try(each.value.default_cache_behavior.lambda_function_associations, null) != null ? each.value.default_cache_behavior.lambda_function_associations : []
      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = try(lambda_function_association.value.include_body, null)
      }
    }

    # CloudFront Functions associations
    dynamic "function_association" {
      for_each = try(each.value.default_cache_behavior.function_associations, null) != null ? each.value.default_cache_behavior.function_associations : []
      content {
        event_type   = function_association.value.event_type
        function_arn = function_association.value.function_arn
      }
    }
  }

  # Ordered cache behaviors (path-specific caching rules)
  dynamic "ordered_cache_behavior" {
    for_each = try(each.value.ordered_cache_behaviors, null) != null ? each.value.ordered_cache_behaviors : []
    content {
      path_pattern              = ordered_cache_behavior.value.path_pattern
      target_origin_id          = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy    = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods           = ordered_cache_behavior.value.allowed_methods
      cached_methods            = ordered_cache_behavior.value.cached_methods
      compress                  = try(ordered_cache_behavior.value.compress, null)
      smooth_streaming          = try(ordered_cache_behavior.value.smooth_streaming, null)
      field_level_encryption_id = try(ordered_cache_behavior.value.field_level_encryption_id, null)
      realtime_log_config_arn   = try(ordered_cache_behavior.value.realtime_log_config_arn, null)

      # Modern cache policies
      cache_policy_id            = try(ordered_cache_behavior.value.cache_policy_id, null)
      origin_request_policy_id   = try(ordered_cache_behavior.value.origin_request_policy_id, null)
      response_headers_policy_id = try(ordered_cache_behavior.value.response_headers_policy_id, null)

      # Legacy TTL settings
      min_ttl     = try(ordered_cache_behavior.value.min_ttl, null)
      default_ttl = try(ordered_cache_behavior.value.default_ttl, null)
      max_ttl     = try(ordered_cache_behavior.value.max_ttl, null)

      # Legacy forwarded values
      dynamic "forwarded_values" {
        for_each = try(ordered_cache_behavior.value.forwarded_values, null) != null ? [ordered_cache_behavior.value.forwarded_values] : []
        content {
          query_string            = forwarded_values.value.query_string
          headers                 = try(forwarded_values.value.headers, null)
          query_string_cache_keys = try(forwarded_values.value.query_string_cache_keys, null)

          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = try(forwarded_values.value.cookies.whitelisted_names, null)
          }
        }
      }

      # Trusted signers
      trusted_signers    = try(ordered_cache_behavior.value.trusted_signers, null)
      trusted_key_groups = try(ordered_cache_behavior.value.trusted_key_groups, null)

      # Lambda@Edge associations
      dynamic "lambda_function_association" {
        for_each = try(ordered_cache_behavior.value.lambda_function_associations, null) != null ? ordered_cache_behavior.value.lambda_function_associations : []
        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = try(lambda_function_association.value.include_body, null)
        }
      }

      # CloudFront Functions associations
      dynamic "function_association" {
        for_each = try(ordered_cache_behavior.value.function_associations, null) != null ? ordered_cache_behavior.value.function_associations : []
        content {
          event_type   = function_association.value.event_type
          function_arn = function_association.value.function_arn
        }
      }
    }
  }

  # Custom error responses for handling HTTP errors
  dynamic "custom_error_response" {
    for_each = try(each.value.custom_error_responses, null) != null ? each.value.custom_error_responses : []
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = try(custom_error_response.value.response_code, null)
      response_page_path    = try(custom_error_response.value.response_page_path, null)
      error_caching_min_ttl = try(custom_error_response.value.error_caching_min_ttl, null)
    }
  }

  # Viewer certificate configuration (SSL/TLS)
  dynamic "viewer_certificate" {
    for_each = each.value.viewer_certificate != null ? [each.value.viewer_certificate] : []
    content {
      acm_certificate_arn            = try(viewer_certificate.value.acm_certificate_arn, null)
      iam_certificate_id             = try(viewer_certificate.value.iam_certificate_id, null)
      cloudfront_default_certificate = try(viewer_certificate.value.cloudfront_default_certificate, null)
      minimum_protocol_version       = try(viewer_certificate.value.minimum_protocol_version, null)
      ssl_support_method             = try(viewer_certificate.value.ssl_support_method, null)
    }
  }

  # Default viewer certificate if none specified
  dynamic "viewer_certificate" {
    for_each = each.value.viewer_certificate == null ? [1] : []
    content {
      cloudfront_default_certificate = true
    }
  }

  # Logging configuration (access logs to S3)
  dynamic "logging_config" {
    for_each = each.value.logging_config != null ? [each.value.logging_config] : []
    content {
      bucket          = logging_config.value.bucket
      include_cookies = try(logging_config.value.include_cookies, false)
      prefix          = try(logging_config.value.prefix, null)
    }
  }

  # Geographic restrictions
  dynamic "restrictions" {
    for_each = each.value.restrictions != null ? [each.value.restrictions] : []
    content {
      geo_restriction {
        restriction_type = restrictions.value.geo_restriction.restriction_type
        locations        = try(restrictions.value.geo_restriction.locations, [])
      }
    }
  }

  # Default restrictions if none specified
  dynamic "restrictions" {
    for_each = each.value.restrictions == null ? [1] : []
    content {
      geo_restriction {
        restriction_type = "none"
      }
    }
  }

  # Tags for the distribution
  tags = each.value.tags
}
