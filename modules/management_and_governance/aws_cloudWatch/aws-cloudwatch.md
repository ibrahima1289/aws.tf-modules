# Amazon CloudWatch

Amazon CloudWatch is a monitoring and observability service that provides data and actionable insights for AWS, hybrid, and on-premises applications and infrastructure resources. CloudWatch collects monitoring and operational data in the form of logs, metrics, and events, providing you with a unified view of your AWS resources, applications, and services.

## Core Concepts

*   **Monitoring and Observability:** CloudWatch helps you monitor your applications, understand and respond to system-wide performance changes, optimize resource utilization, and get a unified view of operational health.
*   **Logs, Metrics, Events:** CloudWatch collects and processes these three types of data.
*   **Alarms:** You can set alarms on metrics to be notified or to trigger automated actions when a threshold is breached.
*   **Dashboards:** Visualize your metrics and logs in customizable dashboards.

## Key Components and Configuration

### 1. CloudWatch Metrics

*   **Time-Ordered Data Points:** Metrics are numerical data points that represent the performance of your resources and applications over time.
*   **Dimensions:** Metrics are uniquely identified by a name, namespace, and zero or more dimensions (name/value pairs that uniquely identify a metric).
*   **Granularity:** Standard metrics have a 1-minute granularity. Custom metrics can be stored at 1-second (high-resolution) or 1-minute granularity.
*   **Automatic Metrics:** Many AWS services (EC2, RDS, Lambda, S3, etc.) automatically publish metrics to CloudWatch.
*   **Custom Metrics:** You can publish your own custom metrics from your applications or on-premises servers using the CloudWatch PutMetricData API or the CloudWatch Agent.
*   **Real-life Example:**
    *   **AWS Service Metric:** The `CPUUtilization` metric for an EC2 instance, with `InstanceId` as a dimension.
    *   **Custom Metric:** Your application publishes a `SuccessfulLogins` metric, with `ApplicationName` as a dimension, to track user login success rates.

### 2. CloudWatch Logs

*   **Centralized Log Management:** CloudWatch Logs allows you to centralize logs from all of your systems, applications, and AWS services.
*   **Log Groups:** Logs are organized into log groups.
*   **Log Streams:** Each log group contains one or more log streams, which are sequences of log events from a common source.
*   **Log Retention:** Configure how long logs are retained (from never expiring to several years).
*   **Log Filtering and Search:** You can search and filter log events based on keywords, phrases, or patterns.
*   **Metric Filters:** You can create metric filters from log data to extract numerical values from logs and transform them into CloudWatch metrics.
*   **Real-life Example:**
    *   **Lambda Logs:** All logs from your AWS Lambda functions are automatically sent to CloudWatch Logs in a log group `/aws/lambda/<function-name>`.
    *   **EC2 Instance Logs:** You install the CloudWatch Agent on your EC2 instances to send application logs (e.g., Nginx access logs, custom application logs) to CloudWatch Logs.
    *   **Metric Filter:** You create a metric filter that counts the number of "ERROR" occurrences in your application logs and creates a custom metric for it.

### 3. CloudWatch Events (now integrated with Amazon EventBridge)

*   **Event-Driven Automation:** CloudWatch Events (now largely superseded by Amazon EventBridge, though the underlying service components are similar) delivers a near real-time stream of system events that describe changes in AWS resources.
*   **Rules:** You define rules that match incoming events and route them to one or more targets for processing.
*   **Scheduled Events:** Rules can also be configured to trigger on a schedule (e.g., cron or rate expressions).
*   **Real-life Example:** A rule is configured to detect when an EC2 instance stops. This event triggers an AWS Lambda function that sends a notification to an SNS topic.

### 4. CloudWatch Alarms

*   **Threshold Monitoring:** Alarms watch a single CloudWatch metric or a metric math expression and perform one or more actions when the metric crosses a defined threshold for a specified number of periods.
*   **Actions:**
    *   **SNS Notification:** Send a notification to an Amazon SNS topic.
    *   **Auto Scaling Action:** Trigger an Auto Scaling policy to scale out or scale in your EC2 instances.
    *   **EC2 Action:** Stop, terminate, reboot, or recover an EC2 instance.
    *   **Systems Manager OpsItem:** Create an OpsItem in AWS Systems Manager OpsCenter.
    *   **Real-life Example:** You create an alarm on the `CPUUtilization` metric for your web server Auto Scaling group. If the average CPU utilization exceeds 70% for 5 consecutive minutes, the alarm triggers an Auto Scaling policy to add more web server instances.

### 5. CloudWatch Dashboards

*   **Customizable Visualizations:** Dashboards allow you to create custom views of your CloudWatch metrics and alarms.
*   **Widgets:** Add widgets to display line graphs, stacked area graphs, numbers, text, and alarms.
*   **Real-time Insights:** Provides a single pane of glass to monitor the operational health of your applications and infrastructure.
*   **Real-life Example:** A DevOps team creates a dashboard that displays critical metrics for their production web application, including CPU utilization, request count, error rates, and active alarms, giving them a real-time overview of system health.

### 6. CloudWatch Agent

*   **Collects System/Application Logs and Metrics:** A unified agent that collects metrics and logs from EC2 instances and on-premises servers.
*   **Configuration:** Configured using a JSON file.
*   **Real-life Example:** The CloudWatch Agent is installed on your EC2 instances to collect host-level metrics (e.g., memory usage, disk usage) that are not natively provided by EC2, and also to collect custom application logs.

## Purpose and Real-Life Use Cases

*   **Application Performance Monitoring (APM):** Monitoring the performance of your web applications, APIs, and microservices.
*   **Infrastructure Monitoring:** Keeping an eye on the health and performance of your EC2 instances, RDS databases, load balancers, and other AWS resources.
*   **Log Management and Analysis:** Centralizing and analyzing logs from various sources for troubleshooting, security auditing, and compliance.
*   **Automated Remediation:** Setting up alarms that automatically trigger actions (e.g., scaling, restarting instances) in response to operational issues.
*   **Cost Optimization:** Monitoring resource utilization to identify underutilized resources that can be scaled down or terminated.
*   **Business Activity Monitoring:** Tracking custom business metrics (e.g., number of new users, orders placed) to gain real-time insights into business performance.

CloudWatch is a foundational service for operational excellence, providing the tools needed to monitor, troubleshoot, and optimize your entire AWS environment.
