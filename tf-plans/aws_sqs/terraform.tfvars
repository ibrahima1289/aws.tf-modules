# Comprehensive example terraform.tfvars for AWS SQS wrapper

region = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
}

queues = {
  # 1) Minimal standard queue using mostly defaults
  standard_minimal = {
    name = "example-standard-queue-minimal"
  }

  # 2) Standard queue with all core timing/size options set
  standard_tuned = {
    name                       = "example-standard-queue-tuned"
    delay_seconds              = 10            # delay delivery of new messages (seconds)
    maximum_message_size       = 131072        # 128 KiB
    message_retention_seconds  = 7 * 24 * 3600 # Min is 60s, max 14 days (default 4 days)
    receive_wait_time_seconds  = 20            # long polling (max 20s)
    visibility_timeout_seconds = 60            # seconds messages stay hidden while processed
    tags = {
      Purpose = "tuned-standard"
    }
  }

  # 3) FIFO queue with content-based deduplication
  fifo_basic = {
    # .fifo suffix will be auto-appended if missing by the module
    name                        = "example-fifo-queue-basic"
    fifo_queue                  = true
    content_based_deduplication = true
    visibility_timeout_seconds  = 90            # Min 0s, max 12h (default 30s)
    message_retention_seconds   = 4 * 24 * 3600 # Min 60s, max 14 days (default 4 days)
    tags = {
      Purpose = "fifo-basic"
    }
  }

  # 4) Standard queue with DLQ (dead-letter queue) using redrive_policy
  # NOTE: dead_letter_target_arn should point to an existing queue ARN (often created separately).
  standard_with_dlq = {
    name = "example-standard-queue-with-dlq"

    redrive_policy = {
      dead_letter_target_arn = "arn:aws:sqs:us-east-1:123456789012:example-dlq" # replace with your DLQ ARN
      max_receive_count      = 3                                                # Number of times a message can be received before moving to DLQ
    }

    tags = {
      Purpose = "with-dlq"
    }
  }

  # 5) FIFO queue with SSE-KMS encryption and custom data key reuse period
  fifo_encrypted = {
    name                        = "example-fifo-queue-encrypted" # .fifo auto-appended if needed
    fifo_queue                  = true
    content_based_deduplication = true

    kms_master_key_id                 = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000" # replace with your KMS key ARN
    kms_data_key_reuse_period_seconds = 300                                                                           # seconds to reuse the same data key for encryption (default 300s) and max is 7 days (604800s)

    visibility_timeout_seconds = 120 # Min 0s, max 12h (default 30s)
    tags = {
      Purpose = "fifo-encrypted"
    }
  }

  # 6) Standard queue with an inline resource policy (policy_json)
  # Example policy allows a specific IAM role to send messages.
  standard_with_policy = {
    name = "example-standard-queue-with-policy"

    policy_json = <<POLICY
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": {
              "AWS": "arn:aws:iam::123456789012:role/producer-role"
            },
            "Action": "sqs:SendMessage",
            "Resource": "arn:aws:sqs:us-east-1:123456789012:example-standard-queue-with-policy"
          }
        ]
      }
      POLICY

    tags = {
      Purpose = "with-policy"
    }
  }
}
