# Local values for CloudFront resources

locals {
  # CreatedDate tag for all resources (YYYY-MM-DD format)
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Normalize distributions with safe defaults
  distributions = {
    for key, dist in var.distributions : key => {
      comment             = dist.comment
      enabled             = dist.enabled
      is_ipv6_enabled     = try(dist.is_ipv6_enabled, true)
      http_version        = try(dist.http_version, "http2")
      price_class         = try(dist.price_class, "PriceClass_100")
      retain_on_delete    = try(dist.retain_on_delete, false)
      wait_for_deployment = try(dist.wait_for_deployment, true)
      web_acl_id          = try(dist.web_acl_id, null)
      aliases             = try(dist.aliases, [])

      # Origins configuration
      origins = dist.origins

      # Default cache behavior
      default_cache_behavior = dist.default_cache_behavior

      # Optional ordered cache behaviors
      ordered_cache_behaviors = try(dist.ordered_cache_behaviors, [])

      # Optional custom error responses
      custom_error_responses = try(dist.custom_error_responses, [])

      # Optional viewer certificate
      viewer_certificate = try(dist.viewer_certificate, null)

      # Optional logging configuration
      logging_config = try(dist.logging_config, null)

      # Optional restrictions (geo restrictions)
      restrictions = try(dist.restrictions, null)

      # Optional origin groups (failover)
      origin_groups = try(dist.origin_groups, [])

      # Merge global and per-distribution tags with CreatedDate
      tags = merge(
        var.tags,
        try(dist.tags, {}),
        { CreatedDate = local.created_date }
      )
    }
  }
}
