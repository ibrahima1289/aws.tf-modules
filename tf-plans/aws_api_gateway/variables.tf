# Wrapper inputs: region, tags, and APIs to create

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Global tags applied to module resources"
}

# Pass-through inputs for the module
variable "apis" {
  type = map(object({
    name          = string
    protocol_type = string
    description   = optional(string)
    cors_configuration = optional(object({
      allow_headers     = optional(list(string))
      allow_methods     = optional(list(string))
      allow_origins     = optional(list(string))
      expose_headers    = optional(list(string))
      max_age           = optional(number)
      allow_credentials = optional(bool)
    }))
    integrations = optional(map(object({
      integration_type       = string
      integration_uri        = string
      payload_format_version = optional(string)
      timeout_milliseconds   = optional(number)
    })))
    routes = optional(list(object({
      route_key              = string
      target_integration_key = string
      authorization_type     = optional(string)
    })))
    stage = optional(object({
      name        = optional(string)
      auto_deploy = optional(bool)
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
    tags = optional(map(string))
  }))
  description = "APIs to create"
}
