# Terraform AWS Fargate Module
# Manages ECS clusters, Fargate task definitions, CloudWatch log groups,
# and ECS services running on Fargate (or Fargate Spot).
# Supports multiple clusters, task definitions, and services via for_each.
# Container definitions are supplied as a JSON string per task definition,
# allowing callers to use jsonencode() or file() for clean separation.

# ─── Step 1: ECS Clusters ─────────────────────────────────────────────────────
# Create one ECS cluster per entry in var.clusters.
# Container Insights can be enabled per cluster for enhanced CloudWatch metrics.
resource "aws_ecs_cluster" "cluster" {
  for_each = local.clusters_map

  name = each.value.name

  # Step 1a: Container Insights — provides CPU, memory, network, and storage
  # metrics per task and service without any agent installation.
  setting {
    name  = "containerInsights"
    value = each.value.container_insights ? "enabled" : "disabled"
  }

  tags = merge(local.common_tags, each.value.tags)
}

# ─── Step 2: Cluster Capacity Providers ───────────────────────────────────────
# Register FARGATE and FARGATE_SPOT as capacity providers on every cluster.
# Services can then choose between them via capacity_provider_strategy or
# fall back to the default (FARGATE) using launch_type.
resource "aws_ecs_cluster_capacity_providers" "providers" {
  for_each = local.clusters_map

  cluster_name       = aws_ecs_cluster.cluster[each.key].name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  # Default strategy: always start at least 1 base task on standard FARGATE
  # so the service remains available even when Spot capacity is interrupted.
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

# ─── Step 3: CloudWatch Log Groups ────────────────────────────────────────────
# Create one log group per task definition using the convention /ecs/{family}.
# Container definitions should reference this same group name in their
# awslogs-group option so all container logs stream here automatically.
resource "aws_cloudwatch_log_group" "task" {
  for_each = local.task_definitions_map

  name              = "/ecs/${each.value.family}"
  retention_in_days = each.value.log_retention_days

  tags = merge(local.common_tags, each.value.tags)
}

# ─── Step 4: ECS Task Definitions ─────────────────────────────────────────────
# Create one Fargate task definition per entry in var.task_definitions.
# All tasks use awsvpc network mode (required for Fargate) and inherit their
# container definitions from the caller-supplied JSON string.
resource "aws_ecs_task_definition" "task" {
  for_each = local.task_definitions_map

  family                   = each.value.family
  requires_compatibilities = ["FARGATE"]

  # Step 4a: awsvpc gives each task its own Elastic Network Interface (ENI),
  # providing task-level security group and VPC routing control.
  network_mode = "awsvpc"

  # Step 4b: Task-level CPU and memory allocations for Fargate billing.
  # Supported combinations: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = each.value.cpu
  memory = each.value.memory

  # Step 4c: IAM roles — execution role allows ECS to pull images and write
  # logs; task role is assumed by the running container for AWS API calls.
  execution_role_arn = each.value.task_execution_role_arn
  task_role_arn      = each.value.task_role_arn

  # Step 4d: Container definitions JSON — passed in by the caller.
  # Build this with jsonencode() in locals.tf or load from a template file
  # via file("${path.module}/templates/<name>-containers.json").
  container_definitions = each.value.container_definitions

  # Step 4e: Runtime platform — controls the OS family and CPU architecture.
  # Use "ARM64" for Graviton-based tasks (up to 20% cheaper than X86_64).
  runtime_platform {
    operating_system_family = each.value.operating_system_family
    cpu_architecture        = each.value.cpu_architecture
  }

  # Step 4f: Named volumes — bind or EFS mounts referenced by containers.
  dynamic "volume" {
    for_each = each.value.volumes
    content {
      name = volume.value.name

      # EFS volume — optional; omit for ephemeral (bind) volumes.
      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id     = efs_volume_configuration.value.file_system_id
          root_directory     = efs_volume_configuration.value.root_directory
          transit_encryption = efs_volume_configuration.value.transit_encryption
        }
      }
    }
  }

  tags = merge(local.common_tags, each.value.tags)

  # Log groups must exist before the task definition registers the awslogs driver.
  depends_on = [aws_cloudwatch_log_group.task]
}

# ─── Step 5: ECS Services ─────────────────────────────────────────────────────
# Create one ECS service per entry in var.services.
# Each service maintains a desired count of Fargate tasks, handles rolling
# deployments, and optionally integrates with an ALB or Cloud Map.
resource "aws_ecs_service" "service" {
  for_each = local.services_map

  name            = each.value.name
  cluster         = aws_ecs_cluster.cluster[each.value.cluster_key].id
  task_definition = aws_ecs_task_definition.task[each.value.task_definition_key].arn
  desired_count   = each.value.desired_count

  # Step 5a: Launch type — used when no capacity_provider_strategy is supplied.
  # Setting this to null allows capacity_provider_strategy blocks to take effect.
  launch_type = length(each.value.capacity_provider_strategy) == 0 ? each.value.launch_type : null

  # Step 5b: Capacity provider strategy — mix FARGATE and FARGATE_SPOT tasks
  # for cost optimisation. Ignored when launch_type is used instead.
  dynamic "capacity_provider_strategy" {
    for_each = each.value.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  # Step 5c: Network configuration — every Fargate task requires awsvpc;
  # subnets and security groups are applied at the task ENI level.
  network_configuration {
    subnets          = each.value.subnet_ids
    security_groups  = each.value.security_group_ids
    assign_public_ip = each.value.assign_public_ip
  }

  # Step 5d: Optional load balancer — routes traffic from ALB/NLB target group
  # to the named container port on each task.
  dynamic "load_balancer" {
    for_each = each.value.load_balancer != null ? [each.value.load_balancer] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Step 5e: Optional Cloud Map service discovery — registers each task in a
  # private DNS namespace for service-to-service communication without a load balancer.
  dynamic "service_registries" {
    for_each = each.value.service_registries != null ? [each.value.service_registries] : []
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = service_registries.value.port
      container_port = service_registries.value.container_port
      container_name = service_registries.value.container_name
    }
  }

  # Step 5f: Deployment settings — rolling update behaviour and circuit breaker.
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  deployment_maximum_percent         = each.value.deployment_maximum_percent
  health_check_grace_period_seconds  = each.value.health_check_grace_period_seconds

  # Automatically roll back to the last stable task definition if the new
  # deployment fails to reach a healthy steady state.
  deployment_circuit_breaker {
    enable   = each.value.enable_deployment_circuit_breaker
    rollback = each.value.enable_deployment_circuit_breaker
  }

  # Step 5g: Tag propagation — copy service/task-definition tags onto tasks.
  enable_ecs_managed_tags = each.value.enable_ecs_managed_tags
  propagate_tags          = each.value.propagate_tags

  tags = merge(local.common_tags, each.value.tags)

  # Services must be created after the cluster capacity providers are registered.
  depends_on = [
    aws_ecs_cluster_capacity_providers.providers,
    aws_ecs_task_definition.task,
  ]
}
