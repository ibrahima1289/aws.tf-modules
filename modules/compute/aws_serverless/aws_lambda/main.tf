#############################################
# AWS Lambda Module - Main Configuration    #
# This file defines the core resources for  #
# an AWS Lambda function, including the     #
# function itself, optional IAM role/policy #
# attachments, environment variables, VPC   #
# config, dead-letter queue, and triggers.  #
#############################################

# data "aws_caller_identity" "current" {}

# Optionally create IAM role if not provided
resource "aws_iam_role" "lambda_role" {
  count = var.create_iam_role && var.role_name == null ? 1 : 0

  name               = var.role_name == null ? "${var.function_name}-role" : var.role_name
  assume_role_policy = local.assume_role_policy

  tags = merge(var.tags, {
    Name         = var.function_name,
    created_date = local.created_date
  })
}

# Optional managed policy attachments for the role
resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = var.create_iam_role && var.managed_policy_arns != null ? toset(var.managed_policy_arns) : []
  role       = coalesce(var.role_name, aws_iam_role.lambda_role[0].name)
  policy_arn = each.value
}

# Optional inline policy for the role
resource "aws_iam_role_policy" "inline" {
  count  = var.create_iam_role && var.inline_policy_json != null ? 1 : 0
  name   = "${var.function_name}-inline"
  role   = coalesce(var.role_name, aws_iam_role.lambda_role[0].name)
  policy = var.inline_policy_json
}

# Optional CloudWatch log group to control retention
resource "aws_cloudwatch_log_group" "lambda" {
  count             = var.enable_log_group && var.log_retention_in_days != null ? 1 : 0
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
  tags = merge(var.tags, {
    Name         = var.function_name,
    created_date = local.created_date
  })
}

# Optional Dead Letter Queue (SQS) for async failures
resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0
  name  = "${var.function_name}-dlq"
  tags  = merge(var.tags, { created_date = local.created_date })
}

