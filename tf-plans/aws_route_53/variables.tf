###############################################
# Wrapper input variables
###############################################

variable "region" {
  type        = string
  description = "AWS region for the wrapper's AWS provider."
}

# Scalable map of zones instantiated via for_each. Each item maps 1:1
# with the module inputs and supports records and optional logging.
variable "zones" {
  description = "Map describing multiple hosted zones and their records."
  type = map(object({
    zone_name                = string
    is_private               = optional(bool, false)
    comment                  = optional(string, "Managed by Terraform")
    force_destroy            = optional(bool, false)
    delegation_set_id        = optional(string)
    vpc_associations         = optional(list(object({ vpc_id = string, region = optional(string) })), [])
    enable_query_log         = optional(bool, false)
    cloudwatch_log_group_arn = optional(string)
    allow_overwrite          = optional(bool, false)
    tags                     = optional(map(string), {})

    records = optional(map(object({
      name    = string
      type    = string
      ttl     = optional(number)
      records = optional(list(string), [])
      alias   = optional(object({ name = string, zone_id = string, evaluate_target_health = optional(bool, false) }))

      set_identifier          = optional(string)
      weighted_routing_policy = optional(object({ weight = number }))
      latency_routing_policy  = optional(object({ region = string }))
      failover_routing_policy = optional(object({ type = string }))
      geolocation_routing_policy = optional(object({
        continent   = optional(string)
        country     = optional(string)
        subdivision = optional(string)
      }))
      # CIDR routing policy in records references a CIDR collection and location by name.
      cidr_routing_policy = optional(object({
        collection_id = string
        location_name = string
      }))
      multivalue_answer_routing_policy = optional(bool)
      health_check_id                  = optional(string)
    })), {})
  }))
  default = {}
}
