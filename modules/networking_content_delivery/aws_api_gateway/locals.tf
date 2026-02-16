# Local helpers and stable created date

locals {
  # ISO 8601 timestamp used in tags
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Convenience alias for `var.apis`
  apis = var.apis

  # Flatten integrations across all APIs with a composite key
  # Key format: "<api_key>::<integration_key>"
  integrations_flat = merge([
    for api_key, api in var.apis : {
      for integ_key, integ in coalesce(api.integrations, {}) : "${api_key}::${integ_key}" => merge(integ, {
        api_key = api_key
      })
    }
  ]...)

  # Flatten routes across all APIs; each references its target integration
  # Key format: "<api_key>::<route_key>"
  routes_flat = merge([
    for api_key, api in var.apis : {
      for r in coalesce(api.routes, []) : "${api_key}::${r.route_key}" => merge(r, {
        api_key              = api_key,
        integration_comp_key = "${api_key}::${r.target_integration_key}"
      })
    }
  ]...)

  # Flatten stages for APIs that provide stage settings
  # Key: the api_key for one stage per API
  stages_flat = merge([
    for api_key, api in var.apis : (
      api.stage != null ? {
        "${api_key}" = merge(api.stage, { api_key = api_key })
      } : {}
    )
  ]...)
}
