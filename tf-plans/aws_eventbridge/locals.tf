locals {
  # Compute a one-time created_date stamp merged into var.tags before passing to the module.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # ── Rule definitions ─────────────────────────────────────────────────────
  # Rules are defined here rather than terraform.tfvars so that event patterns
  # and input templates can be loaded from readable JSON files via file().
  rules_config = [

    # Rule 1: Scheduled daily report — fires at 08:00 UTC every day.
    # Triggers a Lambda function to generate a daily cost/utilisation report.
    {
      key                 = "daily-report"
      name                = "daily-cost-report"
      description         = "Triggers daily cost report Lambda at 08:00 UTC"
      bus_name            = "default"
      schedule_expression = "cron(0 8 * * ? *)"
      enabled             = true
      tags                = { schedule = "daily" }

      targets = [
        {
          target_key = "report-lambda"
          target_id  = "DailyCostReportLambda"
          arn        = "arn:aws:lambda:us-east-1:123456789012:function:daily-cost-report"
          # Limit retries to 3 within 1 hour for scheduled jobs.
          retry_policy = {
            max_event_age_in_seconds = 3600
            max_retry_attempts       = 3
          }
        }
      ]
    },

    # Rule 2: EC2 Instance State Change → SQS + Lambda.
    # Matches EC2 stop/terminate events; sends to SQS for async processing and
    # Lambda for real-time alerting. Undeliverable events land in a DLQ.
    {
      key         = "ec2-state-change"
      name        = "ec2-instance-state-changes"
      description = "Route EC2 stopped/terminated events to SQS and alerting Lambda"
      bus_name    = "default"
      enabled     = true
      tags        = { alert-type = "infrastructure" }
      # Load the event filter pattern from a dedicated JSON file.
      event_pattern = file("${path.module}/templates/ec2-state-change-pattern.json")

      targets = [
        # Target 1: SQS queue for async audit/processing with a DLQ.
        {
          target_key      = "ec2-sqs"
          target_id       = "EC2StateChangeSQS"
          arn             = "arn:aws:sqs:us-east-1:123456789012:ec2-state-changes"
          dead_letter_arn = "arn:aws:sqs:us-east-1:123456789012:ec2-events-dlq"
          retry_policy = {
            max_event_age_in_seconds = 7200
            max_retry_attempts       = 10
          }
        },
        # Target 2: Lambda with input transformer — reshape event fields before delivery.
        # The template JSON is loaded from a file for readability.
        {
          target_key = "ec2-lambda"
          target_id  = "EC2StateChangeLambda"
          arn        = "arn:aws:lambda:us-east-1:123456789012:function:ec2-alerting"
          input_transformer = {
            input_paths = {
              instance_id = "$.detail.instance-id"
              state       = "$.detail.state"
              region      = "$.region"
            }
            # Load the output shape from a dedicated JSON template file.
            input_template = file("${path.module}/templates/ec2-lambda-input-template.json")
          }
        }
      ]
    },

    # Rule 3: Custom bus — OrderPlaced → Step Functions.
    # Routes confirmed order events from the ecommerce bus to a state machine
    # for automated order fulfillment orchestration.
    {
      key         = "order-placed"
      name        = "order-placed-fulfillment"
      description = "Trigger order fulfillment workflow on OrderPlaced events"
      bus_name    = "ecommerce-events"
      enabled     = true
      tags        = { domain = "orders" }
      # Load the event filter pattern from a dedicated JSON file.
      event_pattern = file("${path.module}/templates/order-placed-pattern.json")

      targets = [
        {
          target_key = "order-sfn"
          target_id  = "OrderFulfillmentStateMachine"
          arn        = "arn:aws:states:us-east-1:123456789012:stateMachine:order-fulfillment"
          # IAM role that grants EventBridge permission to start the state machine.
          role_arn = "arn:aws:iam::123456789012:role/EventBridgeStepFunctionsRole"
        }
      ]
    },

    # Rule 4: S3 Object Created → Lambda (disabled — pending review).
    # Routes S3 object-created events to an image processing Lambda.
    # Disabled until reviewed for production readiness.
    {
      key         = "s3-upload"
      name        = "s3-image-upload-processor"
      description = "Route new S3 image uploads to the image processor Lambda"
      bus_name    = "default"
      enabled     = false
      tags        = { status = "pending-review" }
      # Load the event filter pattern from a dedicated JSON file.
      event_pattern = file("${path.module}/templates/s3-upload-pattern.json")

      targets = [
        {
          target_key = "image-lambda"
          target_id  = "ImageProcessorLambda"
          arn        = "arn:aws:lambda:us-east-1:123456789012:function:image-processor"
        }
      ]
    }
  ]
}
