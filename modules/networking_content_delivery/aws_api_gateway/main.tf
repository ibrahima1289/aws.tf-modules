# Create one or more API Gateway v2 APIs with integrations, routes, and stages

# APIs: core HTTP/WebSocket API definitions per entry in `var.apis`
resource "aws_apigatewayv2_api" "api" {
  for_each = local.apis

  # Required identifiers
  name          = each.value.name
  protocol_type = each.value.protocol_type

  # Optional description; avoid null by defaulting to empty string
  description = try(each.value.description, "")

  # Optional CORS configuration block, only rendered when provided
  dynamic "cors_configuration" {
    for_each = try(each.value.cors_configuration, null) != null ? [each.value.cors_configuration] : []
    content {
      allow_headers     = try(cors_configuration.value.allow_headers, null)
      allow_methods     = try(cors_configuration.value.allow_methods, null)
      allow_origins     = try(cors_configuration.value.allow_origins, null)
      expose_headers    = try(cors_configuration.value.expose_headers, null)
      max_age           = try(cors_configuration.value.max_age, null)
      allow_credentials = try(cors_configuration.value.allow_credentials, null)
    }
  }

  # Merge global tags, per-API tags, and a stable CreatedDate
  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    { CreatedDate = local.created_date }
  )
}

# Integrations per API: Lambda AWS_PROXY or HTTP backends
resource "aws_apigatewayv2_integration" "integration" {
  for_each = local.integrations_flat

  api_id           = aws_apigatewayv2_api.api[each.value.api_key].id
  integration_type = each.value.integration_type
  integration_uri  = each.value.integration_uri

  # Avoid nulls: default payload_format_version to "2.0", timeout to provider default (30000)
  payload_format_version = try(each.value.payload_format_version, "2.0")
  timeout_milliseconds   = try(each.value.timeout_milliseconds, 30000)
}

# Routes per API: wire route_key to its target integration
resource "aws_apigatewayv2_route" "route" {
  for_each = local.routes_flat

  api_id    = aws_apigatewayv2_api.api[each.value.api_key].id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.integration[each.value.integration_comp_key].id}"

  # Default authorization to NONE when not specified
  authorization_type = try(each.value.authorization_type, "NONE")
}

# Stage per API (when provided); defaults to $default if omitted
resource "aws_apigatewayv2_stage" "stage" {
  for_each = local.stages_flat

  api_id      = aws_apigatewayv2_api.api[each.value.api_key].id
  name        = try(each.value.name, "$default")
  auto_deploy = try(each.value.auto_deploy, true)

  # Optional access logs
  dynamic "access_log_settings" {
    for_each = try(each.value.access_log_settings, null) != null ? [each.value.access_log_settings] : []
    content {
      destination_arn = access_log_settings.value.destination_arn
      format          = access_log_settings.value.format
    }
  }

  # Optional default route settings
  dynamic "default_route_settings" {
    for_each = try(each.value.default_route_settings, null) != null ? [each.value.default_route_settings] : []
    content {
      throttling_burst_limit   = try(default_route_settings.value.throttling_burst_limit, null)
      throttling_rate_limit    = try(default_route_settings.value.throttling_rate_limit, null)
      detailed_metrics_enabled = try(default_route_settings.value.detailed_metrics_enabled, null)
    }
  }

  # Per-stage tags including CreatedDate
  tags = merge(var.tags, { CreatedDate = local.created_date })
}

# ---------------------------------------------------------------------------
# Optional custom domain names, API mappings, and Route 53 alias records
# ---------------------------------------------------------------------------

# Create API Gateway v2 custom domains for any configured entries in `var.domains`
resource "aws_apigatewayv2_domain_name" "domain" {
  for_each = var.domains

  domain_name = each.value.domain_name

  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = try(each.value.security_policy, "TLS_1_2")
  }

  # Tag the custom domain with created_date and any global tags
  tags = merge(
    var.tags,
    { created_date = local.created_date }
  )
}

# Map each custom domain to its target API and stage
resource "aws_apigatewayv2_api_mapping" "mapping" {
  for_each = var.domains

  api_id      = aws_apigatewayv2_api.api[each.value.api_key].id
  domain_name = aws_apigatewayv2_domain_name.domain[each.key].domain_name

  # Use the named stage when configured; otherwise default to "$default"
  stage = coalesce(
    try(local.stages_flat[each.value.api_key].name, null),
    "$default"
  )
}

# Route 53 alias records pointing to the API Gateway custom domains
resource "aws_route53_record" "domain" {
  for_each = var.domains

  name    = each.value.domain_name
  type    = "A"
  zone_id = each.value.hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain[each.key].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain[each.key].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
