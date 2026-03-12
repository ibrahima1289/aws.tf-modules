# Amazon Athena

## Overview

**Amazon Athena** is a **serverless, interactive query service** that lets you analyse data directly in **Amazon S3** using standard SQL — with no infrastructure to provision or manage. Athena uses **Presto** and **Apache Spark** under the hood, integrates natively with the **AWS Glue Data Catalog**, and charges only for the data scanned per query.

---

## Key Features

| Feature | Description |
|---|---|
| **Serverless** | No clusters to spin up; queries run on demand |
| **Standard SQL** | ANSI SQL support via Presto/Trino engine |
| **S3-native** | Queries data directly where it lives in S3 |
| **Glue Catalog integration** | Uses Glue as the metastore for table/schema definitions |
| **Federated Query** | Query data in RDS, DynamoDB, Redshift, CloudWatch, and more via Lambda connectors |
| **Athena for Apache Spark** | Run interactive Spark notebooks directly in Athena |
| **Result Caching** | Reuse identical query results to reduce cost |
| **CTAS / INSERT INTO** | Create new tables and write results back to S3 |

---

## Architecture

```
         SQL Client / BI Tool / Console
                     │
              ┌──────▼──────┐
              │   Amazon    │
              │   Athena    │ ◄── AWS Glue Data Catalog (schemas/tables)
              └──────┬──────┘
                     │  Scan
          ┌──────────▼──────────────┐
          │       Amazon S3         │
          │  Parquet / ORC / JSON   │
          │  CSV / Avro / TSV       │
          └─────────────────────────┘
                     │
              ┌──────▼──────┐
              │   Results   │  → S3 output bucket
              │   (cached)  │  → QuickSight / Jupyter / API
              └─────────────┘
```

### How a Query Executes

1. **Submit SQL** — via console, JDBC/ODBC, API, or SDK
2. **Plan** — Athena parses SQL and consults the Glue Data Catalog for schema
3. **Scan** — Athena workers read only the relevant S3 files (partitions + column pruning)
4. **Results** — Written to your designated S3 output location; billed per TB scanned

---

## Supported Data Formats

| Format | Read | Write (CTAS) | Notes |
|---|---|---|---|
| **Apache Parquet** | ✅ | ✅ | Recommended — columnar, highly compressed |
| **Apache ORC** | ✅ | ✅ | Columnar; good compression |
| **Apache Avro** | ✅ | ✅ | Row-based; schema evolution |
| **JSON / JSON Lines** | ✅ | ✅ | Human-readable; higher scan cost |
| **CSV / TSV** | ✅ | ✅ | Widely supported; no compression benefit |
| **Apache Iceberg** | ✅ | ✅ | ACID transactions, time travel, schema evolution |
| **Apache Hudi** | ✅ | — | Incremental processing, upserts |
| **Delta Lake** | ✅ | — | Open-source; read-only via manifest |

> 💡 **Best practice:** Store data as **Parquet** or **ORC** with **Snappy** compression, partitioned by common filter columns (e.g., `year/month/day`). This minimises data scanned and reduces cost.

---

## Partitioning

Partitioning reduces the amount of data scanned and dramatically lowers query cost.

```sql
-- Create a partitioned external table
CREATE EXTERNAL TABLE cloudtrail_logs (
  eventtime    STRING,
  eventname    STRING,
  useridentity STRUCT<type:STRING, principalid:STRING>
)
PARTITIONED BY (region STRING, year STRING, month STRING, day STRING)
STORED AS PARQUET
LOCATION 's3://my-bucket/cloudtrail/';

-- Load partitions from S3
MSCK REPAIR TABLE cloudtrail_logs;

-- Query a specific partition (scans only that partition's data)
SELECT eventname, COUNT(*) AS cnt
FROM cloudtrail_logs
WHERE region = 'us-east-1' AND year = '2026' AND month = '03'
GROUP BY eventname
ORDER BY cnt DESC;
```

---

## Federated Query

Query data sources beyond S3 using **Lambda-based data source connectors**.

```sql
-- Connect to RDS PostgreSQL via Athena Federated Query
CREATE DATA SOURCE my_rds_postgres
USING 'arn:aws:lambda:us-east-1:123456789012:function:AthenaPGConnector'
WITH (
  catalog = 'my_rds_postgres',
  "connection_string" = 'postgres://my-rds-host:5432/mydb'
);

-- Join S3 data with live RDS data
SELECT s.customer_id, r.email, s.total_spend
FROM "my_rds_postgres"."public"."customers" r
JOIN my_s3_table s ON r.customer_id = s.customer_id;
```

### Available Connectors

