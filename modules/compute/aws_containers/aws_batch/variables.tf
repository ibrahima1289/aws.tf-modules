# Input variables for the AWS Batch module

# Region used by the AWS provider
variable "region" {
  type        = string
  description = "AWS region for the provider"
}

# Global tags applied across all resources
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Global tags applied to all resources in this module"
}

# Define one or more Batch compute environments via a keyed map
variable "compute_environments" {
  type = map(object({
    name = string # Compute environment name
    type = string # "MANAGED" or "UNMANAGED"

    # Service role ARN for Batch to manage resources
    service_role = optional(string)

    # Compute resources configuration (required for MANAGED type)
    compute_resources = optional(object({
      type               = string           # "EC2", "SPOT", or "FARGATE"
      max_vcpus          = number           # Maximum vCPUs
      min_vcpus          = optional(number) # Minimum vCPUs (default 0)
      desired_vcpus      = optional(number) # Desired vCPUs
      instance_types     = list(string)     # EC2 instance types
      subnets            = list(string)     # Subnet IDs
      security_group_ids = list(string)     # Security group IDs
      instance_role      = optional(string) # IAM instance profile ARN for EC2 instances

      # Optional EC2 configuration
      ec2_key_pair        = optional(string)
      allocation_strategy = optional(string) # "BEST_FIT", "BEST_FIT_PROGRESSIVE", "SPOT_CAPACITY_OPTIMIZED"
      bid_percentage      = optional(number) # For SPOT, 0-100
      spot_iam_fleet_role = optional(string) # IAM role for Spot fleet

      # Optional launch template
      launch_template = optional(object({
        launch_template_id   = optional(string)
        launch_template_name = optional(string)
        version              = optional(string)
      }))
    }))

    # State: "ENABLED" or "DISABLED"
    state = optional(string)

    # Optional per-environment tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Batch compute environments keyed by unique names"
}

# Define one or more Batch job queues via a keyed map
variable "job_queues" {
  type = map(object({
    name     = string # Job queue name
    state    = string # "ENABLED" or "DISABLED"
    priority = number # Priority of the queue (higher values = higher priority)

    # Compute environment order (list of environment keys from compute_environments)
    compute_environment_keys = list(string)

    # Optional per-queue tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Batch job queues keyed by unique names"
}

# Define one or more Batch job definitions via a keyed map
variable "job_definitions" {
  type = map(object({
    name = string # Job definition name
    type = string # "container", "multinode"

    # Platform capabilities: "EC2" or "FARGATE"
    platform_capabilities = optional(list(string))

    # Container properties (JSON string for container configuration)
    container_properties = optional(string)

    # Retry strategy
    retry_strategy = optional(object({
      attempts = number
      evaluate_on_exit = optional(list(object({
        action           = string # "RETRY" or "EXIT"
        on_status_reason = optional(string)
        on_reason        = optional(string)
        on_exit_code     = optional(string)
      })))
    }))

    # Timeout configuration
    timeout = optional(object({
      attempt_duration_seconds = number
    }))

    # Optional per-definition tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Batch job definitions keyed by unique names"
}
