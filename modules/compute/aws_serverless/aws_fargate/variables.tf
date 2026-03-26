# Variables for the AWS Fargate Module.

variable "region" {
  description = "AWS region where ECS and Fargate resources are deployed."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}

# ─── Clusters ─────────────────────────────────────────────────────────────────
# Each entry creates one aws_ecs_cluster with Fargate and Fargate Spot capacity
# providers pre-configured.
#
# Required per entry:
#   key  — Stable unique string key used as the for_each index.
#   name — ECS cluster name shown in the AWS console.
#
# Optional per entry:
#   container_insights — Enable enhanced CloudWatch Container Insights metrics.
#   tags               — Per-cluster tags merged with global tags.
variable "clusters" {
  description = "List of ECS cluster definitions. Each entry creates one aws_ecs_cluster with FARGATE and FARGATE_SPOT capacity providers."
  type = list(object({
    key                = string
    name               = string
    container_insights = optional(bool, true)
    tags               = optional(map(string), {})
  }))
  default = []
}

# ─── Task Definitions ─────────────────────────────────────────────────────────
# Each entry creates one aws_ecs_task_definition and its CloudWatch log group.
# Container definitions are passed as a pre-encoded JSON string so callers can
# use jsonencode() in locals.tf or file() to load from a template file.
#
# Required per entry:
#   key                     — Stable unique string key.
#   family                  — Task family name. Versions are appended automatically.
#   cpu                     — Task-level vCPU units as a string: "256", "512",
#                             "1024", "2048", or "4096".
#   memory                  — Task-level memory in MiB as a string: "512",
#                             "1024", "2048", "4096", "8192", etc.
#   task_execution_role_arn — IAM role ARN used by ECS to pull images and write logs.
#   container_definitions   — JSON string with one or more container specs.
#
# Optional per entry:
#   task_role_arn           — IAM role the task's containers can assume.
#   log_retention_days      — CloudWatch log retention (0 = never expire).
#   operating_system_family — "LINUX" (default) or "WINDOWS_SERVER_*" variants.
#   cpu_architecture        — "X86_64" (default) or "ARM64".
#   volumes                 — Named volumes for container mounts (bind or EFS).
#   tags                    — Per-task-definition tags.
variable "task_definitions" {
  description = "List of ECS Fargate task definition configurations. Each entry creates one aws_ecs_task_definition and one aws_cloudwatch_log_group."
  type = list(object({
    key                     = string
    family                  = string
    cpu                     = string
    memory                  = string
    task_execution_role_arn = string
    task_role_arn           = optional(string)
    container_definitions   = string
    log_retention_days      = optional(number, 30)
    operating_system_family = optional(string, "LINUX")
    cpu_architecture        = optional(string, "X86_64")

    volumes = optional(list(object({
      name = string
      efs_volume_configuration = optional(object({
        file_system_id     = string
        root_directory     = optional(string, "/")
        transit_encryption = optional(string, "ENABLED")
      }))
    })), [])

    tags = optional(map(string), {})
  }))
  default = []
}

# ─── Services ─────────────────────────────────────────────────────────────────
# Each entry creates one aws_ecs_service that runs a task definition on Fargate.
# Supports both FARGATE and FARGATE_SPOT via launch_type or capacity_provider_strategy.
#
# Required per entry:
#   key                 — Stable unique string key.
#   name                — ECS service name shown in the AWS console.
#   cluster_key         — Must match a key in var.clusters.
#   task_definition_key — Must match a key in var.task_definitions.
#   subnet_ids          — Subnets for the task ENIs (awsvpc mode).
#   security_group_ids  — Security groups attached to each task's ENI.
#
# Optional per entry:
#   desired_count                      — Number of tasks to run (default 1).
#   launch_type                        — "FARGATE" (default). Ignored when
#                                        capacity_provider_strategy is non-empty.
#   capacity_provider_strategy         — Mix FARGATE and FARGATE_SPOT for cost savings.
#   assign_public_ip                   — Assign public IP to task ENIs (default false).
#   deployment_minimum_healthy_percent — Min % healthy during deployment (default 100).
#   deployment_maximum_percent         — Max % capacity during deployment (default 200).
#   health_check_grace_period_seconds  — Grace period before health checks begin.
#   enable_deployment_circuit_breaker  — Auto-roll back failed deployments.
#   load_balancer                      — ALB/NLB target group routing.
#   service_registries                 — AWS Cloud Map service discovery.
#   enable_ecs_managed_tags            — Propagate ECS-managed tags (default true).
#   propagate_tags                     — Tag propagation source (default "SERVICE").
#   tags                               — Per-service tags.
variable "services" {
  description = "List of ECS Fargate service definitions. Each entry creates one aws_ecs_service."
  type = list(object({
    key                 = string
    name                = string
    cluster_key         = string
    task_definition_key = string
    desired_count       = optional(number, 1)

    # Launch type — used when capacity_provider_strategy is empty.
    launch_type = optional(string, "FARGATE")

    # Capacity provider strategy — mix FARGATE and FARGATE_SPOT.
    # When non-empty, launch_type is ignored.
    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = number
      base              = optional(number, 0)
    })), [])

    # Network configuration (required for awsvpc network mode).
    subnet_ids         = list(string)
    security_group_ids = list(string)
    assign_public_ip   = optional(bool, false)

    # Deployment settings.
    deployment_minimum_healthy_percent = optional(number, 100)
    deployment_maximum_percent         = optional(number, 200)
    health_check_grace_period_seconds  = optional(number, 0)
    enable_deployment_circuit_breaker  = optional(bool, true)

    # Optional ALB / NLB load balancer integration.
    load_balancer = optional(object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    }))

    # Optional AWS Cloud Map service discovery.
    service_registries = optional(object({
      registry_arn   = string
      port           = optional(number)
      container_port = optional(number)
      container_name = optional(string)
    }))

    enable_ecs_managed_tags = optional(bool, true)
    propagate_tags          = optional(string, "SERVICE")

    tags = optional(map(string), {})
  }))
  default = []
}
