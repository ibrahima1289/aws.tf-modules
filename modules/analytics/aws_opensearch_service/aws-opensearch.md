# Amazon OpenSearch Service

## Overview

**Amazon OpenSearch Service** (formerly Amazon Elasticsearch Service) is a fully managed service that makes it easy to deploy, operate, and scale **OpenSearch** and **Elasticsearch** clusters in AWS. It is purpose-built for **real-time search, log analytics, full-text search, application monitoring, and security analytics** at any scale.

OpenSearch is an open-source fork of Elasticsearch (≤7.10), maintained by AWS and the community under the Apache 2.0 license.

---

## Key Features

| Feature | Description |
|---|---|
| **Managed Clusters** | Automated provisioning, patching, backups, and failover |
| **OpenSearch Dashboards** | Built-in Kibana-compatible visualisation and exploration UI |
| **Multi-AZ** | Deploy with 2 or 3 AZs for high availability |
| **UltraWarm** | S3-backed warm storage tier — lower cost for infrequently queried data |
| **Cold Storage** | Detach indices to S3 cold storage; re-attach on demand |
| **Serverless** | Fully serverless OpenSearch — auto-scales with no cluster management |
| **Machine Learning** | Built-in anomaly detection, semantic search (k-NN), and neural search |
| **Security Analytics** | Purpose-built dashboards for threat detection (SIEM use cases) |
| **Observability** | Trace analytics with AWS X-Ray and OpenTelemetry integration |

---

## Architecture

### Provisioned Cluster

```
                        ┌──────────────────────────────────────────┐
                        │         OpenSearch Domain                │
  Ingest Sources        │                                          │
  ─────────────         │  ┌──────────┐     ┌──────────────────┐   │
  Kinesis Firehose ────►│  │  Master  │     │  Data Nodes      │   │
  Logstash / Fluent ───►│  │  Nodes   │────►│  Node 1 (Hot)    │   │
  Lambda ──────────────►│  │  (3 AZ)  │     │  Node 2 (Hot)    │   │
  Direct HTTP API ─────►│  └──────────┘     │  Node 3 (Warm)   │   │
                        │                   └──────────────────┘   │
                        │  ┌─────────────────────────────────────┐ │
                        │  │    OpenSearch Dashboards (UI)       │ │
                        │  └─────────────────────────────────────┘ │
                        └──────────────────────────────────────────┘
                                         │
                              ┌──────────▼──────────┐
                              │  UltraWarm / Cold   │
                              │  Storage (S3-backed)│
                              └─────────────────────┘
```

### Serverless

```
  Client ──► OpenSearch Serverless Collection ──► Auto-scaled compute
                        │
             S3-backed managed storage (automatic)
```

---

## Node Types

| Node Type | Purpose |
|---|---|
| **Dedicated Master Nodes** | Cluster state management; recommended for production (3 or 5 nodes) |
| **Data Nodes (Hot)** | Store and query active, frequently accessed indices |
| **UltraWarm Nodes** | Query less-frequently-accessed data at lower cost (S3-backed) |
| **Cold Storage** | Offload indices to S3; attach/detach as needed |

---

## Storage Tiers

| Tier | Storage | Use Case | Relative Cost |
|---|---|---|---|
| **Hot** | Local SSD (EBS) | Active indices, real-time search | Highest |
| **UltraWarm** | S3 + local cache | Read-only historical data (logs, metrics) | ~⅓ of hot |
| **Cold** | S3 only | Long-term archival; query on demand | Lowest |

---

## Index Management (ISM)

Index State Management (ISM) automates transitions between storage tiers and lifecycle actions.

```json
{
  "policy": {
    "description": "Hot-Warm-Cold-Delete log lifecycle",
    "states": [
      {
        "name": "hot",
        "actions": [],
        "transitions": [{ "state_name": "warm", "conditions": { "min_index_age": "7d" }}]
      },
      {
        "name": "warm",
        "actions": [{ "warm_migration": {} }],
        "transitions": [{ "state_name": "cold", "conditions": { "min_index_age": "30d" }}]
      },
      {
        "name": "cold",
        "actions": [{ "cold_migration": { "timestamp_field": "@timestamp" } }],
        "transitions": [{ "state_name": "delete", "conditions": { "min_index_age": "365d" }}]
      },
      {
        "name": "delete",
        "actions": [{ "delete": {} }],
        "transitions": []
      }
    ]
  }
}
```

---

## Common Query Patterns

### Full-text Search

```json
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "wireless noise cancelling headphones",
      "fields": ["name^3", "description", "tags"]
    }
  }
}
```

### Aggregation (Analytics)

```json
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "errors_per_hour": {
      "date_histogram": {
        "field": "@timestamp",
        "fixed_interval": "1h"
      },
      "aggs": {
        "error_count": {
          "filter": { "term": { "level": "ERROR" } }
        }
      }
    }
  }
}
```

### k-NN Vector Search (Semantic Search)

```json
GET /embeddings/_search
{
  "size": 5,
  "query": {
    "knn": {
      "embedding_vector": {
        "vector": [0.12, 0.45, 0.78, ...],
        "k": 5
      }
    }
  }
}
```

---

## Ingestion Patterns

| Source | Method | Use Case |
|---|---|---|
| **Amazon Kinesis Data Firehose** | Native delivery stream → OpenSearch | Real-time log/event streaming |
| **AWS Lambda** | Push documents via HTTP API | Event-driven indexing |
| **Logstash** | Logstash OpenSearch output plugin | Log pipeline (on-premises/EC2) |
| **Fluent Bit / Fluentd** | AWS-native plugins | Container log aggregation (EKS/ECS) |
| **AWS Glue** | Batch ETL → OpenSearch | Bulk index loading |
| **Amazon CloudWatch → Firehose** | CW subscription filter → Firehose | CloudWatch Logs to OpenSearch |

