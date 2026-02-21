# Create AWS Batch compute environments, job queues, and job definitions

# ---------------------------------------------------------------------------
# Batch Compute Environments
# ---------------------------------------------------------------------------

# Create compute environments for running Batch jobs
resource "aws_batch_compute_environment" "compute_env" {
  for_each = local.compute_environments

  name = each.value.name
  type = each.value.type

  # Service role for Batch to manage resources (required for MANAGED type)
  service_role = try(each.value.service_role, null)

  # State: ENABLED or DISABLED (default ENABLED)
  state = try(each.value.state, "ENABLED")

  # Compute resources configuration (only for MANAGED type)
  dynamic "compute_resources" {
    for_each = try(each.value.compute_resources, null) != null ? [each.value.compute_resources] : []
    content {
      type      = compute_resources.value.type
      max_vcpus = compute_resources.value.max_vcpus

      # Optional vCPU configuration with safe defaults
      min_vcpus     = try(compute_resources.value.min_vcpus, 0)
      desired_vcpus = try(compute_resources.value.desired_vcpus, compute_resources.value.min_vcpus, 0)

      # Instance and network configuration
      instance_type      = compute_resources.value.instance_types
      subnets            = compute_resources.value.subnets
      security_group_ids = compute_resources.value.security_group_ids

      # IAM instance profile for EC2 instances
      instance_role = try(compute_resources.value.instance_role, null)

      # Optional EC2 configuration
      ec2_key_pair        = try(compute_resources.value.ec2_key_pair, null)
      allocation_strategy = try(compute_resources.value.allocation_strategy, null)

      # SPOT instance configuration
      bid_percentage      = try(compute_resources.value.bid_percentage, null)
      spot_iam_fleet_role = try(compute_resources.value.spot_iam_fleet_role, null)

      # Optional launch template
      dynamic "launch_template" {
        for_each = try(compute_resources.value.launch_template, null) != null ? [compute_resources.value.launch_template] : []
        content {
          launch_template_id   = try(launch_template.value.launch_template_id, null)
          launch_template_name = try(launch_template.value.launch_template_name, null)
          version              = try(launch_template.value.version, "$Latest")
        }
      }
    }
  }

  # Merge global tags, per-environment tags, and CreatedDate
  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    { CreatedDate = local.created_date }
  )
}

# ---------------------------------------------------------------------------
# Batch Job Queues
# ---------------------------------------------------------------------------

# Create job queues to submit jobs to compute environments
resource "aws_batch_job_queue" "job_queue" {
  for_each = local.job_queues

  name     = each.value.name
  state    = each.value.state
  priority = each.value.priority

  # Associate with compute environments in priority order
  dynamic "compute_environment_order" {
    for_each = {
      for idx, arn in local.job_queue_compute_envs[each.key] :
      idx => arn
    }
    content {
      order               = compute_environment_order.key + 1
      compute_environment = compute_environment_order.value
    }
  }

  # Merge global tags, per-queue tags, and CreatedDate
  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    { CreatedDate = local.created_date }
  )

  # Ensure compute environments are created before the queue
  depends_on = [aws_batch_compute_environment.compute_env]
}

# ---------------------------------------------------------------------------
# Batch Job Definitions
# ---------------------------------------------------------------------------

# Create job definitions to specify how jobs should run
resource "aws_batch_job_definition" "job_def" {
  for_each = local.job_definitions

  name = each.value.name
  type = each.value.type

  # Platform capabilities (EC2 or FARGATE)
  platform_capabilities = try(each.value.platform_capabilities, null)

  # Container properties (JSON string)
  container_properties = try(each.value.container_properties, null)

  # Optional retry strategy
  dynamic "retry_strategy" {
    for_each = try(each.value.retry_strategy, null) != null ? [each.value.retry_strategy] : []
    content {
      attempts = retry_strategy.value.attempts

      # Optional evaluate on exit rules
      dynamic "evaluate_on_exit" {
        for_each = try(retry_strategy.value.evaluate_on_exit, null) != null ? retry_strategy.value.evaluate_on_exit : []
        content {
          action           = evaluate_on_exit.value.action
          on_status_reason = try(evaluate_on_exit.value.on_status_reason, null)
          on_reason        = try(evaluate_on_exit.value.on_reason, null)
          on_exit_code     = try(evaluate_on_exit.value.on_exit_code, null)
        }
      }
    }
  }

  # Optional timeout configuration
  dynamic "timeout" {
    for_each = try(each.value.timeout, null) != null ? [each.value.timeout] : []
    content {
      attempt_duration_seconds = timeout.value.attempt_duration_seconds
    }
  }

  # Merge global tags, per-definition tags, and CreatedDate
  tags = merge(
    var.tags,
    try(each.value.tags, {}),
    { CreatedDate = local.created_date }
  )
}
