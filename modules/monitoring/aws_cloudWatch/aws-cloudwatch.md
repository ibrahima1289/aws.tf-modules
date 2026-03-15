# Amazon CloudWatch

> 🔧 **Terraform Module:** [modules/monitoring/aws_cloudwatch](README.md) | **Wrapper:** [tf-plans/aws_cloudwatch](../../../tf-plans/aws_cloudwatch/README.md) | **Pricing:** [AWS CloudWatch Pricing](https://aws.amazon.com/cloudwatch/pricing/) | **Related:** [CloudTrail Guide](../aws_cloudtrail/aws-cloudtrail.md)

Amazon CloudWatch is a monitoring and observability service that collects metrics, logs, and events from AWS resources, on-premises servers, and hybrid environments. It provides a unified operational picture, enabling you to detect anomalies, set alarms, visualize logs and metrics, automate responses, and troubleshoot issues — all from a single platform.

---

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Metrics** | Time-series numerical data points emitted by AWS services or your own applications. Identified by namespace, name, and dimensions. |
| **Logs** | Arbitrary text records stored in log groups and streams. Supports filtering, searching, querying (Logs Insights), and metric extraction. |
| **Alarms** | Watch a metric or math expression; fire actions (SNS, Auto Scaling, EC2, OpsCenter) when a threshold is breached. |
| **Composite Alarms** | Combine multiple alarms using boolean logic (`ALARM()`, `OK()`, `INSUFFICIENT_DATA()`). Reduces alert noise. |
| **Dashboards** | Customizable visualisations with widgets (graphs, numbers, text, alarm status). Sharable across accounts. |
| **Log Metric Filters** | Extract numeric values from log events and publish them as CloudWatch custom metrics. |
| **Log Subscription Filters** | Stream matching log events in real time to Lambda, Kinesis Data Streams, or Kinesis Firehose. |
| **Logs Insights** | Interactive query engine for log groups. SQL-like syntax; results returned in seconds. |
| **CloudWatch Agent** | Unified agent for EC2 and on-premises servers — collects host-level metrics (memory, disk) and application logs. |

---

## Key Components and Configuration

### 1. Log Groups (`aws_cloudwatch_log_group`)

Log groups are the top-level container for log data in CloudWatch Logs.

| Setting | Description |
|---------|-------------|
| `name` | Log group name. Convention: `/aws/<service>/<resource>` or `/app/<env>/<component>`. |
| `retention_in_days` | How long events are kept. Valid values: `1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0` (never expire). |
| `kms_key_id` | ARN of a customer-managed KMS key for server-side encryption at rest. |
| `tags` | Resource tags. |

- **Real-life Example:**
  - `/aws/lambda/payment-processor` — automatically created by Lambda when your function first runs.
  - `/app/prod/api-gateway` — custom log group fed by API Gateway access logs.
  - A compliance team sets `retention_in_days = 365` on all production log groups to satisfy a 12-month audit log retention policy.

---

### 2. Metrics and Namespaces

Metrics are the fundamental unit of CloudWatch monitoring. They are published automatically by over 70 AWS services or manually via the `PutMetricData` API.

| Concept | Detail |
|---------|--------|
| **Namespace** | Grouping container, e.g., `AWS/EC2`, `AWS/Lambda`, `AWS/RDS`. Custom metrics use your own namespace (e.g., `MyApp/Orders`). |
| **Dimensions** | Key/value pairs that further identify a metric, e.g., `{ InstanceId = "i-0abc123" }` or `{ FunctionName = "my-fn" }`. |
| **Resolution** | Standard (1-minute minimum). High-resolution custom metrics support 1-second granularity at higher cost. |
| **Statistics** | `Average`, `Sum`, `Min`, `Max`, `SampleCount`. Percentiles (`p50`, `p99`) via extended statistics. |
| **Math expressions** | Combine multiple metrics into a single expression (e.g., error rate = `errors / requests * 100`). |
| **Anomaly detection** | ML-based band (`ANOMALY_DETECTION_BAND()`) automatically models expected behaviour for a metric. |

- **Common AWS namespaces:**

| Namespace | Key Metrics |
|-----------|-------------|
| `AWS/EC2` | `CPUUtilization`, `NetworkIn`, `NetworkOut`, `DiskReadOps` |
| `AWS/Lambda` | `Invocations`, `Errors`, `Throttles`, `Duration`, `ConcurrentExecutions` |
| `AWS/RDS` | `CPUUtilization`, `DatabaseConnections`, `FreeStorageSpace`, `ReadLatency` |
| `AWS/ApplicationELB` | `RequestCount`, `TargetResponseTime`, `HTTPCode_ELB_5XX_Count` |
| `AWS/ECS` | `CPUUtilization`, `MemoryUtilization` |
| `AWS/SQS` | `ApproximateNumberOfMessagesVisible`, `NumberOfMessagesSent` |

---

### 3. Metric Alarms (`aws_cloudwatch_metric_alarm`)

Metric alarms continuously evaluate a single metric or a metric math expression and transition between three states.

| State | Meaning |
|-------|---------|
| `OK` | The metric is within the defined threshold. |
| `ALARM` | The metric has breached the threshold for the required number of periods. |
| `INSUFFICIENT_DATA` | Not enough data points to evaluate the alarm. |

**Key configuration fields:**

| Field | Description |
|-------|-------------|
| `comparison_operator` | `GreaterThanThreshold`, `LessThanThreshold`, `GreaterThanOrEqualToThreshold`, `LessThanOrEqualToThreshold`, `GreaterThanUpperThreshold` (anomaly detection) |
| `evaluation_periods` | Number of consecutive periods that must breach before the alarm fires. |
| `datapoints_to_alarm` | N out of M datapoints to breach (N-of-M evaluation). Reduces false positives. |
| `treat_missing_data` | `missing` (default), `ignore`, `breaching`, `notBreaching`. |
| `metric_queries` | Use for math alarms, anomaly detection, or cross-account/cross-region metrics. |

**Alarm Actions:**

| Action Type | ARN Format | Triggered on State |
|-------------|------------|--------------------|
| SNS notification | `arn:aws:sns:<region>:<account>:<topic>` | ALARM, OK, INSUFFICIENT_DATA |
| Auto Scaling policy | `arn:aws:autoscaling:...` | ALARM |
| EC2 action | `arn:aws:automate:<region>:ec2:stop\|terminate\|reboot\|recover` | ALARM |
| OpsCenter OpsItem | `arn:aws:ssm:...` | ALARM |

- **Real-life Examples:**
  - **Simple alarm:** EC2 `CPUUtilization > 80%` for 3 consecutive 5-minute periods → SNS alert to on-call team.
  - **N-of-M alarm:** Lambda `Errors > 5` in 2 out of 3 one-minute periods → avoids single-spike false positives.
  - **Math expression alarm:** `errors / invocations * 100 > 1` to alarm on error rate above 1%.
  - **Anomaly detection alarm:** `CPUUtilization` exceeds `ANOMALY_DETECTION_BAND(m1, 2)` (2 standard deviations above expected) → adaptive threshold that adjusts to daily traffic patterns automatically.

---

### 4. Composite Alarms (`aws_cloudwatch_composite_alarm`)

Composite alarms combine multiple metric alarms or other composite alarms using a boolean alarm rule. They fire only when the combined rule expression evaluates to `ALARM`.

**Benefits:**
- Reduce alert noise by requiring multiple conditions before paging the team.
- Suppress alarms during planned maintenance using the `actions_suppressor` feature.

**Alarm rule syntax:**

```
ALARM("alarm-name-1") AND ALARM("alarm-name-2")
ALARM("alarm-name-1") OR ALARM("alarm-name-2")
NOT ALARM("alarm-name-3")
```

| Feature | Description |
|---------|-------------|
| `alarm_rule` | Boolean expression combining `ALARM()`, `OK()`, `INSUFFICIENT_DATA()` functions. |
| `actions_suppressor` | Name of a suppressor alarm. While that alarm is in ALARM state, all actions on this composite alarm are suppressed. |
| `extension_period` | Seconds to continue suppressing actions after the suppressor alarm returns to OK. |
| `wait_period` | Grace period (seconds) before suppression takes effect after the suppressor enters ALARM. |

- **Real-life Example:**
  - A composite alarm fires only when **both** high CPU **and** high memory alarms are active simultaneously — avoiding pages for normal auto-scaling spikes. A maintenance alarm suppresses all actions during the 2 AM deployment window.

---

### 5. Dashboards (`aws_cloudwatch_dashboard`)

Dashboards are customizable JSON-defined views rendered in the CloudWatch console.

**Widget types:**

| Widget Type | `type` Value | Description |
|-------------|--------------|-------------|
| Time series line chart | `metric` | Visualise one or more metrics over time. |
| Stacked area chart | `metric` + `stacked: true` | Show contribution of each series to the total. |
| Single value / sparkline | `metric` + `view: singleValue` | Show the latest value with a small trend graph. |
| Alarm status | `alarm` | Show coloured status badges for named alarms. |
| Logs Insights query | `log` | Run a query and display a table or bar chart. |
| Text (Markdown) | `text` | Free-form Markdown — add runbook links, headings. |
| Explorer | `explorer` | Tag-based metric browsing across resources. |

**Dashboard body format:**

```json
{
  "widgets": [
    {
      "type": "metric",
      "x": 0, "y": 0, "width": 12, "height": 6,
      "properties": {
        "title": "EC2 CPU Utilization",
        "region": "us-east-1",
        "metrics": [["AWS/EC2","CPUUtilization","InstanceId","i-0abc123"]],
        "period": 300,
        "stat": "Average",
        "view": "timeSeries"
      }
    }
  ]
}
```

> 💡 **Best practice:** Store dashboard JSON bodies in external `.json` files under `dashboards/` and load them with `file("${path.module}/dashboards/<name>.json")` in `locals.tf`. This keeps `terraform.tfvars` free of inline JSON and makes diffs readable in version control.

- **Real-life Example:**
  - A production ops team has a `prod-overview` dashboard with: a Markdown header linking to the runbook (row 1), EC2 CPU and Lambda metrics side-by-side (row 2), singleValue P99 latency widgets with sparklines (row 3), alarm status badges for all critical alarms and a Logs Insights table showing the last 50 ERROR log lines (row 4).

---

### 6. Log Metric Filters (`aws_cloudwatch_log_metric_filter`)

Log metric filters scan incoming log events against a filter pattern and increment a custom CloudWatch metric each time a match is found. This bridges the gap between unstructured log data and metric-based alarming.

**Filter pattern syntax examples:**

| Pattern | Matches |
|---------|---------|
| `"ERROR"` | Any log event containing the literal string `ERROR`. |
| `"[level=ERROR]"` | Structured log where the `level` field equals `ERROR`. |
| `"[ts, level=ERROR, msg]"` | Space-delimited log where the second field is `ERROR`. |
| `"{ $.statusCode = 500 }"` | JSON log where `statusCode` is `500`. |
| `"{ $.latencyMs > 1000 }"` | JSON log where `latencyMs` exceeds 1000. |

**Metric transformation fields:**

| Field | Description |
|-------|-------------|
| `metric_name` | Name of the custom metric to publish (e.g., `ApiErrorCount`). |
| `metric_namespace` | Namespace for the metric (e.g., `MyApp/API`). |
| `metric_value` | Numeric string published per match — typically `"1"` for counts, or a JSON field reference like `$.latencyMs` for values. |
| `metric_default_value` | Value published when no events match in a period. Omit to publish no data (maintains `INSUFFICIENT_DATA` on alarms). |
| `metric_unit` | CloudWatch unit: `Count`, `Milliseconds`, `Bytes`, etc. |
| `metric_dimensions` | Map of dimension names to log field references (e.g., `{ Endpoint = "$.path" }`). |

- **Real-life Example:**
  - A filter pattern `{ $.level = "ERROR" }` on `/app/prod/api` publishes `ApiErrorCount` to the `MyApp` namespace. A metric alarm on `ApiErrorCount > 10` in 1 minute fires an SNS alert to the on-call engineer.

---

### 7. Log Subscription Filters (`aws_cloudwatch_log_subscription_filter`)

Subscription filters deliver matching log events from a log group to a destination in near real time (sub-second latency).

**Supported destinations:**

| Destination | Use Case | `role_arn` Required? |
|-------------|----------|----------------------|
| AWS Lambda | Real-time log processing, enrichment, anomaly detection | No |
| Kinesis Data Stream | High-volume log fan-out to multiple consumers | Yes |
| Kinesis Data Firehose | Log archival to S3, OpenSearch, or Splunk | Yes |

**Distribution modes:**

| Mode | Description |
|------|-------------|
| `ByLogStream` (default) | Log events from the same stream always go to the same shard (deterministic). |
| `Random` | Log events are distributed randomly across shards (better for high-fan-out). |

- **Real-life Example:**
  - All log events from `/app/prod/api` are streamed to a Lambda function (`log-enricher`) that parses structured JSON, extracts the `requestId`, and forwards to an OpenSearch cluster for full-text search. A second subscription filter on the same group streams events matching `"CRITICAL"` to a Kinesis Firehose that archives to an S3 compliance bucket.

---

## CloudWatch Logs Insights

Logs Insights provides an interactive query engine for log data. Results can be visualised in the console or embedded as dashboard widgets.

**Common query patterns:**

```
# Count ERROR events per minute
filter @message like /ERROR/
| stats count(*) as errorCount by bin(1m)

# P99 latency from structured JSON logs
filter ispresent(latencyMs)
| stats pct(latencyMs, 99) as p99 by bin(5m)

# Top 10 slowest requests
filter ispresent(latencyMs)
| sort latencyMs desc
| limit 10
| fields @timestamp, requestId, latencyMs, path

# Find requests returning 5xx errors
filter statusCode >= 500
| stats count(*) as count by statusCode, path
| sort count desc
```

---

## Architecture Overview

```
  AWS Services (EC2, RDS, Lambda, ECS, ALB…)
           │ emit metrics & logs automatically
           ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │                          Amazon CloudWatch                             │
  │                                                                        │
  │  ┌──────────────────┐  filter pattern  ┌──────────────────────────┐    │
  │  │   Log Groups     │ ───────────────▶│  Log Metric Filters      │    │
  │  │  (log streams)   │                  │  (custom metrics)        │    │
  │  └────────┬─────────┘                  └─────────────┬────────────┘    │
  │           │ subscription filter                      │ PutMetricData   │
  │           ▼                                          ▼                 │
  │  Lambda / Kinesis /                      ┌──────────────────────────┐  │
  │  Firehose Destination                    │   Metric Alarms          │  │
  │                                          │   (single / math /       │  │
  │                                          │    anomaly detection)    │  │
  │                                          └─────────────┬────────────┘  │
  │                                                        │ ALARM()/OK()  │
  │                                                        ▼               │
  │                                          ┌──────────────────────────┐  │
  │                                          │   Composite Alarms       │  │
  │                                          │   (boolean alarm rules)  │  │
  │                                          └─────────────┬────────────┘  │
  │                                                        │ actions       │
  │                                                        ▼               │
  │                                    SNS / Auto Scaling / EC2 / OpsCenter│
  │                                                                        │
  │  ┌────────────────────────────────────────────────────────────────┐    │
  │  │            Dashboards  (widgets: metric, alarm, log, text)     │    │
  │  └────────────────────────────────────────────────────────────────┘    │
  └────────────────────────────────────────────────────────────────────────┘
```

---

## Security Best Practices

| Practice | Description |
|----------|-------------|
| **Encrypt log groups with KMS** | Set `kms_key_id` on sensitive log groups to use a customer-managed key (CMK). Ensure the key policy grants CloudWatch Logs `kms:GenerateDataKey` and `kms:Decrypt`. |
| **Set log retention** | Never leave retention at the default (never expire). Unretained logs accumulate cost; compliance standards require defined retention periods. |
| **Restrict log group access** | Apply resource-based IAM policies and use condition keys (`logs:ResourceTag/*`) to limit who can read sensitive log groups. |
| **Alarm on root account usage** | Use a log metric filter on CloudTrail logs: `{ $.userIdentity.type = "Root" }` → metric alarm → SNS. |
| **Alarm on unauthorised API calls** | Filter pattern: `{ $.errorCode = "AccessDenied" || $.errorCode = "UnauthorizedAccess" }`. |
| **Protect dashboards** | Dashboards are account-wide; restrict `cloudwatch:PutDashboard` and `cloudwatch:DeleteDashboards` via IAM. |
| **Use composite alarms** | Reduce alert fatigue; only page when multiple signals fire together. Use suppressor alarms during maintenance windows. |
| **Monitor alarm state changes** | Set `treat_missing_data = "breaching"` for critical alarms so missing data does not silently mask an issue. |
| **Enable cross-account observability** | Use CloudWatch cross-account observability (Observability Access Manager) to centralise monitoring into a dedicated monitoring account. |
| **Audit with CloudTrail** | All CloudWatch API calls are logged by CloudTrail. Monitor `DeleteAlarms`, `DeleteDashboards`, and `DeleteLogGroup` events. |

---

## Terraform Resources

| Resource | Terraform Type | Module Variable |
|----------|---------------|-----------------|
| Log Group | [`aws_cloudwatch_log_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | `var.log_groups` |
| Metric Alarm | [`aws_cloudwatch_metric_alarm`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | `var.metric_alarms` |
| Composite Alarm | [`aws_cloudwatch_composite_alarm`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_composite_alarm) | `var.composite_alarms` |
| Dashboard | [`aws_cloudwatch_dashboard`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | `var.dashboards` |
| Log Metric Filter | [`aws_cloudwatch_log_metric_filter`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | `var.log_metric_filters` |
| Log Subscription Filter | [`aws_cloudwatch_log_subscription_filter`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_subscription_filter) | `var.log_subscription_filters` |

---

## Purpose and Real-Life Use Cases

| Use Case | Description |
|----------|-------------|
| **Application performance monitoring** | Track request latency, error rate, and throughput for APIs and microservices using custom metrics and Logs Insights queries. |
| **Infrastructure health** | Monitor EC2 CPU, RDS storage, SQS queue depth, and ELB 5xx rates with metric alarms and a central dashboard. |
| **Automated remediation** | Alarm on unhealthy EC2 instances triggers the `ec2:recover` action automatically, without human intervention. |
| **Cost visibility** | Publish custom billing metrics; alarm when estimated charges exceed a budget threshold. |
| **Security detection** | Log metric filters on CloudTrail logs detect root logins, IAM changes, and access denials in real time. |
| **SLO / SLA tracking** | Math-expression alarms on error rate and latency percentiles enforce service level objectives across teams. |
| **Log archival and compliance** | Subscription filters stream all logs to Firehose → S3 for long-term immutable retention satisfying SOC 2, PCI-DSS, and HIPAA requirements. |
| **On-call alert routing** | Composite alarms reduce paging noise; only a combined CPU + memory + error rate signal pages the on-call engineer. |

---

CloudWatch is the observability backbone of AWS, combining metrics, logs, alarms, and dashboards into a single platform. Pair it with [CloudTrail](../aws_cloudtrail/aws-cloudtrail.md) for API audit logging and [AWS X-Ray](https://docs.aws.amazon.com/xray/latest/devguide/aws-xray.html) for distributed tracing to achieve full-stack observability.
