# AWS Step Functions Terraform Module

This module provisions one or more AWS Step Functions state machines with optional CloudWatch Logs logging, X-Ray tracing, and KMS encryption. It avoids null values by using safe defaults and only renders optional blocks when configured. All resources are tagged with a stable `CreatedDate`.

## Requirements
- Terraform >= 1.3
- AWS Provider >= 5.0

## Features
- Create multiple state machines via a keyed map (`state_machines`)
- Support for STANDARD (long-running) and EXPRESS (high-volume, short-duration) types
- Optional CloudWatch Logs logging with configurable levels
- Optional X-Ray tracing for observability
- Optional KMS encryption for data at rest
- Global and per-state-machine tags, including `CreatedDate`

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region for the provider |
| tags | map(string) | no | Global tags applied to all resources |
| state_machines | map(object) | no | Map of state machines keyed by unique names; see schema below |

### `state_machines` object schema
| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| name | string | yes | - | State machine name |
| role_arn | string | yes | - | IAM role ARN for execution |
| definition | string | yes | - | Amazon States Language (ASL) JSON definition |
| type | string | no | `STANDARD` | State machine type: `STANDARD` or `EXPRESS` |
| logging_enabled | bool | no | `false` | Enable CloudWatch Logs logging |
| logging_level | string | no | `ERROR` | Log level: `ALL`, `ERROR`, `FATAL`, or `OFF` |
| logging_include_execution_data | bool | no | `false` | Include input/output data in logs |
| logging_log_group_arn | string | no | `null` | CloudWatch Logs group ARN (required if `logging_enabled = true`) |
| tracing_enabled | bool | no | `false` | Enable X-Ray tracing |
| kms_key_arn | string | no | `null` | KMS key ARN for encryption at rest |
| tags | map(string) | no | `{}` | Per-state-machine tags merged with global tags |

## Outputs
- `state_machine_arns`: Map of state machine key -> state machine ARN
- `state_machine_names`: Map of state machine key -> state machine name
- `state_machine_ids`: Map of state machine key -> state machine ID

## Usage
```hcl
module "step_function" {
  source = "../../modules/application_integration/aws_step_function"
  region = var.region
  tags   = { Environment = "dev" }

  state_machines = {
    simple_workflow = {
      name     = "simple-hello-world"
      role_arn = "arn:aws:iam::123456789012:role/StepFunctionsExecutionRole"
      type     = "STANDARD"

      definition = jsonencode({
        Comment = "A simple Hello World state machine"
        StartAt = "HelloWorld"
        States = {
          HelloWorld = {
            Type   = "Pass"
            Result = "Hello, World!"
            End    = true
          }
        }
      })

      logging_enabled       = true
      logging_level         = "ALL"
      logging_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vendedlogs/states/simple-workflow:*"

      tracing_enabled = true
    }
  }
}
```

## Notes
- **IAM Role**: You must provide an existing IAM role ARN with appropriate permissions for Step Functions execution. The role should have:
  - Trust policy allowing `states.amazonaws.com` to assume the role
  - Permissions to invoke Lambda functions, access DynamoDB, SNS, SQS, or other services used in your state machine definition
- **CloudWatch Logs**: If `logging_enabled = true`, you must provide `logging_log_group_arn` pointing to an existing CloudWatch Logs group with `:*` suffix
- **KMS Encryption**: If `kms_key_arn` is provided, ensure the IAM role has `kms:Decrypt` and `kms:GenerateDataKey` permissions for the key
- **EXPRESS vs STANDARD**: EXPRESS state machines have a maximum execution time of 5 minutes and are optimized for high-volume workloads; STANDARD supports longer executions and preserves full execution history

## Examples
See [tf-plans/aws_step_function](../../tf-plans/aws_step_function/README.md) for a complete wrapper example with `terraform.tfvars`.
