# Input variables for the API Gateway module

# Region used by the AWS provider
variable "region" {
  type        = string
  description = "AWS region for the provider"
}

# Global tags applied across resources
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Global tags applied to all resources in this module"
}

# Define one or more API Gateway v2 APIs via a keyed map
# Each entry can include integrations, routes, and optional stage settings
variable "apis" {
  type = map(object({
    name          = string           # API display name
    protocol_type = string           # "HTTP" or "WEBSOCKET"
    description   = optional(string) # Optional description

    # Optional CORS configuration
    cors_configuration = optional(object({
      allow_headers     = optional(list(string))
      allow_methods     = optional(list(string))
      allow_origins     = optional(list(string))
      expose_headers    = optional(list(string))
      max_age           = optional(number)
      allow_credentials = optional(bool)
    }))

    # Integrations keyed per API (Lambda AWS_PROXY or HTTP backends)
    integrations = optional(map(object({
      integration_type       = string           # e.g., "AWS_PROXY" or "HTTP"
      integration_uri        = string           # Lambda ARN or HTTP URL
      payload_format_version = optional(string) # e.g., "2.0" (default used if omitted)
      timeout_milliseconds   = optional(number) # default used if omitted
    })))

    # Routes targeting integrations by key
    routes = optional(list(object({
      route_key              = string           # e.g., "GET /items"
      target_integration_key = string           # references an entry in `integrations`
      authorization_type     = optional(string) # defaults to NONE if omitted
    })))

    # Optional per-API stage configuration
    stage = optional(object({
      name        = optional(string) # defaults to "$default"
      auto_deploy = optional(bool)   # defaults to true
      access_log_settings = optional(object({
        destination_arn = string
        format          = string
      }))
      default_route_settings = optional(object({
        throttling_burst_limit   = optional(number)
        throttling_rate_limit    = optional(number)
        detailed_metrics_enabled = optional(bool)
      }))
    }))

    # Optional per-API tags merged with global tags
    tags = optional(map(string))
  }))
  description = "Map of APIs keyed by unique names, each with integrations, routes, and optional stage settings"
}

# Optional custom domains mapped to APIs
# Each entry configures:
# - an existing ACM certificate (by ARN)
# - a custom API Gateway domain name
# - a Route 53 alias record in a hosted zone you own
variable "domains" {
  type = map(object({
    api_key        = string # key of the API in `var.apis` to map
    domain_name    = string # e.g., "api.example.com"
    hosted_zone_id = string # Route 53 hosted zone ID where the record will be created

    # ARN of an existing ACM certificate in the same region
    # (certificate should already be validated; this module does not request/validate ACM certs)
    certificate_arn = string

    # Optional override for security policy (defaults to TLS_1_2)
    security_policy = optional(string)
  }))

  default     = {}
  description = "Optional map of custom domains to create for APIs; empty map means no domains are created"
}
