# Wrapper inputs: region, tags, and Batch resources to create

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
variable "compute_environments" {
  type = map(object({
    name         = string
    type         = string
    service_role = optional(string)
    compute_resources = optional(object({
      type                = string
      max_vcpus           = number
      min_vcpus           = optional(number)
      desired_vcpus       = optional(number)
      instance_types      = list(string)
      subnets             = list(string)
      security_group_ids  = list(string)
      instance_role       = optional(string)
      ec2_key_pair        = optional(string)
      allocation_strategy = optional(string)
      bid_percentage      = optional(number)
      spot_iam_fleet_role = optional(string)
      launch_template = optional(object({
        launch_template_id   = optional(string)
        launch_template_name = optional(string)
        version              = optional(string)
      }))
    }))
    state = optional(string)
    tags  = optional(map(string))
  }))
  default     = {}
  description = "Compute environments to create"
}

variable "job_queues" {
  type = map(object({
    name                     = string
    state                    = string
    priority                 = number
    compute_environment_keys = list(string)
    tags                     = optional(map(string))
  }))
  default     = {}
  description = "Job queues to create"
}

variable "job_definitions" {
  type = map(object({
    name                  = string
    type                  = string
    platform_capabilities = optional(list(string))
    container_properties  = optional(string)
    retry_strategy = optional(object({
      attempts = number
      evaluate_on_exit = optional(list(object({
        action           = string
        on_status_reason = optional(string)
        on_reason        = optional(string)
        on_exit_code     = optional(string)
      })))
    }))
    timeout = optional(object({
      attempt_duration_seconds = number
    }))
    tags = optional(map(string))
  }))
  default     = {}
  description = "Job definitions to create"
}
