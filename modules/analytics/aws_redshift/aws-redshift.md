# Amazon Redshift

## Overview

**Amazon Redshift** is AWS's fully managed, petabyte-scale **cloud data warehouse** service. It enables fast, cost-effective analysis of structured and semi-structured data using standard SQL and existing business intelligence (BI) tools. Redshift is built on a massively parallel processing (MPP) architecture optimised for complex analytical queries across very large datasets.

---

## Key Features

| Feature | Description |
|---|---|
| **Columnar Storage** | Data stored by column rather than row — dramatically reduces I/O for analytical queries |
| **MPP Architecture** | Distributes queries across multiple nodes in parallel for fast execution |
| **Redshift Serverless** | Automatically provisions and scales capacity — pay only for what you use |
| **Redshift Spectrum** | Query data directly in Amazon S3 without loading it into Redshift |
| **Auto-scaling** | Concurrency Scaling adds capacity automatically during peak query load |
| **Data Sharing** | Share live data across Redshift clusters and accounts without copying |
| **AQUA** | Advanced Query Accelerator — hardware-accelerated cache for faster queries |
| **ML Integration** | Run `CREATE MODEL` SQL to train and invoke ML models directly in Redshift |

---

## Architecture

```
Clients / BI Tools (Tableau, QuickSight, Looker)
           │
    ┌──────▼──────────────────────────────────┐
    │           Amazon Redshift Cluster       │
    │  ┌────────────┐   ┌───────────────────┐ │
    │  │ Leader Node│   │   Compute Nodes   │ │
    │  │ (SQL parse │──►│  Node 1 / Node 2  │ │
    │  │  & plan)   │   │  Node 3 / Node N  │ │
    │  └────────────┘   └───────────────────┘ │
    └─────────────────────────────────────────┘
           │                      │
    ┌──────▼───────┐     ┌────────▼────────┐
    │  Amazon S3   │     │  Redshift       │
    │ (Spectrum /  │     │  Serverless     │
    │  COPY/UNLOAD)│     │  (auto-scale)   │
    └──────────────┘     └─────────────────┘
```

### Node Types

| Node Type | Best For | Storage |
|---|---|---|
| **RA3** | Scalable managed storage (recommended) | Managed storage (S3-backed) |
| **DC2** | Fixed local SSD storage; compute-intensive | Local SSD |
| **Serverless** | Variable/unpredictable workloads | Managed automatically |

---

## Cluster Types

### Provisioned Cluster
- Fixed number of nodes; you choose the node type and count
- Suitable for consistent, predictable workloads
- Supports `pause/resume` to reduce costs when idle

### Redshift Serverless
- No cluster management — capacity auto-provisions on demand
- Billed per **Redshift Processing Unit (RPU)** per second
- Ideal for intermittent, bursty, or unpredictable analytics workloads

---

## Data Loading

### Recommended: `COPY` Command
Load data from Amazon S3, DynamoDB, EMR, or SSH remote hosts in parallel.

```sql
COPY sales
FROM 's3://my-bucket/sales/data/'
IAM_ROLE 'arn:aws:iam::123456789012:role/RedshiftS3Role'
FORMAT AS PARQUET;
```

### Other Ingestion Methods

| Method | Description |
|---|---|
| **AWS Glue** | ETL pipelines to transform and load data into Redshift |
| **Amazon Kinesis Data Firehose** | Real-time streaming data delivery to Redshift |
| **AWS DMS** | Migrate databases to Redshift |
| **federated query** | Query live data from RDS/Aurora without ETL |
| **INSERT / JDBC/ODBC** | Small-volume inserts via standard SQL drivers |

---

## Redshift Spectrum

Query data that lives in Amazon S3 directly from Redshift without loading it first.

```sql
-- External table pointing to S3
CREATE EXTERNAL SCHEMA spectrum_schema
FROM DATA CATALOG
DATABASE 'my_glue_db'
IAM_ROLE 'arn:aws:iam::123456789012:role/RedshiftSpectrumRole'
CREATE EXTERNAL DATABASE IF NOT EXISTS;

-- Query S3 data alongside Redshift tables
SELECT r.customer_id, s.total_spend
FROM redshift_table r
JOIN spectrum_schema.s3_large_table s ON r.customer_id = s.customer_id;
```

---

## Security

