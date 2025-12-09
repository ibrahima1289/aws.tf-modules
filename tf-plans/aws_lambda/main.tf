#############################################
# Wrapper - AWS Lambda Plan                 #
# Required variables: region, function_name,
# runtime, handler. Optional variables are
# annotated inline below by grouping.
#############################################

module "lambda" {
  source = "../../modules/compute/aws_lambda"

  region        = var.region
  function_name = var.function_name
  runtime       = var.runtime
  handler       = var.handler

  package_type      = var.package_type
  filename          = var.filename
  image_uri         = var.image_uri
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version
  source_code_hash  = var.source_code_hash

  memory_size                    = var.memory_size
  timeout                        = var.timeout
  architectures                  = var.architectures
  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Optional: Environment variables
  environment = var.environment

  # Optional: VPC configuration
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  # Optional: DLQ, Log retention, X-Ray, Ephemeral storage
  enable_dlq             = var.enable_dlq
  enable_log_group       = var.enable_log_group
  log_retention_in_days  = var.log_retention_in_days
  tracing_mode           = var.tracing_mode
  ephemeral_storage_size = var.ephemeral_storage_size

  tags = merge(var.tags, { created_date = local.created_date })

  # Optional: Use existing IAM role or attach policies
  create_iam_role     = var.create_iam_role
  role_name           = var.role_name
  role_arn            = var.role_arn
  managed_policy_arns = var.managed_policy_arns
  inline_policy_json  = var.inline_policy_json

  # Optional: Permissions and event source mappings
  permissions           = var.permissions
  event_source_mappings = var.event_source_mappings

  # Optional: Function URL and CORS settings
  enable_function_url                 = var.enable_function_url
  function_url_auth_type              = var.function_url_auth_type
  function_url_cors_allow_credentials = var.function_url_cors_allow_credentials
  function_url_cors_allow_headers     = var.function_url_cors_allow_headers
  function_url_cors_allow_methods     = var.function_url_cors_allow_methods
  function_url_cors_allow_origins     = var.function_url_cors_allow_origins
  function_url_cors_expose_headers    = var.function_url_cors_expose_headers
  function_url_cors_max_age           = var.function_url_cors_max_age

  # Optional: Provisioned concurrency
  enable_provisioned_concurrency    = var.enable_provisioned_concurrency
  provisioned_concurrency_alias     = var.provisioned_concurrency_alias
  provisioned_concurrent_executions = var.provisioned_concurrent_executions

  # Optional: Autoscaling (target tracking) for provisioned concurrency
  enable_autoscaling       = var.enable_autoscaling
  autoscaling_alias        = var.autoscaling_alias
  autoscaling_target_value = var.autoscaling_target_value
  autoscaling_min_capacity = var.autoscaling_min_capacity
  autoscaling_max_capacity = var.autoscaling_max_capacity
}
