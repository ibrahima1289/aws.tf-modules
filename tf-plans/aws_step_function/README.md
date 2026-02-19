# AWS Step Functions Wrapper (Examples)

This plan demonstrates using the Step Functions module to provision one or more state machines with optional logging, tracing, and encryption.

## Files
- provider.tf: Providers (AWS)
- variables.tf: Plan inputs (region, tags, state_machines)
- main.tf: Wires inputs to the module
- outputs.tf: Exposes module outputs
- terraform.tfvars: Example configuration

## Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|
| region | string | yes | AWS region |
| tags | map(string) | no | Global tags |
| state_machines | map(object) | no | State machines to create (see module README for schema) |

### `state_machines` object schema

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| name | string | yes | - | State machine name |
| role_arn | string | yes | - | IAM role ARN for execution |
| definition | string | yes | - | Amazon States Language (ASL) JSON definition |
| type | string | no | `STANDARD` | State machine type: `STANDARD` or `EXPRESS` |
| logging_enabled | bool | no | `false` | Enable CloudWatch Logs |
| logging_level | string | no | `ERROR` | Log level: `ALL`, `ERROR`, `FATAL`, or `OFF` |
| logging_include_execution_data | bool | no | `false` | Include input/output data in logs |
| logging_log_group_arn | string | no | `null` | CloudWatch Logs group ARN |
| tracing_enabled | bool | no | `false` | Enable X-Ray tracing |
| kms_key_arn | string | no | `null` | KMS key ARN for encryption at rest |
| tags | map(string) | no | `{}` | Per-state-machine tags merged with global tags |

## Example tfvars
```hcl
region = "us-east-1"

tags = { Environment = "dev" }

state_machines = {
  simple_workflow = {
    name     = "simple-hello-world"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsExecutionRole"
    type     = "STANDARD"

    definition = <<-JSON
      {
        "Comment": "A simple Hello World state machine",
        "StartAt": "HelloWorld",
        "States": {
          "HelloWorld": {
            "Type": "Pass",
            "Result": "Hello, World!",
            "End": true
          }
        }
      }
    JSON

    logging_enabled       = true
    logging_level         = "ALL"
    logging_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vendedlogs/states/simple-workflow:*"

    tracing_enabled = true
  }
}
```

## Usage
1. Customize `terraform.tfvars` with your state machine definitions and IAM role ARNs
2. Initialize and apply:
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```
