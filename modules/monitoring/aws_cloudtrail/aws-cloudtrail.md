# AWS CloudTrail

AWS CloudTrail is a service that enables governance, compliance, operational auditing, and risk auditing of your AWS account. CloudTrail records API calls made on your account and delivers log files to you, providing visibility into user activity, resource changes, and actions taken through the AWS Management Console, AWS SDKs, command-line tools, and other AWS services.

## Core Concepts

- **API Activity Logging:** CloudTrail captures every API call made within your AWS account — who made it, from where, when, and what was affected.
- **Event History:** A searchable, downloadable, and immutable 90-day record of management events is available by default, at no extra charge.
- **Trails:** A trail is a configuration that enables continuous delivery of CloudTrail events to an S3 bucket, CloudWatch Logs, and/or CloudWatch Events.
- **Governance and Compliance:** CloudTrail is foundational for security audits, compliance frameworks (PCI-DSS, HIPAA, SOC), and incident investigation.

---

## Key Components and Configuration

### 1. CloudTrail Events

CloudTrail records three types of events:

| Event Type | Description |
|---|---|
| **Management Events** | Operations performed on AWS resources (e.g., `CreateBucket`, `RunInstances`, `AttachRolePolicy`). Enabled by default. |
| **Data Events** | Resource-level operations such as S3 object-level activity (`GetObject`, `PutObject`) and Lambda function invocations. Must be explicitly enabled. |
| **Insights Events** | Detects unusual activity in your account — e.g., a sudden spike in API calls or IAM errors — by comparing against a baseline. |

- **Real-life Example:**
  - A developer deletes an S3 bucket. CloudTrail records a **management event** showing the IAM user, timestamp, source IP, and the bucket ARN.
  - A Lambda function reads sensitive files from S3. With data events enabled, CloudTrail records every `GetObject` call, which object was accessed, and by which principal.

---

### 2. Trails

A trail configures where and how CloudTrail delivers logs.

- **Single-Region vs. Multi-Region Trail:** A multi-region trail captures events from all AWS regions and is recommended for comprehensive coverage.
- **Organization Trail:** An AWS Organizations trail captures events from all member accounts within an organization into a single S3 bucket.
- **S3 Delivery:** Log files are delivered to a designated S3 bucket, typically within 15 minutes of the API call.
- **Log File Integrity Validation:** CloudTrail can create a digest file for each log delivery. You can validate that log files have not been tampered with using the AWS CLI (`aws cloudtrail validate-logs`).
- **Real-life Example:**
  - A compliance team creates a multi-region organization trail that delivers all logs to a centralized, dedicated security account's S3 bucket with server-side encryption (SSE-KMS) and log file integrity validation enabled. No member account can disable or modify this trail.

---

### 3. CloudTrail Log Files

- **Format:** Log files are stored in JSON format and compressed with gzip.
- **Contents:** Each record includes:
  - `eventTime` — When the API call occurred.
  - `eventName` — The specific API action (e.g., `CreateUser`, `TerminateInstances`).
  - `userIdentity` — Who made the call (IAM user, role, root, service, etc.).
  - `sourceIPAddress` — The IP address from which the request was made.
  - `requestParameters` — The parameters sent with the request.
  - `responseElements` — The response returned by the AWS service.
  - `awsRegion` — The AWS region where the call was made.
  - `errorCode` / `errorMessage` — If the call failed, the error details.
- **Log File Location:** `s3://<bucket-name>/AWSLogs/<account-id>/CloudTrail/<region>/<year>/<month>/<day>/`

---

### 4. Integration with Amazon CloudWatch Logs

- **Real-Time Monitoring:** CloudTrail can be configured to deliver events to a CloudWatch Logs log group, enabling near real-time monitoring and alerting.
- **Metric Filters and Alarms:** Once in CloudWatch Logs, you can define metric filters to extract patterns (e.g., root account logins, unauthorized API calls) and create CloudWatch Alarms to notify your team via SNS.
- **Real-life Example:**
  - A security team creates a metric filter that detects root account sign-in events and triggers a CloudWatch alarm that sends an immediate alert to their security SNS topic whenever the root user logs in.

