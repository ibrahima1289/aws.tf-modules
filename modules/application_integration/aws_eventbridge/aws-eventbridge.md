# Amazon EventBridge

Amazon EventBridge is a serverless event bus service that makes it easy to connect applications together using data from your own applications, integrated SaaS applications, and AWS services. EventBridge simplifies the process of building event-driven architectures, allowing applications to communicate without being tightly coupled.

## Core Concepts

*   **Event-Driven Architecture:** EventBridge enables you to build scalable and resilient event-driven applications.
*   **Event Bus:** A central point where events are sent and then routed to various targets.
*   **Decoupling:** Applications can produce events without knowing which consumers will process them, and consumers can process events without knowing their producers. This reduces interdependencies.
*   **Serverless:** EventBridge is fully managed, so there are no servers to provision or manage.

## Key Components and Configuration

### 1. Event Bus

An event bus receives events and delivers them to targets. EventBridge supports three types of event buses:

*   **Default Event Bus:** Every AWS account has a default event bus that automatically receives events from AWS services (e.g., EC2 instance state changes, S3 object uploads).
*   **Custom Event Buses:** You can create custom event buses to receive events from your own applications.
*   **Partner Event Buses:** For receiving events from SaaS applications (e.g., Shopify, Zendesk, PagerDuty).

### 2. Rules

A rule matches incoming events and routes them to targets. Each rule can specify an event pattern that determines which events it processes.

*   **Event Pattern:** A JSON object that defines the structure of events that a rule should match. You can match on any part of an event, including the source, detail-type, or specific fields within the event's detail.
    *   **Real-life Example:**
        ```json
        {
          "source": ["aws.s3"],
          "detail-type": ["Object Created"],
          "detail": {
            "bucket": {
              "name": ["my-image-uploads"]
            },
            "object": {
              "key": [{ "prefix": "new-images/" }]
            }
          }
        }
        ```
        This pattern matches events where an object is created in the `my-image-uploads` S3 bucket, specifically if the object key starts with `new-images/`.
*   **Schedule Expressions:** You can create rules that trigger on a regular schedule (e.g., every 5 minutes, every day at 8 AM UTC) using cron or rate expressions.
    *   **Real-life Example:** A scheduled rule that runs a Lambda function every hour to check for new data in an external API.

### 3. Targets

A target is an AWS resource or API destination that EventBridge sends an event to when the event matches a rule.

*   **Common Targets:**
    *   **AWS Lambda Function:** Execute a serverless function in response to an event.
    *   **Amazon SQS Queue:** Send events to a queue for asynchronous processing.
    *   **Amazon SNS Topic:** Publish events to a topic to notify multiple subscribers.
    *   **Amazon Kinesis Data Streams:** Send events to a stream for real-time analytics.
    *   **AWS Step Functions State Machine:** Start a workflow in response to an event.
    *   **EC2 Instances:** Trigger actions on specific EC2 instances (e.g., reboot, stop).
    *   **API Destination:** Send events to an HTTP endpoint outside of AWS.
*   **Input Transformer:** Allows you to select specific parts of an event and/or combine them with static text to create a customized output sent to the target. This helps tailor the event data to the target's expected format.
*   **Retry Policy:** Configures how EventBridge retries sending events to a target if delivery fails (up to 24 hours).
*   **Dead-Letter Queues (DLQs):** You can configure a DLQ (an SQS queue) for a target. If EventBridge is unable to successfully deliver an event to a target after exhausting the retry policy, the event is sent to the DLQ. This prevents data loss and allows for later inspection and reprocessing of failed events.

## Event Replays and Archives

*   **Event Archives:** You can create an archive of events from any event bus for a specified retention period (from 1 day to indefinite). This allows you to replay past events.
*   **Event Replays:** You can replay events from an archive to an event bus or to specific rules. This is useful for testing new features with historical data, recovering from errors, or backfilling data.
*   **Real-life Example:** You deploy a new microservice that needs to process all user sign-up events from the past year. Instead of running a complex data migration, you can replay the `UserSignedUp` events from your archive to the new microservice's rule.

## Purpose and Real-Life Use Cases

*   **Building Event-Driven Architectures:** Decoupling services in microservices architectures. When one service performs an action (e.g., a "ProductUpdated" event), it publishes an event, and other services can react without direct dependencies.
*   **Application Integration:** Connecting various AWS services (e.g., Lambda, SQS, SNS), your own custom applications, and SaaS applications (via Partner Event Buses) to create integrated workflows.
*   **Monitoring and Alerting:** Responding to changes in AWS resources (e.g., an EC2 instance stopping, a security group being modified) to trigger alerts or automated remediation.
*   **Scheduled Tasks:** Running routine jobs (e.g., daily reports, nightly backups) using schedule expressions.
*   **Serverless Workflows:** Orchestrating complex serverless workflows with AWS Step Functions, triggered by EventBridge events.
*   **Auditing and Compliance:** Archiving events for auditing purposes and replaying them to ensure new systems correctly process historical data.

EventBridge is a powerful tool for creating flexible, scalable, and resilient event-driven systems on AWS.