# Lambda function definition
resource "aws_lambda_function" "function" {
  count = (
    var.package_type == "Image" && var.image_uri != null
    ) || (
    var.package_type == "Zip" && (
      var.filename != null || (var.s3_bucket != null && var.s3_key != null)
    )
  ) ? 1 : 0
  function_name = var.function_name
  role          = coalesce(var.role_arn, aws_iam_role.lambda_role[0].arn)
  runtime       = var.runtime
  handler       = var.handler

  # Only set filename or image_uri based on package type
  package_type      = var.package_type
  filename          = var.package_type == "Zip" && var.filename != null ? var.filename : null
  s3_bucket         = var.package_type == "Zip" && var.s3_bucket != null && var.s3_key != null ? var.s3_bucket : null
  s3_key            = var.package_type == "Zip" && var.s3_bucket != null && var.s3_key != null ? var.s3_key : null
  s3_object_version = var.package_type == "Zip" && var.s3_object_version != null ? var.s3_object_version : null
  image_uri         = var.package_type == "Image" && var.image_uri != null ? var.image_uri : null

  source_code_hash = var.source_code_hash
  publish          = true

  memory_size = var.memory_size
  timeout     = var.timeout

  reserved_concurrent_executions = var.reserved_concurrent_executions

  architectures = var.architectures

  # Environment variables (optional)
  dynamic "environment" {
    for_each = var.environment != null && length(var.environment) > 0 ? [1] : []
    content {
      variables = var.environment
    }
  }

  # VPC configuration (optional)
  dynamic "vpc_config" {
    for_each = var.vpc_subnet_ids != null && length(var.vpc_subnet_ids) > 0 && var.vpc_security_group_ids != null && length(var.vpc_security_group_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  # Dead letter config (optional)
  dynamic "dead_letter_config" {
    for_each = var.enable_dlq ? [1] : []
    content {
      target_arn = aws_sqs_queue.dlq[0].arn
    }
  }

  # Tracing config (optional)
  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  # Ephemeral storage (optional)
  dynamic "ephemeral_storage" {
    for_each = var.ephemeral_storage_size != null ? [1] : []
    content {
      size = var.ephemeral_storage_size
    }
  }

  tags = merge(var.tags, {
    Name         = var.function_name,
    created_date = local.created_date
  })
}
# Optional: create alias for provisioned concurrency
resource "aws_lambda_alias" "pc_alias" {
  count            = var.enable_provisioned_concurrency && var.provisioned_concurrency_alias != null && length(aws_lambda_function.function) > 0 ? 1 : 0
  name             = var.provisioned_concurrency_alias
  description      = "Alias for provisioned concurrency"
  function_name    = aws_lambda_function.function[0].function_name
  function_version = aws_lambda_function.function[0].version
}

# Optional: provisioned concurrency config
resource "aws_lambda_provisioned_concurrency_config" "pc" {
  count                             = var.enable_provisioned_concurrency && var.provisioned_concurrent_executions != null && length(aws_lambda_alias.pc_alias) > 0 ? 1 : 0
  function_name                     = aws_lambda_function.function[0].function_name
  qualifier                         = aws_lambda_alias.pc_alias[0].name
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  depends_on = [
    aws_lambda_function.function,
    aws_lambda_alias.pc_alias,
    aws_iam_role.lambda_role,
    aws_iam_role_policy_attachment.managed,
    aws_iam_role_policy.inline
  ]
}

# Application Auto Scaling target tracking for provisioned concurrency
resource "aws_appautoscaling_target" "lambda_pc" {
  count              = var.enable_autoscaling && var.autoscaling_alias != null && length(aws_lambda_function.function) > 0 ? 1 : 0
  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "function:${aws_lambda_function.function[0].function_name}:${var.autoscaling_alias}"
  scalable_dimension = "lambda:function:ProvisionedConcurrency"
  service_namespace  = "lambda"
}

resource "aws_appautoscaling_policy" "lambda_pc_policy" {
  count              = var.enable_autoscaling && length(aws_appautoscaling_target.lambda_pc) > 0 ? 1 : 0
  name               = "lambda-pc-tt-${aws_lambda_function.function[0].function_name}-${var.autoscaling_alias}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.lambda_pc[0].resource_id
  scalable_dimension = aws_appautoscaling_target.lambda_pc[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.lambda_pc[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "LambdaProvisionedConcurrencyUtilization"
    }
    target_value = var.autoscaling_target_value
  }
}

# Optional Lambda permission for event sources
resource "aws_lambda_permission" "allow_invoke" {
  for_each      = (var.permissions != null && length(aws_lambda_function.function) > 0) ? { for p in var.permissions : "${p.principal}-${coalesce(p.source_arn, "none")}" => p } : {}
  statement_id  = coalesce(each.value.statement_id, "AllowExecutionFrom-${each.value.principal}")
  action        = coalesce(each.value.action, "lambda:InvokeFunction")
  function_name = aws_lambda_function.function[0].function_name
  principal     = each.value.principal
  source_arn    = each.value.source_arn
}

# Optional event source mapping (e.g., SQS, Kinesis, DynamoDB Streams)
resource "aws_lambda_event_source_mapping" "mapping" {
  for_each                           = (var.event_source_mappings != null && length(aws_lambda_function.function) > 0) ? { for m in var.event_source_mappings : m.uuid => m } : {}
  event_source_arn                   = each.value.event_source_arn
  function_name                      = aws_lambda_function.function[0].arn
  batch_size                         = coalesce(each.value.batch_size, 10)
  maximum_batching_window_in_seconds = each.value.maximum_batching_window_in_seconds
  enabled                            = coalesce(each.value.enabled, true)
  starting_position                  = each.value.starting_position

  # Optional: filter_criteria block
  dynamic "filter_criteria" {
    for_each = try(each.value.filter_criteria, null) != null ? [each.value.filter_criteria] : []
    content {
      # Render one or more filter blocks when provided
      dynamic "filter" {
        for_each = try(filter_criteria.value.filters, null) != null ? filter_criteria.value.filters : []
        content {
          pattern = try(filter.value.pattern, null)
        }
      }
    }
  }

  # Optional: destination_config block
  dynamic "destination_config" {
    for_each = try(each.value.destination_config, null) != null ? [each.value.destination_config] : []
    content {
      dynamic "on_failure" {
        for_each = try(destination_config.value.on_failure, null) != null ? [destination_config.value.on_failure] : []
        content {
          destination_arn = try(on_failure.value.destination_arn, null)
        }
      }
    }
  }

  # Optional: scaling_config block (for SQS partial batch)
  dynamic "scaling_config" {
    for_each = try(each.value.scaling_config, null) != null ? [each.value.scaling_config] : []
    content {
      maximum_concurrency = try(scaling_config.value.maximum_concurrency, null)
    }
  }
}

# Optional function URL
resource "aws_lambda_function_url" "url" {
  count              = var.enable_function_url && length(aws_lambda_function.function) > 0 ? 1 : 0
  function_name      = aws_lambda_function.function[0].arn
  authorization_type = var.function_url_auth_type
  cors { # Only provided when values exist to avoid nulls
    allow_credentials = var.function_url_cors_allow_credentials
    allow_headers     = var.function_url_cors_allow_headers
    allow_methods     = var.function_url_cors_allow_methods
    allow_origins     = var.function_url_cors_allow_origins
    expose_headers    = var.function_url_cors_expose_headers
    max_age           = var.function_url_cors_max_age
  }
}
