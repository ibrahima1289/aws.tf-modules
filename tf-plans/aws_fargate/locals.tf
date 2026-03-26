locals {
  # Compute a one-time created_date stamp merged into var.tags before passing to the module.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # ── Task definitions ──────────────────────────────────────────────────────
  # Defined here (not in terraform.tfvars) so container definitions can be
  # loaded from readable JSON template files via file().
  # The log group name in each JSON file must match /ecs/{family}.
  task_definitions_config = [

    # Task 1: Node.js API service
    # Runs behind an ALB; container logs go to /ecs/api-service.
    {
      key                     = "api"
      family                  = "api-service"
      cpu                     = "512"
      memory                  = "1024"
      task_execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
      task_role_arn           = "arn:aws:iam::123456789012:role/api-task-role"
      log_retention_days      = 30
      operating_system_family = "LINUX"
      cpu_architecture        = "X86_64"
      # Load container spec from a dedicated JSON template file.
      container_definitions = file("${path.module}/templates/api-containers.json")
      tags                  = { service = "api" }
    },

    # Task 2: Python order-processing worker
    # Pulls messages from SQS; no load balancer needed.
    # Uses FARGATE_SPOT on the service for cost savings.
    {
      key                     = "worker"
      family                  = "order-worker"
      cpu                     = "256"
      memory                  = "512"
      task_execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
      task_role_arn           = "arn:aws:iam::123456789012:role/worker-task-role"
      log_retention_days      = 14
      operating_system_family = "LINUX"
      cpu_architecture        = "X86_64"
      # Load container spec from a dedicated JSON template file.
      container_definitions = file("${path.module}/templates/worker-containers.json")
      tags                  = { service = "worker" }
    }
  ]
}
