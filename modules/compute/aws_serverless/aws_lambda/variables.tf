#############################################
# AWS Lambda Module - Variables             #
# Defines required and optional inputs.     #
#############################################

variable "region" {
  description = "AWS region to deploy the Lambda function"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime (e.g., python3.11, nodejs20.x)"
  type        = string
}

variable "handler" {
  description = "Handler for the Lambda (e.g., index.handler)"
  type        = string
}

variable "package_type" {
  description = "Package type: Zip or Image"
  type        = string
  default     = "Zip"
}

variable "filename" {
  description = "Path to deployment package when package_type is Zip"
  type        = string
  default     = null
}

variable "image_uri" {
  description = "Image URI when package_type is Image"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package (Zip)"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 object key for the deployment package (Zip)"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "Optional S3 object version for the deployment package"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Base64-encoded SHA256 hash of the deployment package"
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Memory size for the Lambda function"
  type        = number
  default     = 128
}

variable "reserved_concurrent_executions" {
  description = "Reserved concurrency limit for the Lambda function"
  type        = number
  default     = null
}

variable "timeout" {
  description = "Timeout in seconds"
  type        = number
  default     = 3
}

variable "architectures" {
  description = "Instruction set architecture: [\"x86_64\"], [\"arm64\"]"
  type        = list(string)
  default     = ["x86_64"]
}

variable "environment" {
  description = "Map of environment variables"
  type        = map(string)
  default     = null
}

variable "vpc_subnet_ids" {
  description = "List of subnet IDs for VPC config"
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs for VPC config"
  type        = list(string)
  default     = null
}

variable "enable_dlq" {
  description = "Enable SQS dead-letter queue"
  type        = bool
  default     = false
}

variable "enable_log_group" {
  description = "Create CloudWatch log group to control retention"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Log retention in days"
  type        = number
  default     = null
}

variable "tracing_mode" {
  description = "X-Ray tracing mode: Active or PassThrough"
  type        = string
  default     = null
}

variable "ephemeral_storage_size" {
  description = "Ephemeral storage size in MB (512-10240)"
  type        = number
  default     = null
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "create_iam_role" {
  description = "If true, create IAM role for Lambda"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Existing IAM role name to use (optional)"
  type        = string
  default     = null
}

variable "role_arn" {
  description = "Existing IAM role ARN to use (optional)"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to role"
  type        = list(string)
  default     = null
}

variable "inline_policy_json" {
  description = "IAM inline policy JSON to attach to role"
  type        = string
  default     = null
}

variable "permissions" {
  description = "List of Lambda permissions to allow invoke"
  type = list(object({
    principal    = string
    action       = optional(string)
    source_arn   = optional(string)
    statement_id = optional(string)
  }))
  default = null
}

variable "event_source_mappings" {
  description = "List of event source mapping objects"
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
  description = "Enable provisioned concurrency on a specific alias/version"
  type        = bool
  default     = false
}

variable "provisioned_concurrency_alias" {
  description = "Lambda alias name to apply provisioned concurrency"
  type        = string
  default     = null
}

variable "provisioned_concurrent_executions" {
  description = "Number of provisioned concurrent executions"
  type        = number
  default     = null
}

# Autoscaling (target tracking) for provisioned concurrency
variable "enable_autoscaling" {
  description = "Enable Application Auto Scaling target tracking for provisioned concurrency"
  type        = bool
  default     = false
}

variable "autoscaling_alias" {
  description = "Alias name to scale (typically same as provisioned_concurrency_alias)"
  type        = string
  default     = null
}

variable "autoscaling_target_value" {
  description = "Target value for LambdaProvisionedConcurrencyUtilization (e.g., 0.7)"
  type        = number
  default     = 0.7
}

variable "autoscaling_min_capacity" {
  description = "Minimum provisioned concurrency capacity"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum provisioned concurrency capacity"
  type        = number
  default     = 10
}

variable "enable_function_url" {
  description = "Enable function URL"
  type        = bool
  default     = false
}

variable "function_url_auth_type" {
  description = "Function URL authorization type: NONE or AWS_IAM"
  type        = string
  default     = "NONE"
}

variable "function_url_cors_allow_credentials" {
  description = "CORS allow credentials"
  type        = bool
  default     = null
}

variable "function_url_cors_allow_headers" {
  description = "CORS allow headers"
  type        = list(string)
  default     = null
}

variable "function_url_cors_allow_methods" {
  description = "CORS allow methods"
  type        = list(string)
  default     = null
}

variable "function_url_cors_allow_origins" {
  description = "CORS allow origins"
  type        = list(string)
  default     = null
}

variable "function_url_cors_expose_headers" {
  description = "CORS expose headers"
  type        = list(string)
  default     = null
}

variable "function_url_cors_max_age" {
  description = "CORS max age"
  type        = number
  default     = null
}
