# Comprehensive example terraform.tfvars for AWS SNS wrapper

region = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
}

topics = {
  # 1) Minimal standard topic using defaults
  events_standard_minimal = {
    name = "example-events-topic-minimal"
  }

  # 2) Standard topic with all core options and custom tags
  events_standard_full = {
    name              = "example-events-topic-full"
    display_name      = "Example Events"
    kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000" # replace with your KMS key ARN

    # Topic access policy (who can publish/subscribe)
    policy_json = <<POLICY
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::123456789012:role/publisher-role"},
            "Action": ["sns:Publish"],
            "Resource": "arn:aws:sns:us-east-1:123456789012:example-events-topic-full"
          }
        ]
      }
      POLICY

    # Delivery policy (e.g., retry/backoff config), left simple here
    delivery_policy = <<DELIVERY
      {"healthyRetryPolicy": {"numRetries": 3}}
      DELIVERY

    tags = {
      Purpose = "events-standard-full"
      Owner   = "platform-team"
    }
  }

  # 3) FIFO topic with content-based deduplication
  events_fifo = {
    name                        = "example-events-fifo" # .fifo suffix auto-added by module if missing
    fifo_topic                  = true
    content_based_deduplication = true

    tags = {
      Purpose = "events-fifo"
    }
  }

  # 4) Notifications topic demonstrating multiple subscription features
  notifications = {
    name = "example-notifications-topic"

    subscriptions = [
      # Simple email subscription
      {
        protocol = "email"
        endpoint = "ops@example.com"
      },

      # Lambda subscriber with raw message delivery
      {
        protocol             = "lambda"
        endpoint             = "arn:aws:lambda:us-east-1:123456789012:function:notification-handler" # replace with your Lambda ARN
        raw_message_delivery = true
      },

      # SQS subscriber with filter policy and DLQ redrive policy
      {
        protocol      = "sqs"
        endpoint      = "arn:aws:sqs:us-east-1:123456789012:notifications-queue" # replace with your SQS ARN
        filter_policy = <<FILTER
          {"eventType": ["CRITICAL", "HIGH"]}
          FILTER

        redrive_policy_arn = "arn:aws:sqs:us-east-1:123456789012:notifications-dlq" # replace with your DLQ ARN
      }
    ]
  }
}
