#############################################
# Wrapper - Variables                       #
#############################################

variable "region" {
  description = "AWS region (e.g., us-east-1)"
  type        = string
}
variable "function_name" {
  description = "Lambda function name (e.g., example-lambda)"
  type        = string
}
variable "runtime" {
  description = "Lambda runtime (e.g., python3.11, nodejs20.x)"
  type        = string
}
variable "handler" {
  description = "Lambda handler (e.g., index.handler)"
  type        = string
}

variable "package_type" {
  description = "Package type: Zip or Image (e.g., Zip)"
  type        = string
  default     = "Zip"
}
variable "filename" {
  description = "Zip package file path (e.g., ./builds/example-lambda.zip)"
  type        = string
  default     = null
}
variable "image_uri" {
  description = "Container image URI (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/example:latest)"
  type        = string
  default     = null
}
variable "s3_bucket" {
  description = "S3 bucket for Zip package (e.g., my-bucket)"
  type        = string
  default     = null
}
variable "s3_key" {
  description = "S3 object key for Zip package (e.g., lambda/builds/example-lambda.zip)"
  type        = string
  default     = null
}
variable "s3_object_version" {
  description = "Optional S3 object version (e.g., 3Lg1Qsa7H2KfC0...)"
  type        = string
  default     = null
}
variable "source_code_hash" {
  description = "SHA256 base64 of package (e.g., filebase64sha256(\"./builds/example-lambda.zip\"))"
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Memory size in MB (e.g., 256)"
  type        = number
  default     = 128
}
variable "reserved_concurrent_executions" {
  description = "Reserved concurrency (e.g., 5)"
  type        = number
  default     = null
}
variable "timeout" {
  description = "Timeout seconds (e.g., 10)"
  type        = number
  default     = 3
}
variable "architectures" {
  description = "Architectures (e.g., [\"x86_64\"] or [\"arm64\"])"
  type        = list(string)
  default     = ["x86_64"]
}

variable "environment" {
  description = "Env vars map (e.g., { STAGE = \"dev\" })"
  type        = map(string)
  default     = null
}
variable "vpc_subnet_ids" {
  description = "VPC subnet IDs (e.g., [\"subnet-0123abc\", \"subnet-0456def\"])"
  type        = list(string)
  default     = null
}
variable "vpc_security_group_ids" {
  description = "VPC security group IDs (e.g., [\"sg-0abc123\"])"
  type        = list(string)
  default     = null
}

variable "enable_dlq" {
  description = "Enable DLQ (true/false)"
  type        = bool
  default     = false
}
variable "enable_log_group" {
  description = "Enable log group (true/false)"
  type        = bool
  default     = true
}
variable "log_retention_in_days" {
  description = "Log retention days (e.g., 14)"
  type        = number
  default     = null
}
variable "tracing_mode" {
  description = "Tracing mode (e.g., Active or PassThrough)"
  type        = string
  default     = null
}
variable "ephemeral_storage_size" {
  description = "Ephemeral storage MB (e.g., 1024)"
  type        = number
  default     = null
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "create_iam_role" {
  description = "Create IAM role"
  type        = bool
  default     = true
}
variable "role_name" {
  description = "Existing role name"
  type        = string
  default     = null
}
variable "role_arn" {
  description = "Existing role ARN"
  type        = string
  default     = null
}
variable "managed_policy_arns" {
  description = "Managed policy ARNs"
  type        = list(string)
  default     = null
}
variable "inline_policy_json" {
  description = "Inline policy JSON"
  type        = string
  default     = null
}

variable "permissions" {
  description = "Lambda permissions list (e.g., [{ principal = \"apigateway.amazonaws.com\", source_arn = \"arn:aws:execute-api:...\" }])"
  type = list(object({
    principal    = string
    action       = optional(string)
    source_arn   = optional(string)
    statement_id = optional(string)
  }))
  default = null
}

variable "event_source_mappings" {
  description = "Event source mappings (e.g., [{ uuid = \"sqs-1\", event_source_arn = \"arn:aws:sqs:...\" }])"
  type = list(object({
    uuid                               = string
    event_source_arn                   = string
    batch_size                         = optional(number)
    maximum_batching_window_in_seconds = optional(number)
    enabled                            = optional(bool)
    starting_position                  = optional(string)
    filter_criteria                    = optional(any)
    destination_config                 = optional(any)
    scaling_config                     = optional(any)
  }))
  default = null
}

variable "enable_provisioned_concurrency" {
  description = "Enable provisioned concurrency (true/false)"
  type        = bool
  default     = false
}
variable "provisioned_concurrency_alias" {
  description = "Alias name for provisioned concurrency (e.g., live)"
  type        = string
  default     = null
}
variable "provisioned_concurrent_executions" {
  description = "Provisioned concurrent executions (e.g., 3)"
  type        = number
  default     = null
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for provisioned concurrency (true/false)"
  type        = bool
  default     = false
}
variable "autoscaling_alias" {
  description = "Alias to scale via target tracking (e.g., live)"
  type        = string
  default     = null
}
variable "autoscaling_target_value" {
  description = "Target value for provisioned concurrency utilization (e.g., 0.7)"
  type        = number
  default     = 0.7
}
variable "autoscaling_min_capacity" {
  description = "Minimum provisioned concurrency (e.g., 1)"
  type        = number
  default     = 1
}
variable "autoscaling_max_capacity" {
  description = "Maximum provisioned concurrency (e.g., 10)"
  type        = number
  default     = 10
}

variable "enable_function_url" {
  description = "Enable function URL (true/false)"
  type        = bool
  default     = false
}
variable "function_url_auth_type" {
  description = "URL auth type (NONE or AWS_IAM)"
  type        = string
  default     = "NONE"
}
variable "function_url_cors_allow_credentials" {
  description = "CORS allow credentials (true/false)"
  type        = bool
  default     = null
}
variable "function_url_cors_allow_headers" {
  description = "CORS allow headers (e.g., [\"*\"])"
  type        = list(string)
  default     = null
}
variable "function_url_cors_allow_methods" {
  description = "CORS allow methods (e.g., [\"GET\", \"POST\"])"
  type        = list(string)
  default     = null
}
variable "function_url_cors_allow_origins" {
  description = "CORS allow origins (e.g., [\"*\"])"
  type        = list(string)
  default     = null
}
variable "function_url_cors_expose_headers" {
  description = "CORS expose headers (e.g., [\"x-request-id\"])"
  type        = list(string)
  default     = null
}
variable "function_url_cors_max_age" {
  description = "CORS max age seconds (e.g., 3600)"
  type        = number
  default     = null
}
