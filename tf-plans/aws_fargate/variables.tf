# Variables for the AWS Fargate wrapper.
# task_definitions is defined in locals.tf (uses file() for container JSON).

variable "region" {
  description = "AWS region where ECS and Fargate resources are deployed."
  type        = string
}

variable "tags" {
  description = "Global tags applied to all Fargate resources."
  type        = map(string)
  default     = {}
}

variable "clusters" {
  description = "List of ECS cluster definitions. See module README for full schema."
  type = list(object({
    key                = string
    name               = string
    container_insights = optional(bool, true)
    tags               = optional(map(string), {})
  }))
  default = []
}

variable "services" {
  description = "List of ECS Fargate service definitions. See module README for full schema."
  type = list(object({
    key                 = string
    name                = string
    cluster_key         = string
    task_definition_key = string
    desired_count       = optional(number, 1)

    launch_type = optional(string, "FARGATE")

    capacity_provider_strategy = optional(list(object({
      capacity_provider = string
      weight            = number
      base              = optional(number, 0)
    })), [])

    subnet_ids         = list(string)
    security_group_ids = list(string)
    assign_public_ip   = optional(bool, false)

    deployment_minimum_healthy_percent = optional(number, 100)
    deployment_maximum_percent         = optional(number, 200)
    health_check_grace_period_seconds  = optional(number, 0)
    enable_deployment_circuit_breaker  = optional(bool, true)

    load_balancer = optional(object({
      target_group_arn = string
      container_name   = string
      container_port   = number
    }))

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
