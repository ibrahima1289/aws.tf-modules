variable "region" {
  description = "AWS region (e.g., us-east-1)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources (e.g., { project = \"demo\", environment = \"dev\" })"
  type        = map(string)
  default     = {}
}

# ─── Trails ──────────────────────────────────────────────────────────────────
variable "trails" {
  description = "List of CloudTrail trails to create"
  type = list(object({
    name           = string
    s3_bucket_name = string

    s3_key_prefix  = optional(string)
    sns_topic_name = optional(string)

    is_multi_region_trail         = optional(bool, false)
    include_global_service_events = optional(bool, true)
    is_organization_trail         = optional(bool, false)

    enable_logging             = optional(bool, true)
    enable_log_file_validation = optional(bool, true)

    kms_key_id = optional(string)

    cloud_watch_logs_group_arn = optional(string)
    cloud_watch_logs_role_arn  = optional(string)

    event_selectors = optional(list(object({
      read_write_type                  = optional(string, "All")
      include_management_events        = optional(bool, true)
      exclude_management_event_sources = optional(list(string), [])
      data_resources = optional(list(object({
        type   = string
        values = list(string)
      })), [])
    })), [])

    advanced_event_selectors = optional(list(object({
      name = optional(string)
      field_selectors = list(object({
        field           = string
        equals          = optional(list(string))
        not_equals      = optional(list(string))
        starts_with     = optional(list(string))
        not_starts_with = optional(list(string))
        ends_with       = optional(list(string))
        not_ends_with   = optional(list(string))
      }))
    })), [])

    insight_selectors = optional(list(object({
      insight_type = string
    })), [])

    tags = optional(map(string), {})
  }))
  default = []
}