---

## OpenSearch Dashboards

**OpenSearch Dashboards** (the successor to Kibana) provides a rich UI for:

- **Discover** — Browse and search raw index data
- **Visualise** — Build charts (bar, pie, time-series, heatmap, maps)
- **Dashboards** — Combine visuals into monitoring dashboards
- **Dev Tools** — Run ad-hoc REST queries against indices
- **Alerting** — Define monitors and triggers with notifications (SNS, Slack, email)
- **Anomaly Detection** — ML-based anomaly detection with visualisation
- **Observability** — Traces, logs, and metrics in one pane (with OpenTelemetry)
- **Security Analytics** — SIEM-style threat detection rules and findings

---

## Security

| Control | Details |
|---|---|
| **Encryption at Rest** | AES-256 with AWS-managed or customer KMS keys |
| **Encryption in Transit** | TLS for all node-to-node and client communication |
| **VPC** | Deploy domain within a VPC; use security groups |
| **Fine-grained Access Control (FGAC)** | Index-, field-, and document-level permissions per user/role |
| **SAML / Cognito** | Federated SSO for OpenSearch Dashboards |
| **IP-based Access Policies** | Resource-based policies restricting access by CIDR |
| **AWS CloudTrail** | Full API audit logging |
| **Audit Logs** | Record all search and index operations per user |

---

## Alerting

Define monitors that run queries on a schedule and trigger actions when conditions are met.

```json
{
  "name": "High Error Rate Alert",
  "type": "monitor",
  "schedule": { "period": { "interval": 5, "unit": "MINUTES" } },
  "inputs": [{
    "search": {
      "indices": ["app-logs-*"],
      "query": {
        "size": 0,
        "query": { "term": { "level": "ERROR" } },
        "aggs": { "count": { "value_count": { "field": "_id" } } }
      }
    }
  }],
  "triggers": [{
    "name": "error_threshold",
    "condition": { "script": { "source": "ctx.results[0].aggregations.count.value > 100" } },
    "actions": [{
      "name": "Notify SNS",
      "destination_id": "my-sns-destination",
      "message_template": { "source": "High error rate detected: {{ctx.results[0].aggregations.count.value}} errors in 5 min" }
    }]
  }]
}
```

---

## Monitoring

| Tool | Metrics |
|---|---|
| **Amazon CloudWatch** | Cluster health, indexing rate, search rate, JVM memory, disk usage |
| **OpenSearch Dashboards** | Real-time cluster/index metrics in the UI |
| **ISM** | Index lifecycle events and state transitions |
| **CloudTrail** | API-level audit logging |

### Key CloudWatch Metrics

| Metric | Alert Threshold |
|---|---|
| `ClusterStatus.red` | > 0 (critical — data loss risk) |
| `JVMMemoryPressure` | > 85% |
| `FreeStorageSpace` | < 20% of total |
| `KibanaHealthyNodes` | < expected count |

---

## Pricing

| Component | Pricing |
|---|---|
| **Instance hours** | Per-hour rate by instance type (e.g., r6g.large.search) |
| **EBS storage** | Per GB/month for gp2, gp3, or io1 volumes |
| **UltraWarm storage** | Per GB/month (~⅓ the cost of hot storage) |
| **Cold storage** | S3 standard rates per GB/month |
| **Serverless OCU** | Per OpenSearch Compute Unit (OCU) hour for indexing and search |
| **Data transfer** | Free within same AZ; standard cross-AZ/cross-region rates |

> Use the [AWS Cost Calculator](https://calculator.aws/#/) to estimate costs.

---

## Common Use Cases

| Use Case | Pattern |
|---|---|
| **Log Analytics** | Aggregate application/infrastructure logs; search and alert |
| **SIEM / Security Analytics** | Ingest CloudTrail, GuardDuty, VPC Flow Logs; detect threats |
| **E-commerce Search** | Product catalogue full-text and faceted search |
| **Observability** | Distributed tracing + metrics + logs in one platform |
| **Semantic / Vector Search** | k-NN embeddings for AI-powered similarity search |
| **Operational Dashboards** | Real-time metrics dashboards from Firehose/Kinesis streams |

---

## When to Use OpenSearch vs Alternatives

| Scenario | Recommended Service |
|---|---|
| Full-text search, log analytics, SIEM | **OpenSearch Service** ✅ |
| Structured SQL analytics on S3 | **Athena** |
| Large-scale data warehousing | **Redshift** |
| BI dashboards and reports | **QuickSight** |
| Real-time stream processing | **Kinesis / MSK** |
| Relational database search | **RDS + pg_trgm or Aurora Fulltext** |

---

## Terraform Resources

| Resource | Description |
|---|---|
| [`aws_opensearch_domain`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | Provisioned OpenSearch domain |
| [`aws_opensearch_domain_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain_policy) | Resource-based access policy |
| [`aws_opensearch_serverless_collection`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection) | Serverless collection |
| [`aws_opensearch_serverless_security_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | Encryption/network policy for serverless |
| [`aws_opensearch_serverless_access_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | Data access policy for serverless |
| [`aws_opensearch_vpc_endpoint`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_vpc_endpoint) | VPC endpoint for private access |

---

## Useful Links

- [Amazon OpenSearch Service Documentation](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/what-is.html)
- [OpenSearch Project](https://opensearch.org/)
- [OpenSearch Dashboards](https://opensearch.org/docs/latest/dashboards/)
- [Fine-grained Access Control](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/fgac.html)
- [Index State Management](https://opensearch.org/docs/latest/im-plugin/ism/index/)
- [Terraform: aws_opensearch_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain)
