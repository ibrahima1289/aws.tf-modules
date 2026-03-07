# AWS Lake Formation

[AWS Lake Formation](https://aws.amazon.com/lake-formation/) is a fully managed service that makes it easy to build, secure, and manage data lakes on AWS. Lake Formation acts as a **governance and permissions layer** that sits on top of Amazon S3 (your data lake storage) and AWS Glue (your data catalog and ETL engine), providing fine-grained access control — down to individual columns and rows — that is enforced consistently across all integrated analytics services.

## Core Concepts

*   **Data Lake as S3 + Catalog:** At its core, a data lake on AWS is data stored in Amazon S3 with metadata registered in the AWS Glue Data Catalog. Lake Formation layers security, governance, and data quality on top of this foundation.
*   **Centralized Permissions:** Instead of managing S3 bucket policies, Glue catalog resource policies, and IAM policies separately for every user and service, Lake Formation provides a **unified permissions model** managed from a single place.
*   **Column-Level, Row-Level, and Cell-Level Security:** Lake Formation can restrict access so that an analyst can query a table but only see certain columns (no PII), or only rows matching a filter expression (only their department's data), or a combination of both (cell-level masking).
*   **Data Catalog:** The AWS Glue Data Catalog is the central metadata repository — databases, tables, schemas, and partitions — that Lake Formation manages and secures.
*   **Governed Tables:** A special table type in Lake Formation that supports ACID transactions and automatic data compaction on S3.
*   **Blueprints:** Pre-built workflows that ingest data from common sources (databases, log files) into the data lake with a few clicks.

---

## Key Components

### 1. Data Catalog

The [AWS Glue Data Catalog](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html) is Lake Formation's metadata store. It contains:

*   **Databases** — logical groupings of tables (e.g., `sales_db`, `hr_db`)
*   **Tables** — schema definitions pointing to S3 locations
*   **Partitions** — partition metadata for efficient query pruning
*   **Connections** — JDBC connections to external databases

Lake Formation manages permissions on catalog objects (databases, tables, columns) through its own grant/revoke model, layered on top of IAM.

### 2. Lake Formation Permissions

Lake Formation uses a **grant-based model** similar to a traditional database:

```
GRANT SELECT ON TABLE sales_db.orders
  TO PRINCIPAL analyst_role
  WITH COLUMN PERMISSIONS (order_id, product, quantity)  -- not price, customer_name
  WITH ROW FILTER (region = 'us-east-1');
```

Permission types include:

| Permission | Description |
|------------|-------------|
| `SELECT` | Query rows/columns in a table |
| `INSERT` | Write new records |
| `DELETE` | Delete records |
| `DESCRIBE` | See table schema (no data access) |
| `ALTER` | Modify table schema |
| `CREATE TABLE` | Create tables in a database |
| `DROP` | Drop tables or databases |
| `DATA_LOCATION_ACCESS` | Write to underlying S3 path |

Permissions can be granted to IAM users, roles, groups, SAML-federated identities, AWS accounts (cross-account sharing), and AWS Organizations OUs.

### 3. Fine-Grained Access Control

*   **Column-Level Security:** Grant `SELECT` on specific columns only. Analysts querying via Athena or Redshift Spectrum see only their permitted columns.
*   **Row-Level Security:** Attach a row filter expression (e.g., `department = 'engineering'`) to a grant. The analytics engine applies the filter automatically.
*   **Cell-Level Masking:** Lake Formation can apply data masks (nullify, hash, or redact) to specific cells in permitted columns for specific principals.

### 4. Registered Data Locations

To manage a data lake, Lake Formation must be granted access to the underlying S3 paths. You **register** S3 locations with Lake Formation, and Lake Formation takes ownership of the location by managing access via its service-linked role. After registration, direct S3 bucket policies alone no longer grant access — Lake Formation permissions are authoritative.

### 5. Blueprints and Workflows

[Blueprints](https://docs.aws.amazon.com/lake-formation/latest/dg/workflows-about.html) are pre-built Glue workflows that automate data ingestion:

*   **Database snapshot:** Ingest a full snapshot from a JDBC source (RDS, on-premises DB)
*   **Incremental database:** Ingest new/changed records since the last run using a bookmark column (e.g., `updated_at`)
*   **Log file:** Parse and load application logs from S3

Under the hood, blueprints create Glue crawlers, Glue jobs, and S3 targets, wired together in a Glue Workflow.

### 6. Governed Tables

[Governed tables](https://docs.aws.amazon.com/lake-formation/latest/dg/governed-tables.html) are an enhanced table type that supports:

*   **ACID transactions:** Multiple writers can update a governed table concurrently without data corruption or partial reads.
*   **Automatic compaction:** Lake Formation compacts small S3 objects in the background, improving query performance.
*   **Row-level tagging:** Optimistic concurrency control for streaming ingestion scenarios.

Governed tables are stored in S3 and queryable with Athena.

### 7. Cross-Account Data Sharing

Lake Formation enables governed data sharing across AWS accounts without moving data:

*   **Resource Links:** The consumer account creates a local catalog resource link pointing to a shared database or table in the producer account.
*   **RAM Integration:** Lake Formation uses [AWS Resource Access Manager (RAM)](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) to share catalog resources.
*   **Consumer Controls:** The consumer account's Lake Formation admin controls which IAM principals in that account can access the shared resource.

---

## Architecture Overview

```
 Producer Account
┌────────────────────────────────────────────────────────────┐
│  S3 Data Lake (registered locations)                       │
│   s3://my-lake/raw/     s3://my-lake/curated/              │
│                │                  │                        │
│  ┌─────────────▼──────────────────▼──────────────────┐    │
│  │  AWS Glue Data Catalog (databases + tables)        │    │
│  └───────────────────────┬────────────────────────────┘    │
│                          │                                  │
│  ┌───────────────────────▼────────────────────────────┐    │
│  │  Lake Formation Permissions Engine                  │    │
│  │  (column, row, cell-level grants per principal)    │    │
│  └────────────────┬──────────────────┬────────────────┘    │
│                   │                  │ Cross-account share  │
└───────────────────│──────────────────│────────────────────-┘
                    │                  │
      ┌─────────────▼───┐    ┌────────▼────────────────────┐
      │ Same-account    │    │ Consumer Account             │
      │ Analytics       │    │  Resource Links → RAM share  │
      │  Athena         │    │  Athena / Redshift Spectrum  │
      │  Redshift Spec  │    └─────────────────────────────-┘
      │  EMR            │
      │  Glue ETL       │
      └─────────────────┘
```

---

## Security

*   **Tag-Based Access Control (LF-TBAC):** Assign LF-Tags (key-value pairs like `sensitivity=high`, `domain=hr`) to catalog objects, then grant permissions on LF-Tags rather than individual tables. New tables tagged automatically inherit permissions, eliminating permission sprawl.
*   **Lake Formation Admins:** One or more IAM principals are designated as Lake Formation administrators with full permissions to manage grants.
*   **IAM + Lake Formation Dual Layer:** Both IAM policies and Lake Formation grants must allow access. If either denies, access is denied. This prevents Lake Formation grants from bypassing IAM boundaries.
*   **Audit Logging:** All data access governed by Lake Formation is logged to [CloudTrail Data Events](https://docs.aws.amazon.com/lake-formation/latest/dg/audit-logging-chapter.html) for compliance auditing (who accessed which table, when).
*   **KMS Integration:** Data stored in S3 is encrypted with KMS keys. Lake Formation does not manage KMS encryption — the underlying S3 and Glue settings handle this.
*   **VPC Integration:** Glue ETL jobs that process data in the catalog can run within a VPC, keeping data processing traffic private.

---

## Integration with Analytics Services

| Service | Lake Formation Role |
|---------|-------------------|
| [Amazon Athena](https://docs.aws.amazon.com/athena/latest/ug/what-is.html) | Query executor — Lake Formation enforces column/row filters on every query |
| [Amazon Redshift Spectrum](https://docs.aws.amazon.com/redshift/latest/dg/c-using-spectrum.html) | External table queries — Lake Formation enforces permissions |
| [AWS Glue ETL](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html) | Catalog source for Spark jobs — governed by Lake Formation |
| [Amazon EMR](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html) | Spark/Hive on EMR can use Lake Formation for fine-grained access |
| [Amazon QuickSight](https://docs.aws.amazon.com/quicksight/latest/user/welcome.html) | BI tool — queries via Athena, which Lake Formation governs |
| [AWS Glue DataBrew](https://docs.aws.amazon.com/databrew/latest/dg/what-is.html) | Visual data preparation — reads from governed catalog |

---

## Pricing

*   **Lake Formation itself:** No charge for the Lake Formation service.
*   **Underlying services:** You pay for what you use — S3 storage, Glue crawlers and ETL jobs, Athena queries, Redshift Spectrum, EMR clusters.
*   **Governed Tables:** Additional charges apply for ACID transaction support (storage of transaction logs and automatic compaction). See [AWS Lake Formation Pricing](https://aws.amazon.com/lake-formation/pricing/).

---

## Real-Life Use Cases

*   **Enterprise Data Lake Governance:** A financial services company stores customer transaction data in S3. Lake Formation ensures that analysts only see aggregated, non-PII columns, while data engineers have full access — enforced consistently across Athena, Redshift Spectrum, and EMR.
*   **Cross-Account Data Marketplace:** A data platform team (producer account) curates and shares datasets to 10 business unit accounts (consumer accounts) via Lake Formation cross-account sharing, without copying data.
*   **GDPR Compliance:** Apply column-level security to mask `email` and `phone_number` columns for all external analysts; only the privacy team's role sees raw PII.
*   **Self-Service Analytics:** Tag all tables with `domain=marketing` LF-Tags and grant the marketing team access to all tables with that tag in a single grant — automatically covering future tables added to the domain.
*   **Streaming Data Lake:** Kinesis Firehose writes JSON events to S3 governed tables. Lake Formation's ACID transactions ensure downstream Athena queries always see consistent snapshots.

---

## Lake Formation vs. S3 + IAM Only

| Capability | S3 Bucket Policies + IAM | Lake Formation |
|-----------|--------------------------|----------------|
| Column-level access control | ❌ | ✅ |
| Row-level filtering | ❌ | ✅ |
| Centralized catalog permissions | ❌ (per-service) | ✅ (unified) |
| Cross-account data sharing | Limited | ✅ (governed) |
| Tag-based permission inheritance | ❌ | ✅ |
| ACID transactions on S3 | ❌ | ✅ (governed tables) |
| Data access audit trail | S3 access logs | CloudTrail (user-level) |

---

## Related Services

*   [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) — the underlying data lake storage
*   [AWS Glue](https://docs.aws.amazon.com/glue/latest/dg/what-is-glue.html) — data catalog and ETL engine
*   [Amazon Athena](https://docs.aws.amazon.com/athena/latest/ug/what-is.html) — serverless SQL query engine over S3
*   [Amazon Redshift](https://docs.aws.amazon.com/redshift/latest/mgmt/welcome.html) — data warehouse with Spectrum for data lake queries
*   [Amazon EMR](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html) — big data processing with Spark/Hive over the data lake
*   [AWS IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) — underlying identity layer; Lake Formation works alongside IAM
*   [AWS RAM](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) — used for cross-account Lake Formation sharing
*   [AWS DMS](https://aws.amazon.com/dms/) — ingest relational database data into the data lake