| Control | Details |
|---|---|
| **Encryption at Rest** | AES-256 using AWS-managed or customer-managed KMS keys |
| **Encryption in Transit** | SSL/TLS for all client connections |
| **VPC** | Deploy cluster within a VPC; use security groups and NACLs |
| **IAM** | IAM roles for S3 access, cross-account data sharing |
| **Database Users & Groups** | SQL-level `GRANT`/`REVOKE` permissions |
| **Row-level Security (RLS)** | Restrict rows visible to specific users or groups |
| **Column-level Security** | Restrict access to specific columns per user/group |
| **Audit Logging** | Connection and user activity logs to S3 |

---

## Performance Optimisation

### Distribution Styles

| Style | Description | Use When |
|---|---|---|
| `AUTO` | Redshift chooses automatically | Default — let Redshift decide |
| `EVEN` | Rows distributed evenly across nodes | No clear join/filter key |
| `KEY` | Rows distributed by column value | Joining on a specific column |
| `ALL` | Entire table copied to every node | Small dimension tables |

### Sort Keys

```sql
-- Compound sort key (commonly used)
CREATE TABLE orders (
  order_id    BIGINT,
  order_date  DATE,
  customer_id INT
)
SORTKEY (order_date, customer_id);

-- Interleaved sort key (multiple query patterns)
CREATE TABLE orders (
  order_id    BIGINT,
  order_date  DATE,
  customer_id INT
)
INTERLEAVED SORTKEY (order_date, customer_id);
```

---

## Monitoring

| Tool | Metrics |
|---|---|
| **Amazon CloudWatch** | CPU, disk usage, query throughput, concurrency |
| **Redshift Console** | Query editor, query history, cluster health |
| **Performance Insights** | Wait events, top queries, query execution plans |
| **`STL_QUERY` / `SVL_QUERY_SUMMARY`** | System tables for detailed query profiling |
| **Amazon CloudTrail** | API-level audit logging |

---

## Pricing

| Component | Pricing Model |
|---|---|
| **Provisioned nodes** | Per-node/hour (RA3, DC2); `pause` to avoid charges when idle |
| **Redshift Serverless** | Per RPU-second used |
| **Redshift Spectrum** | Per TB of S3 data scanned |
| **Data transfer** | Free within same AZ; standard AWS rates cross-AZ/cross-region |
| **Snapshots** | Free up to provisioned storage; per-GB beyond |
| **Reserved Instances** | Up to 75% savings vs on-demand (1-year or 3-year term) |

> Use the [AWS Cost Calculator](https://calculator.aws/#/) to estimate costs for your cluster configuration.

---

## Common Use Cases

| Use Case | Pattern |
|---|---|
| **Enterprise Data Warehouse** | Central repository for structured business data from multiple sources |
| **Real-time Analytics** | Kinesis Firehose → Redshift Serverless for near-real-time dashboards |
| **Data Lake Analytics** | Redshift Spectrum queries raw S3 data alongside Redshift managed tables |
| **ML on Data Warehouse** | `CREATE MODEL` + `PREDICT` SQL for in-database machine learning |
| **Cross-account Data Sharing** | Share live data between business units without duplication |

---

## When to Use Redshift vs Alternatives

| Scenario | Recommended Service |
|---|---|
| Large-scale structured analytics (TB–PB) | **Redshift** ✅ |
| Ad-hoc SQL queries on S3 data | **Athena** |
| OLTP / transactional workloads | **RDS / Aurora** |
| Real-time stream processing | **Kinesis / MSK** |
| Unstructured / search workloads | **OpenSearch Service** |
| Interactive dashboards (no SQL required) | **QuickSight** |

---

## Terraform Resources

| Resource | Description |
|---|---|
| [`aws_redshift_cluster`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster) | Provisioned Redshift cluster |
| [`aws_redshift_serverless_namespace`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_serverless_namespace) | Serverless namespace |
| [`aws_redshift_serverless_workgroup`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_serverless_workgroup) | Serverless workgroup (compute config) |
| [`aws_redshift_subnet_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_subnet_group) | Subnet group for VPC placement |
| [`aws_redshift_parameter_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_parameter_group) | Cluster parameter group |
| [`aws_redshift_snapshot_schedule`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_snapshot_schedule) | Automated snapshot schedule |

---

## Useful Links

- [Amazon Redshift Documentation](https://docs.aws.amazon.com/redshift/latest/mgmt/welcome.html)
- [Redshift Serverless Documentation](https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-serverless.html)
- [Redshift Best Practices](https://docs.aws.amazon.com/redshift/latest/dg/best-practices.html)
- [Terraform: aws_redshift_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster)
