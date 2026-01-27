###############################################
# Input variables for the Route 53 module
###############################################


# DNS name for the hosted zone (e.g., example.com or example.com.)
variable "zone_name" {
  type        = string
  description = "DNS name of the hosted zone."
}

# Whether to create a private hosted zone. If true, associate one or more VPCs.
variable "is_private" {
  type        = bool
  description = "Create a private hosted zone when true; otherwise public."
  default     = false
}

# Optional human-readable comment for the hosted zone.
variable "comment" {
  type        = string
  description = "Comment/description for the hosted zone."
  default     = "Managed by Terraform"
}

# Safety: allow destroying a zone even if non-Terraform records remain.
variable "force_destroy" {
  type        = bool
  description = "Allow destroying a zone with non-empty records (use with caution)."
  default     = false
}

# Optional Delegation Set ID for public hosted zones.
variable "delegation_set_id" {
  type        = string
  description = "Delegation Set ID for reusable name servers (public zones only)."
  default     = null
}

# VPC associations for private zones. Provide at least one when is_private=true.
# The `region` field is optional; when omitted, the provider's region is used.
variable "vpc_associations" {
  description = "List of VPCs to associate with a private hosted zone."
  type = list(object({
    vpc_id = string
    region = optional(string)
  }))
  default = []
}

# Optional: Route 53 query logging to CloudWatch Logs.
variable "cloudwatch_log_group_arn" {
  type        = string
  description = "CloudWatch Log Group ARN for Route 53 query logging."
  default     = null
}

variable "enable_query_log" {
  type        = bool
  description = "Enable Route 53 query logging when true (requires log group ARN)."
  default     = false
}

# Overwrite existing non-Terraform records with the same name/type.
variable "allow_overwrite" {
  type        = bool
  description = "Allow overwriting existing records with the same name/type."
  default     = false
}


# Extra tags to merge with standard tags (CreatedDate, ManagedBy, Module).
variable "tags" {
  type        = map(string)
  description = "tags map merged with standard tags; caller-supplied keys can override."
  default     = {}
}

# DNS records to create. Each element supports either basic (ttl+records)
# or alias (alias block) configuration plus optional routing policies.
variable "records" {
  description = "Map of DNS records to create in the hosted zone."
  type = map(object({
    name = string
    type = string

    ttl     = optional(number)           # For non-alias records
    records = optional(list(string), []) # For non-alias records

    alias = optional(object({ # For alias records
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, false)
    }))

    set_identifier = optional(string)

    weighted_routing_policy = optional(object({ weight = number }))
    latency_routing_policy  = optional(object({ region = string }))
    failover_routing_policy = optional(object({ type = string })) # PRIMARY or SECONDARY
    geolocation_routing_policy = optional(object({
      continent   = optional(string)
      country     = optional(string)
      subdivision = optional(string)
    }))
    # CIDR routing policy for records references a CIDR collection and a specific location.
    # CIDR blocks are defined on the collection; records only select `collection_id` and `location_name`.
    cidr_routing_policy = optional(object({
      collection_id = string
      location_name = string
    }))

    multivalue_answer_routing_policy = optional(bool)
    health_check_id                  = optional(string)
  }))
  default = {}
  validation {
    condition     = alltrue([for r in values(var.records) : contains(["A", "AAAA", "CNAME", "TXT", "MX", "NS", "SRV", "CAA", "PTR", "SPF"], r.type)])
    error_message = "Each record.type must be a supported Route 53 type."
  }
}
