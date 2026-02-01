# AWS Lambda Terraform Module

This module creates an AWS Lambda function with optional IAM role, policies, environment variables, VPC configuration, dead-letter queue (DLQ), CloudWatch log group retention, event source mappings, and a function URL.

## Usage

```hcl
module "lambda" {
  source = "../../modules/compute/aws_lambda"

  region        = var.region
  function_name = "my-func"
  runtime       = "python3.11"
  handler       = "index.handler"

  tags = {
    project = "demo"
  }

  environment = {
    STAGE = "dev"
  }

  enable_function_url = true
  function_url_auth_type = "NONE"
}
```

## Required Variables
- `region`: AWS region to deploy the Lambda.
- `function_name`: Name of the Lambda function.
- `runtime`: Lambda runtime (e.g., `python3.11`, `nodejs20.x`).
- `handler`: Function handler (e.g., `index.handler`).

## Optional Variables
- `package_type` (default `Zip`), `filename` (for Zip), `image_uri` (for Image), `source_code_hash`.
- `memory_size` (default `128`), `timeout` (default `3`), `architectures` (default `["x86_64"]`).
- `environment`: Map of environment variables.
- `vpc_subnet_ids`, `vpc_security_group_ids`: VPC configuration.
- `enable_dlq` (default `false`): Create SQS DLQ.
- `enable_log_group` (default `true`), `log_retention_in_days`.
- `tracing_mode`: `Active` or `PassThrough`.
- `ephemeral_storage_size`: MB 512-10240.
- `tags`: Common tags applied to resources.
- `create_iam_role` (default `true`): Create IAM role.
- `role_name`, `role_arn`: Use existing role.
- `managed_policy_arns`: Managed policy ARNs to attach.
- `inline_policy_json`: Inline IAM policy JSON.
- `permissions`: List of Lambda permissions to allow invoke.
- `event_source_mappings`: List of event source mapping objects.
- `enable_function_url` (default `false`): Enable function URL.
- `function_url_auth_type` (default `NONE`), CORS variables for function URL.

## Outputs
- `function_name`, `function_arn`, `role_arn`, `function_url`, `dlq_arn`.

## Notes
- All tags include a `created_date` from `locals` for auditability.
- Optional blocks are only rendered when inputs are provided to avoid nulls.