- Amazon DynamoDB
- Amazon RDS / Aurora (MySQL, PostgreSQL)
- Amazon Redshift
- Amazon CloudWatch Logs & Metrics
- Apache HBase on EMR
- JDBC-compatible databases (custom connectors)

---

## CTAS — Create Table As Select

Write query results back to S3 as a new optimised table.

```sql
CREATE TABLE optimised_sales
WITH (
  format           = 'PARQUET',
  write_compression = 'SNAPPY',
  partitioned_by   = ARRAY['year', 'month'],
  external_location = 's3://my-bucket/optimised/sales/'
)
AS SELECT
  customer_id,
  product_id,
  amount,
  YEAR(order_date)  AS year,
  MONTH(order_date) AS month
FROM raw_sales_csv
WHERE order_date >= DATE '2025-01-01';
```

---

## Security

| Control | Details |
|---|---|
| **IAM Policies** | Control who can run queries, access workgroups, and read S3 |
| **S3 Bucket Policies** | Restrict which principals can read the underlying data |
| **S3 SSE / KMS** | Data encrypted at rest; Athena decrypts transparently |
| **Athena Workgroups** | Isolate users/teams; enforce query limits and result bucket |
| **VPC Endpoints** | Private access to Athena from within a VPC |
| **Lake Formation** | Fine-grained column- and row-level access control on Glue tables |
| **CloudTrail** | Full API audit trail for all Athena query executions |

---

## Workgroups

Workgroups let you separate users, enforce controls, and track costs per team.

```hcl
resource "aws_athena_workgroup" "analytics_team" {
  name = "analytics-team"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://my-athena-results/analytics-team/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.athena.arn
      }
    }

    bytes_scanned_cutoff_per_query     = 10737418240  # 10 GB limit per query
  }
}
```

---

## Monitoring

| Tool | Metrics |
|---|---|
| **CloudWatch Metrics** | Query execution time, data scanned, success/failure counts |
| **Athena Query History** | Per-query stats in the console or via `ListQueryExecutions` API |
| **AWS Cost Explorer** | Tag-based cost allocation per workgroup |
| **CloudTrail** | API audit logs (`StartQueryExecution`, `GetQueryResults`, etc.) |

---

## Pricing

| Component | Cost |
|---|---|
| **Data scanned per query** | $5.00 per TB scanned (standard engine) |
| **Federated queries** | Same per-TB rate + Lambda invocation costs |
| **Athena for Apache Spark** | Per DPU-hour used |
| **S3 storage** | Standard S3 rates for data and query results |

> Cost optimisation tips:
> - Use **columnar formats** (Parquet/ORC) — typically reduces scanned data by 70–90%
> - **Partition** data by common filter columns
> - Use **CTAS** to convert raw CSV/JSON to Parquet after initial ingest
> - Enable **query result reuse** to avoid re-scanning for repeated queries

---

## Common Use Cases

| Use Case | Pattern |
|---|---|
| **Log Analysis** | Query CloudTrail, VPC Flow Logs, ALB access logs directly from S3 |
| **Data Lake Analytics** | Ad-hoc SQL over S3-based data lake (Parquet/ORC) |
| **ETL Validation** | Quickly validate transformed data before loading to Redshift |
| **Cost & Usage Reporting** | Query AWS Cost & Usage Reports (CUR) stored in S3 |
| **Security Investigations** | Search CloudTrail logs for specific API calls or principals |

---

## When to Use Athena vs Alternatives

| Scenario | Recommended Service |
|---|---|
| Ad-hoc SQL on S3 data | **Athena** ✅ |
| Large-scale, consistent BI workloads | **Redshift** |
| Real-time stream analytics | **Kinesis / MSK** |
| Search & full-text analytics | **OpenSearch Service** |
| Complex ETL pipelines | **AWS Glue** |
| Interactive dashboards (no SQL) | **QuickSight** |

---

## Terraform Resources

| Resource | Description |
|---|---|
| [`aws_athena_database`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_database) | Athena database (backed by Glue) |
| [`aws_athena_workgroup`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | Query workgroup with result config and limits |
| [`aws_athena_named_query`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | Saved/named queries |
| [`aws_athena_data_catalog`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_data_catalog) | External or federated data source catalog |

---

## Useful Links

- [Amazon Athena Documentation](https://docs.aws.amazon.com/athena/latest/ug/what-is.html)
- [Athena Best Practices for Performance](https://docs.aws.amazon.com/athena/latest/ug/performance-tuning.html)
- [Supported Data Formats](https://docs.aws.amazon.com/athena/latest/ug/supported-serdes.html)
- [Federated Query Connectors](https://docs.aws.amazon.com/athena/latest/ug/connect-to-a-data-source.html)
- [Terraform: aws_athena_workgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup)
