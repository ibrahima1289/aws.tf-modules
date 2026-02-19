// Root module for Amazon MQ broker management, supporting multiple brokers with normalized defaults and consistent configuration patterns.
// Supports creating multiple brokers with normalized defaults,
// encryption, logging, maintenance windows, and consistent tagging.

resource "aws_mq_broker" "mq" {
  // Create one Amazon MQ broker per entry in the brokers map
  for_each = local.brokers

  // Core broker settings
  broker_name        = each.value.broker_name
  engine_type        = each.value.engine_type
  engine_version     = each.value.engine_version
  host_instance_type = each.value.host_instance_type

  // Networking
  subnet_ids      = each.value.subnet_ids
  security_groups = each.value.security_groups

  // Deployment and behavior
  deployment_mode            = each.value.deployment_mode
  publicly_accessible        = each.value.publicly_accessible
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade
  apply_immediately          = each.value.apply_immediately
  storage_type               = each.value.storage_type

  authentication_strategy = each.value.authentication_strategy

  // Encryption options (use AWS-owned key by default, optional custom KMS key)
  encryption_options {
    kms_key_id        = each.value.kms_key_id
    use_aws_owned_key = each.value.use_aws_owned_key
  }

  // Logs: only create block when at least one log type is enabled
  dynamic "logs" {
    for_each = (coalesce(each.value.general_logs_enabled, false) || coalesce(each.value.audit_logs_enabled, false)) ? [1] : []
    content {
      general = coalesce(each.value.general_logs_enabled, false)
      audit   = coalesce(each.value.audit_logs_enabled, false)
    }
  }

  // Maintenance window (optional, only when all fields are provided)
  dynamic "maintenance_window_start_time" {
    for_each = (each.value.maintenance_day_of_week != null && each.value.maintenance_time_of_day != null && each.value.maintenance_time_zone != null) ? [1] : []
    content {
      day_of_week = each.value.maintenance_day_of_week
      time_of_day = each.value.maintenance_time_of_day
      time_zone   = each.value.maintenance_time_zone
    }
  }

  // Users for the broker (at least one required); optional fields normalized in locals
  dynamic "user" {
    for_each = each.value.users
    iterator = user
    content {
      username       = user.value.username
      password       = user.value.password
      console_access = coalesce(user.value.console_access, false)
      groups         = user.value.groups
    }
  }

  // Tags: global + per-broker + created_date
  tags = merge(
    var.tags,
    each.value.tags,
    {
      CreatedDate = local.created_date
    }
  )
}

