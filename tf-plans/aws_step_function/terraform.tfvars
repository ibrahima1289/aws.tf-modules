# Example configuration for the AWS Step Functions wrapper plan
# - Sets region and optional global tags
# - Defines one or more state machines with ASL definitions
# - Demonstrates STANDARD and EXPRESS types with logging and tracing options

region = "us-east-1"

# Global tags applied to all resources created by the module
tags = {
  Environment = "dev"
  ManagedBy   = "Terraform"
}

# Define one or more Step Functions state machines
# Keys (simple_workflow, express_workflow, etc.) are used to key outputs

state_machines = {
  simple_workflow = {
    name     = "simple-hello-world"
    role_arn = "arn:aws:iam::123456789012:role/StepFunctionsExecutionRole"
    type     = "STANDARD"

    # Amazon States Language (ASL) JSON definition
    # Replace with your actual state machine definition
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

    # Optional logging configuration
    logging_enabled                = true
    logging_level                  = "ERROR" # Can be DEBUG, INFO, or ALL for more verbose logging
    logging_include_execution_data = true
    # Replace with your CloudWatch Logs group ARN
    logging_log_group_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vendedlogs/states/simple-workflow:*"

    # Optional X-Ray tracing
    tracing_enabled = true

    # Optional per-state-machine tags
    tags = {
      Workflow = "HelloWorld"
    }
  }

  # ---------------------------------------------------------------------------
  # Example of an EXPRESS state machine (uncomment and customize as needed)
  # ---------------------------------------------------------------------------
  # express_workflow = {
  #   name     = "express-high-volume"
  #   role_arn = "arn:aws:iam::123456789012:role/StepFunctionsExecutionRole"
  #   type     = "EXPRESS"
  #
  #   definition = <<-JSON
  #     {
  #       "Comment": "An Express workflow for high-volume, short-duration tasks",
  #       "StartAt": "ProcessEvent",
  #       "States": {
  #         "ProcessEvent": {
  #           "Type": "Task",
  #           "Resource": "arn:aws:lambda:us-east-1:123456789012:function:processEvent",
  #           "End": true
  #         }
  #       }
  #     }
  #   JSON
  #
  #   # Express workflows benefit from CloudWatch Logs for execution history
  #   logging_enabled                = true
  #   logging_level                  = "ERROR"
  #   logging_include_execution_data = false
  #   logging_log_group_arn          = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/vendedlogs/states/express-workflow:*"
  #
  #   # Optional encryption with KMS
  #   # kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"
  #
  #   tags = {
  #     Workflow = "ExpressExample"
  #   }
  # }

  # ---------------------------------------------------------------------------
  # Example of a state machine with encryption (uncomment as needed)
  # ---------------------------------------------------------------------------
  # encrypted_workflow = {
  #   name     = "encrypted-workflow"
  #   role_arn = "arn:aws:iam::123456789012:role/StepFunctionsExecutionRole"
  #   type     = "STANDARD"
  #
  #   definition = <<-JSON
  #     {
  #       "Comment": "A workflow with KMS encryption",
  #       "StartAt": "EncryptedTask",
  #       "States": {
  #         "EncryptedTask": {
  #           "Type": "Task",
  #           "Resource": "arn:aws:lambda:us-east-1:123456789012:function:encryptedTask",
  #           "End": true
  #         }
  #       }
  #     }
  #   JSON
  #
  #   # KMS key for encryption at rest
  #   kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abcd1234-5678-90ab-cdef-1234567890ab"
  #
  #   tracing_enabled = true
  # }
}
