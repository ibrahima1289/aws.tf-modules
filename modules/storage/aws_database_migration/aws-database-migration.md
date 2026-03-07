# AWS Database Migration Service (DMS)

[AWS Database Migration Service (DMS)](https://aws.amazon.com/dms/) is a fully managed cloud service that migrates relational databases, data warehouses, NoSQL databases, and other data stores to AWS quickly and securely. The source database remains fully operational during the migration, minimizing downtime. DMS supports both homogeneous migrations (e.g., MySQL → RDS for MySQL) and heterogeneous migrations (e.g., Oracle → Amazon Aurora) across dozens of engine combinations.

## Core Concepts

*   **Homogeneous Migration:** Source and target use the same database engine. Schema structure is compatible, so no schema conversion is needed. Example: on-premises SQL Server → Amazon RDS for SQL Server.
*   **Heterogeneous Migration:** Source and target use different database engines. Schema must be converted before migration using the AWS Schema Conversion Tool (SCT). Example: Oracle → Amazon Aurora PostgreSQL.
*   **Full Load:** DMS exports all existing data from the source and loads it into the target. No ongoing replication — a one-time bulk copy.
*   **Change Data Capture (CDC):** After the initial full load, DMS reads the database transaction log (binlog, redo log, WAL) at the source and continuously replicates changes to the target in near-real-time.
*   **Full Load + CDC:** The most common migration pattern. Copies all existing data first, then transitions to CDC, enabling a near-zero-downtime migration cutover.
*   **Ongoing Replication:** Use DMS as a permanent data pipeline — continuously replicate a production database into an analytics target (e.g., Amazon Redshift) without a planned cutover.

---

## Key Components

### 1. Replication Instance

A **replication instance** is a managed EC2-like compute resource that DMS provisions to run your replication tasks. It:

*   Connects to both source and target endpoints
*   Reads data from the source, transforms it if needed, and writes it to the target
*   Stores table statistics, cached data, and replication logs on attached EBS storage

Choose the instance class (`dms.t3.medium`, `dms.r5.2xlarge`, etc.) based on the volume of data and the number of concurrent tasks. Multi-AZ replication instances provide high availability with automatic failover.

### 2. Endpoints

**Endpoints** define the connection details for the source and target databases:

*   **Source Endpoint:** The database DMS reads from. DMS uses read-only access (select permissions + log access for CDC).
*   **Target Endpoint:** The database DMS writes to. DMS requires create, insert, update, delete permissions.
*   Each endpoint stores the server name, port, credentials (or Secrets Manager reference), SSL mode, and engine-specific settings.

Supported source and target engines include:

| Category | Engines |
|----------|---------|
| Relational (Source) | Oracle, SQL Server, MySQL, MariaDB, PostgreSQL, SAP ASE, IBM Db2 |
| Relational (Target) | RDS, Aurora, Redshift, SQL Server, Oracle, MySQL, PostgreSQL |
| NoSQL | MongoDB, DocumentDB, DynamoDB, Cassandra |
| Warehouses | Amazon Redshift, Azure Synapse (source only) |
| File | Amazon S3, Kinesis, Kafka, OpenSearch |
| Other | IBM Db2, SAP ASE, Babelfish for Aurora |

### 3. Replication Tasks

A **replication task** defines:

*   Which replication instance to use
*   Source endpoint and target endpoint
*   Migration type (Full Load, CDC, or Full Load + CDC)
*   Table mappings (include/exclude rules by schema and table name using JSON)
*   Transformation rules (rename schemas/tables/columns, add prefixes, change data types)
*   LOB (Large Object) settings for columns containing BLOBs or CLOBs
*   Target table preparation mode (drop and recreate, truncate, or leave as-is)
*   Task logs verbosity level and CloudWatch Logs destination

### 4. AWS Schema Conversion Tool (SCT)

The [AWS Schema Conversion Tool](https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Welcome.html) is a desktop application (also available as AWS SCT in the console) that:

*   Analyzes the source schema and generates an assessment report showing the percentage of code that can be converted automatically
*   Converts DDL (tables, views, indexes, constraints), stored procedures, functions, triggers, and packages
*   Flags items it cannot convert automatically, with recommendations for manual rewrites
*   Applies converted schema to the target database before the DMS task runs

SCT is required for heterogeneous migrations. For homogeneous migrations, you can use the native database dump/restore tools or DMS alone.

### 5. DMS Fleet Advisor

[DMS Fleet Advisor](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_FleetAdvisor.html) discovers and analyzes your on-premises database fleet by:

*   Deploying a data collector on your network
*   Inventorying database servers, schemas, and object counts
*   Recommending AWS target engines and RDS/Aurora instance sizes
*   Providing migration complexity scores to prioritize your migration roadmap

### 6. DMS Serverless

[DMS Serverless](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Serverless.html) automatically provisions, scales, and manages replication capacity. Instead of choosing a fixed replication instance class, you set a minimum and maximum capacity range (in DCUs — DMS Capacity Units), and DMS automatically scales within that range based on workload.

---

## Migration Architecture

```
 On-Premises / Source Cloud
┌──────────────────────────────────────────────────────────────────┐
│  Source DB                  ┌─────────────────────────────────┐  │
│  (Oracle / MySQL /          │  AWS Schema Conversion Tool     │  │
│   SQL Server / MongoDB)     │  (local desktop or AWS console) │  │
│                             └───────────────┬─────────────────┘  │
└─────────────────────────────────────────────│────────────────────┘
          │  JDBC / native protocol           │ converted DDL
          │                                   ▼
          │         ┌────────────────────────────────────────┐
          │         │  Target DB (pre-created schema)        │
          │         │  RDS / Aurora / Redshift / DynamoDB    │
          │         └────────────────────────────────────────┘
          │                       ▲
          ▼                       │ insert / update / delete
  ┌──────────────────────────────────────────────────────┐
  │  DMS Replication Instance                            │
  │  ┌───────────────────────────────────────────────┐  │
  │  │ Task: Full Load + CDC                         │  │
  │  │  1. Full Load → bulk copy all rows            │  │
  │  │  2. CDC      → stream transaction log changes │  │
  │  └───────────────────────────────────────────────┘  │
  └──────────────────────────────────────────────────────┘
```

---

## Cutover Strategy

A typical near-zero-downtime migration proceeds as:

1. **Prepare target schema** — run SCT output against the target database.
2. **Start Full Load + CDC task** — DMS copies existing data; CDC begins capturing changes.
3. **Monitor latency** — wait until CDC lag drops to seconds (target is caught up).
4. **Quiesce the application** — briefly stop writes to the source database.
5. **Verify final CDC flush** — confirm CDC lag reaches zero.
6. **Redirect application** — update connection strings to the new target.
7. **Stop the DMS task** — migration is complete.

---

## Security

*   **Credentials via Secrets Manager:** Endpoint credentials can reference [AWS Secrets Manager](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Security.SecretsManager.html) secrets instead of being stored in the DMS endpoint config.
*   **SSL/TLS:** DMS supports SSL connections to both source and target endpoints. Certificate bundles can be uploaded and assigned per endpoint.
*   **KMS Encryption:** DMS replication instance storage and task logs are encrypted with AWS KMS. You can use the default DMS key or a customer-managed key (CMK).
*   **VPC Isolation:** Replication instances are deployed inside a [replication subnet group](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_ReplicationInstance.VPC.html) within a VPC. Security groups control inbound/outbound traffic to source and target.
*   **IAM Roles:** DMS uses IAM service roles to access S3 (for logs, task reports, and S3 targets), Secrets Manager, and KMS.
*   **CloudTrail:** All DMS API calls are logged to CloudTrail for governance and compliance auditing.

---

## Monitoring

*   **[Amazon CloudWatch Metrics](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Monitoring.html):** `CDCLatencySource`, `CDCLatencyTarget`, `CDCThroughputRowsSource`, `CDCThroughputRowsTarget`, `FullLoadThroughputRowsSource`, `FullLoadThroughputRowsTarget`, `FreeableMemory`, `FreeStorageSpace`.
*   **[CloudWatch Logs](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Monitoring.html#CHAP_Monitoring.Logs):** Task-level logs show row-level events, errors, and warnings.
*   **Table Statistics:** The DMS console shows per-table row counts for inserts, updates, deletes, DDL, and full load rows.
*   **EventBridge:** DMS emits events for task state changes (replication instance created/deleted, task started/stopped/failed).

---

## Pricing

*   **Replication Instance:** Charged per instance-hour (on-demand or reserved). [See instance pricing](https://aws.amazon.com/dms/pricing/).
*   **DMS Serverless:** Charged per DCU-hour consumed based on actual replication workload.
*   **Log Storage:** EBS storage attached to the replication instance is charged per GB-month.
*   **Data Transfer:** Standard AWS data transfer rates apply for data moving between regions or out of AWS.
*   **SCT:** Free to download and use.
*   **Fleet Advisor:** Free to use (you pay for the EC2 instance running the data collector).

See [AWS DMS Pricing](https://aws.amazon.com/dms/pricing/) for current rates by region.

---

## Real-Life Use Cases

*   **Lift-and-Shift Oracle to RDS:** Migrate a 500 GB Oracle OLTP database to RDS for Oracle with minimal downtime using Full Load + CDC, then decommission the on-premises license.
*   **Engine Swap — Oracle to Aurora PostgreSQL:** Use SCT to convert the schema and stored procedures, then DMS to move the data, cutting licensing costs by 90%.
*   **Analytics Offload:** Continuously replicate a production MySQL database to Amazon Redshift using DMS CDC as a permanent data pipeline for BI dashboards.
*   **MongoDB to DocumentDB:** Migrate a MongoDB Atlas cluster to Amazon DocumentDB using DMS's MongoDB source endpoint.
*   **Multi-Database Consolidation:** Migrate dozens of smaller SQL Server databases into a single RDS Multi-AZ instance to reduce operational overhead.
*   **On-Premises to Aurora Serverless v2:** Use DMS to move a spiky-workload MySQL database to Aurora Serverless v2, achieving automatic capacity scaling at lower cost.

---

## DMS vs. Native Tools

| Scenario | Recommended Approach |
|----------|---------------------|
| Same engine, large DB, fast network | Native dump/restore (pg_dump, mysqldump, expdp) |
| Same engine, near-zero downtime | DMS Full Load + CDC |
| Different engine | SCT + DMS Full Load + CDC |
| Continuous replication to analytics | DMS CDC (ongoing) |
| Complex stored procedures/packages | SCT + manual refactoring |
| Offline, very large source | AWS Snowball Edge + DMS |

---

## Related Services

*   [Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html) — most common DMS migration target
*   [Amazon Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html) — high-performance managed relational target
*   [Amazon Redshift](https://docs.aws.amazon.com/redshift/latest/mgmt/welcome.html) — data warehouse migration target
*   [Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html) — NoSQL migration target
*   [Amazon DocumentDB](https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html) — MongoDB-compatible migration target
*   [AWS Schema Conversion Tool](https://docs.aws.amazon.com/SchemaConversionTool/latest/userguide/CHAP_Welcome.html) — schema conversion for heterogeneous migrations
*   [AWS DataSync](https://aws.amazon.com/datasync/) — file and object data migration (not databases)
*   [AWS Snowball Edge](https://aws.amazon.com/snowball/) — offline bulk data transfer for very large databases