**Common CloudWatch metric filters for CloudTrail:**

| Filter Pattern | Use Case |
|---|---|
| `{ $.userIdentity.type = "Root" }` | Detect root account usage |
| `{ $.errorCode = "UnauthorizedAccess" \|\| $.errorCode = "AccessDenied" }` | Alert on access denials |
| `{ $.eventName = "ConsoleLogin" && $.additionalEventData.MFAUsed != "Yes" }` | Detect console logins without MFA |
| `{ $.eventName = "DeleteTrail" \|\| $.eventName = "StopLogging" }` | Detect CloudTrail tampering |
| `{ $.eventSource = "iam.amazonaws.com" }` | Monitor all IAM activity |

---

### 5. CloudTrail Insights

- **Anomaly Detection:** CloudTrail Insights continuously analyzes your write management events and alerts you when it detects unusual patterns compared to typical baseline activity.
- **Insight Types:**
  - `ApiCallRateInsight` — Detects unusually high rates of API calls.
  - `ApiErrorRateInsight` — Detects unusually high rates of API errors.
- **Real-life Example:**
  - An attacker compromises an IAM key and begins calling `DescribeInstances`, `ListBuckets`, and `GetSecretValue` at an unusually high rate. CloudTrail Insights detects this anomaly and generates an Insights event, which can be routed to EventBridge for automated response.

---

### 6. Integration with Amazon EventBridge

- CloudTrail management events are automatically delivered to Amazon EventBridge (default event bus), allowing you to build event-driven automation.
- **Real-life Example:**
  - An EventBridge rule is configured to match `{ "source": ["aws.iam"], "detail": { "eventName": ["CreateUser"] } }`. When a new IAM user is created, EventBridge triggers a Lambda function that automatically sends an approval request to a Slack channel before the user account is fully provisioned.

---

### 7. Security Best Practices

| Practice | Description |
|---|---|
| **Enable in all regions** | Use a multi-region trail to ensure no region is left unmonitored. |
| **Enable log file validation** | Detect tampering or deletion of log files. |
| **Encrypt logs with KMS** | Use a customer-managed KMS key (CMK) for SSE encryption. |
| **Restrict S3 bucket access** | Apply a strict bucket policy; deny `s3:DeleteObject` and `s3:PutLifecycleConfiguration`. |
| **Enable MFA Delete on S3** | Require MFA to delete log objects or change versioning state. |
| **Use Organization trails** | Centralize logs from all accounts into a dedicated security account. |
| **Enable CloudTrail Insights** | Detect unusual API activity automatically. |
| **Alert on trail changes** | Create alarms for `DeleteTrail`, `StopLogging`, and `UpdateTrail`. |

---

## Purpose and Real-Life Use Cases

- **Security Investigation:** When a security incident occurs, CloudTrail logs provide a full timeline of API actions — who did what, when, and from where — enabling rapid forensic analysis.
- **Compliance Auditing:** Satisfy compliance requirements (SOC 2, PCI-DSS, HIPAA, ISO 27001) by demonstrating that all user and service actions are logged and immutably stored.
- **Change Management:** Track infrastructure changes to identify the cause of unintended configuration drift or outages (e.g., who changed a security group rule that opened port 22 to the internet).
- **Insider Threat Detection:** Monitor privileged actions such as IAM policy changes, KMS key deletions, and secret access to detect misuse by internal users.
- **Automated Governance:** Combine CloudTrail with EventBridge and Lambda to enforce policies in real time — for example, automatically reverting a public S3 bucket to private the moment it is made public.
- **Cost Attribution:** Audit which users or roles are creating expensive resources to enforce tagging policies and accountability.

---

CloudTrail is a cornerstone of AWS security and compliance. It is recommended to enable a multi-region trail with S3 log delivery, KMS encryption, log file integrity validation, and CloudWatch Logs integration from day one in every AWS account.
