# ─────────────────────────────────────────────────────────────────────────────
# AWS Region
# ─────────────────────────────────────────────────────────────────────────────
region = "us-east-1"

# ─────────────────────────────────────────────────────────────────────────────
# Global Tags
# ─────────────────────────────────────────────────────────────────────────────
tags = {
  environment = "production"
  team        = "platform"
  project     = "containerised-apps"
  managed_by  = "terraform"
}

# ─────────────────────────────────────────────────────────────────────────────
# ECS Clusters
# ─────────────────────────────────────────────────────────────────────────────
clusters = [
  # Single cluster hosting both the web API and background worker services.
  # Container Insights is enabled for per-task CPU/memory/network metrics.
  {
    key                = "web"
    name               = "web-cluster"
    container_insights = true
    tags               = { workload = "web" }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Task Definitions
# Defined in locals.tf so container specs can be loaded from templates/
# via file(). Update awslogs-group and awslogs-region in each JSON file
# to match the task family name and target region.
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# Services
# Each service runs a task definition on the cluster defined above.
# ─────────────────────────────────────────────────────────────────────────────
services = [

  # ── Service 1: API service behind an ALB ───────────────────────────────────
  # Runs 2 tasks on standard FARGATE for consistent latency.
  # Integrated with an existing ALB target group; health check grace period
  # allows the container 30 s to start before the LB checks it.
  {
    key                 = "api"
    name                = "api-service"
    cluster_key         = "web"
    task_definition_key = "api"
    desired_count       = 2

    # Use standard FARGATE (no Spot interruptions for user-facing traffic).
    launch_type = "FARGATE"

    # Deploy into private app subnets; the ALB sits in public subnets.
    subnet_ids         = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f678901a"]
    security_group_ids = ["sg-0abc1234def567890"]
    assign_public_ip   = false

    # Grace period gives nginx 30 s to start before health checks begin.
    health_check_grace_period_seconds = 30

    # Route ALB traffic to port 80 on the "api" container.
    load_balancer = {
      target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/api-tg/abcdef123456"
      container_name   = "api"
      container_port   = 80
    }

    # Roll forward 50 % at a time; allow up to 200 % capacity during the rollout.
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent         = 200
    enable_deployment_circuit_breaker  = true

    tags = { service-tier = "frontend" }
  },

  # ── Service 2: Background worker (FARGATE + FARGATE_SPOT mix) ─────────────
  # Processes order events from SQS asynchronously; tolerates Spot interruptions
  # because tasks are stateless and SQS messages are re-queued on failure.
  # FARGATE base=1 guarantees at least one on-demand task; remaining tasks
  # are provisioned on FARGATE_SPOT for up to ~70 % cost reduction.
  {
    key                 = "worker"
    name                = "worker-service"
    cluster_key         = "web"
    task_definition_key = "worker"
    desired_count       = 3

    # No launch_type — capacity_provider_strategy takes effect instead.
    capacity_provider_strategy = [
      { capacity_provider = "FARGATE", weight = 1, base = 1 },
      { capacity_provider = "FARGATE_SPOT", weight = 3, base = 0 }
    ]

    subnet_ids         = ["subnet-0a1b2c3d4e5f67890", "subnet-0b2c3d4e5f678901a"]
    security_group_ids = ["sg-0def5678abc901234"]
    assign_public_ip   = false

    # No load balancer — worker pulls from SQS directly.
    # Allow one task to go down during a rolling deployment.
    deployment_minimum_healthy_percent = 67
    deployment_maximum_percent         = 200
    enable_deployment_circuit_breaker  = true

    tags = { service-tier = "backend" }
  }
]
