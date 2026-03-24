# Variables for the AWS Elastic Beanstalk Module.

variable "region" {
  description = "AWS region where Elastic Beanstalk resources are deployed."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Elastic Beanstalk resources created by this module."
  type        = map(string)
  default     = {}
}

# ─── Applications ──────────────────────────────────────────────────────────────
# Each entry creates one aws_elastic_beanstalk_application, which acts as a
# logical container grouping related environments and application versions.
#
# Required per entry:
#   key  — Stable unique string key used as the for_each index (e.g. "node-web").
#   name — Application name shown in the AWS console.
#
# Optional per entry:
#   description          — Human-readable description of the application.
#   appversion_lifecycle — Policy to automatically clean up old application versions.
#   tags                 — Per-application tags merged with global tags.
variable "applications" {
  description = "List of Elastic Beanstalk application definitions. Each entry creates one aws_elastic_beanstalk_application."
  type = list(object({
    key         = string
    name        = string
    description = optional(string, "")
    tags        = optional(map(string), {})

    # Automatically delete old application versions to stay under the 1,000-version limit.
    # Provide either max_count OR max_age_in_days — not both.
    appversion_lifecycle = optional(object({
      service_role          = string           # IAM role ARN EBS uses to delete old versions
      max_count             = optional(number) # Keep the N most recent versions
      max_age_in_days       = optional(number) # Delete versions older than N days
      delete_source_from_s3 = optional(bool, true)
    }))
  }))
  default = []
}

# ─── Environments ──────────────────────────────────────────────────────────────
# Each entry creates one aws_elastic_beanstalk_environment that runs an
# application version on a managed stack of AWS resources (EC2, ALB, ASG, etc.).
#
# Required per entry:
#   key             — Stable unique string key used as the for_each index.
#   name            — Environment name shown in the AWS console.
#   application_key — Must match a key in var.applications.
#   solution_stack  — EBS solution stack name (platform + OS + language version).
#                     Example: "64bit Amazon Linux 2023 v6.1.0 running Node.js 20"
#
# Optional per entry (all have safe defaults):
#   tier             — "WebServer" (HTTP/HTTPS apps) or "Worker" (SQS-backed tasks).
#   environment_type — "LoadBalanced" (HA with ALB) or "SingleInstance" (dev/staging).
#   instance_type    — EC2 instance type (e.g. "t3.micro", "t3.small").
#   iam_instance_profile — Instance profile for EC2 instances. Must already exist.
#   ec2_key_name     — EC2 key pair name for SSH access. Omit to disable SSH.
#   service_role     — IAM service role for EBS to manage the environment.
#   min_instances    — Minimum number of EC2 instances in the ASG.
#   max_instances    — Maximum number of EC2 instances in the ASG.
#   load_balancer_type  — "application" (ALB), "network" (NLB), or "classic".
#   deployment_policy   — "AllAtOnce", "Rolling", "RollingWithAdditionalBatch", or "Immutable".
#   health_check_path   — HTTP path the ALB uses for health checks.
#   health_reporting    — "basic" or "enhanced" health monitoring.
#   vpc_id              — VPC to deploy into. Omit to use the default VPC.
#   instance_subnets    — List of private subnet IDs for EC2 instances.
#   elb_subnets         — List of public subnet IDs for the load balancer.
#   env_vars            — Map of application environment variable key=value pairs.
#   custom_settings     — Any additional EBS namespace/name/value settings not
#                         covered by the convenience variables above.
#   tags                — Per-environment tags merged with global tags.
variable "environments" {
  description = "List of Elastic Beanstalk environment definitions. Each entry creates one aws_elastic_beanstalk_environment."
  type = list(object({
    key             = string
    name            = string
    application_key = string
    description     = optional(string, "")
    solution_stack  = string

    # Tier and environment type
    tier             = optional(string, "WebServer")
    environment_type = optional(string, "LoadBalanced")

    # Instance settings
    instance_type        = optional(string, "t3.micro")
    iam_instance_profile = optional(string, "aws-elasticbeanstalk-ec2-role")
    ec2_key_name         = optional(string)
    service_role         = optional(string)

    # Capacity
    min_instances = optional(number, 1)
    max_instances = optional(number, 4)

    # Load balancer
    load_balancer_type = optional(string, "application")

    # Deployment
    deployment_policy = optional(string, "Rolling")

    # Health
    health_check_path = optional(string, "/")
    health_reporting  = optional(string, "enhanced")

    # VPC networking
    vpc_id           = optional(string)
    instance_subnets = optional(list(string), [])
    elb_subnets      = optional(list(string), [])

    # Application environment variables
    env_vars = optional(map(string), {})

    # Escape-hatch for any additional EBS namespace/name/value settings
    custom_settings = optional(list(object({
      namespace = string
      name      = string
      value     = string
      resource  = optional(string, "")
    })), [])

    tags = optional(map(string), {})
  }))

  default = []

  validation {
    condition     = alltrue([for e in var.environments : contains(["WebServer", "Worker"], e.tier)])
    error_message = "Each environment.tier must be 'WebServer' or 'Worker'."
  }

  validation {
    condition     = alltrue([for e in var.environments : contains(["LoadBalanced", "SingleInstance"], e.environment_type)])
    error_message = "Each environment.environment_type must be 'LoadBalanced' or 'SingleInstance'."
  }

  validation {
    condition     = alltrue([for e in var.environments : contains(["AllAtOnce", "Rolling", "RollingWithAdditionalBatch", "Immutable", "TrafficSplitting"], e.deployment_policy)])
    error_message = "Each environment.deployment_policy must be one of: AllAtOnce, Rolling, RollingWithAdditionalBatch, Immutable, TrafficSplitting."
  }
}
