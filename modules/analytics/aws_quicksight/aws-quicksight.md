# Amazon QuickSight

## Overview

**Amazon QuickSight** is AWS's fully managed, serverless **business intelligence (BI) and data visualisation** service. It enables organisations to create interactive dashboards, perform ad-hoc analysis, and embed analytics into applications — all without managing any infrastructure. QuickSight uses an in-memory engine called **SPICE** (Super-fast, Parallel, In-memory Calculation Engine) for fast query performance at scale.

---

## Key Features

| Feature | Description |
|---|---|
| **SPICE Engine** | In-memory accelerated query engine — billions of rows at millisecond speed |
| **ML Insights** | Auto-detects anomalies, forecasts trends, and generates narrative summaries (Q) |
| **QuickSight Q** | Natural-language querying — ask questions in plain English to get instant answers |
| **Embedded Analytics** | Embed dashboards and visuals into custom web/mobile applications via SDK |
| **Paginated Reports** | Pixel-perfect, scheduled, printable reports (Enterprise edition) |
| **Row-level Security (RLS)** | Restrict data access per user or group at dataset level |
| **Column-level Security (CLS)** | Hide specific columns from certain users or groups |
| **Multi-tenancy** | Serve multiple customers from a single QuickSight account using namespaces |

---

## Architecture

```
Data Sources                   QuickSight                    Consumers
─────────────           ─────────────────────────         ──────────────
  Amazon S3    ──────►                                 ►  Web Browser
  Athena       ──────►  Datasets (SPICE / Direct)      ►  Mobile App
  Redshift     ──────►  ────────────────────────       ►  Embedded SDK
  RDS / Aurora ──────►  Analyses & Visuals             ►  Scheduled Email
  DynamoDB     ──────►  ────────────────────────       ►  Slack / Teams
  Salesforce   ──────►  Dashboards & Stories           ►  API consumers
  Excel / CSV  ──────►
```

---

## Core Concepts

### Datasets
A **dataset** is the connection between a data source and QuickSight. You can:
- Import data into **SPICE** for fast, in-memory performance
- Use **Direct Query** mode for live data without importing
- Apply field-level transformations, calculated fields, and RLS rules

### Analyses
An **analysis** is a draft workspace where you build and explore visualisations before publishing. Multiple sheets per analysis are supported.

### Dashboards
A **dashboard** is a read-only published version of an analysis that you share with users or embed in applications.

### Stories
**Stories** combine dashboard visuals with narrative text — useful for automated executive reporting.

---

## Data Sources

### AWS Native
| Source | Connection Type |
|---|---|
| Amazon S3 | CSV, JSON, Parquet, Excel via Manifest file |
| Amazon Athena | Direct Query / SPICE import |
| Amazon Redshift | Direct Query / SPICE import |
| Amazon RDS / Aurora | Direct Query / SPICE import |
| Amazon OpenSearch Service | Direct Query |
| Amazon DynamoDB | SPICE import only |
| AWS IoT Analytics | Direct Query |

### External / SaaS
- Salesforce, ServiceNow, JIRA
- Adobe Analytics
- GitHub, Twitter
- Any JDBC/ODBC source via private VPC connection

---

## SPICE

**SPICE** (Super-fast, Parallel, In-memory Calculation Engine) is QuickSight's proprietary in-memory query engine.

| Attribute | Detail |
|---|---|
| **Storage** | Each user gets SPICE capacity (10 GB on Standard; configurable on Enterprise) |
| **Refresh** | Schedule full or incremental refreshes; manually trigger via console or API |
| **Performance** | Sub-second queries on billions of rows |
| **Cost** | Billed per GB of SPICE capacity purchased per month |

```
                SPICE Refresh Pipeline
S3 / Redshift / RDS ──► Ingest ──► SPICE Cache ──► Dashboard Query
        (scheduled or manual)
```

---

## ML Insights

QuickSight embeds machine learning without requiring data science expertise.

| ML Feature | Description |
|---|---|
| **Anomaly Detection** | Auto-detects outliers in time-series data using Random Cut Forest |
| **Forecasting** | Projects future trends from historical data |
| **Auto-narratives** | Auto-generates written summaries of chart data |
| **QuickSight Q** | Natural language interface — type a question, get a chart |

```
Example QuickSight Q query:
  "What were the total sales by region last quarter?"
  → QuickSight auto-generates a bar chart answer
```

---

## Embedded Analytics

Use the **QuickSight Embedding SDK** (JavaScript) to embed dashboards, visuals, or the full Q bar into your own web application.

```javascript
import { createEmbeddingContext } from 'amazon-quicksight-embedding-sdk';

const embeddingContext = await createEmbeddingContext();

const embeddedDashboard = await embeddingContext.embedDashboard({
  url: 'https://us-east-1.quicksight.aws.amazon.com/embed/...',
  container: document.getElementById('dashboard-container'),
  height: '700px',
  width: '100%',
});
```

### Embedding URL Generation (Backend)

```python
import boto3

qs = boto3.client('quicksight', region_name='us-east-1')

response = qs.get_dashboard_embed_url(
    AwsAccountId='123456789012',
    DashboardId='my-dashboard-id',
    IdentityType='IAM',
    SessionLifetimeInMinutes=60,
    UndoRedoDisabled=False,
    ResetDisabled=False
)

embed_url = response['EmbedUrl']
```

---

## Security

| Control | Details |
|---|---|
| **IAM** | Control access to QuickSight APIs and admin actions |
| **QuickSight Users & Groups** | Manage who can author, view, or admin within QuickSight |
| **Row-level Security (RLS)** | Dataset-level rules restrict which rows each user sees |
| **Column-level Security (CLS)** | Hide sensitive columns (e.g., PII) per user or group |
| **VPC Connection** | Private network connection to RDS/Redshift in a VPC |
| **Encryption** | Data in SPICE encrypted at rest using AWS-managed keys |
| **Namespaces** | Isolate tenants in multi-tenant deployments |
| **MFA** | Supported for QuickSight user accounts |

---

## Pricing

| Edition | Reader | Author | Admin |
|---|---|---|---|
| **Standard** | — | $9/user/month | $9/user/month |
| **Enterprise** | $0.30/session (max $5/month) | $18/user/month | $18/user/month |
| **Enterprise + Q** | $0.30/session | $28/user/month | $28/user/month |

Additional costs:
- **SPICE capacity**: ~$0.25 per GB/month (Enterprise)
- **Paginated Reports**: $0.015 per report or $500/month unlimited
- **Q Topics**: Included in Q edition

> Use the [AWS Cost Calculator](https://calculator.aws/#/) to estimate your QuickSight spend based on user counts and SPICE usage.

---

## Common Use Cases

| Use Case | Pattern |
|---|---|
| **Executive Dashboards** | Business KPI dashboards connected to Redshift or Athena |
| **Embedded Analytics** | Customer-facing analytics embedded in SaaS applications |
| **Self-service BI** | Business users explore data via Q (natural language) without SQL |
| **Operational Reporting** | Paginated reports on schedules — emailed to stakeholders |
| **Cost & Usage Analysis** | Visualise AWS Cost & Usage Reports (CUR) from S3/Athena |
| **IoT Monitoring** | Real-time dashboards from IoT Analytics data |

---

## When to Use QuickSight vs Alternatives

| Scenario | Recommended Service |
|---|---|
| Managed BI dashboards & reports | **QuickSight** ✅ |
| Ad-hoc SQL queries on S3 | **Athena** |
| Large-scale data warehousing | **Redshift** |
| Full-text / search analytics | **OpenSearch Service** |
| Custom application with embedded charts | **QuickSight Embedded SDK** ✅ |
| Data transformation / ETL | **AWS Glue** |

---

## Terraform Resources

| Resource | Description |
|---|---|
| [`aws_quicksight_account_subscription`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_account_subscription) | Subscribe to QuickSight |
| [`aws_quicksight_user`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_user) | QuickSight user management |
| [`aws_quicksight_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_group) | QuickSight group |
| [`aws_quicksight_data_source`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_data_source) | Data source (Athena, Redshift, S3, etc.) |
| [`aws_quicksight_data_set`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_data_set) | Dataset with transformations and RLS |
| [`aws_quicksight_dashboard`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_dashboard) | Published dashboard |
| [`aws_quicksight_vpc_connection`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_vpc_connection) | VPC connection for private data sources |

---

## Useful Links

- [Amazon QuickSight Documentation](https://docs.aws.amazon.com/quicksight/latest/user/welcome.html)
- [QuickSight Embedding SDK](https://github.com/awslabs/amazon-quicksight-embedding-sdk)
- [Row-level Security](https://docs.aws.amazon.com/quicksight/latest/user/restrict-access-to-a-data-set-using-row-level-security.html)
- [QuickSight Q Overview](https://docs.aws.amazon.com/quicksight/latest/user/quicksight-q.html)
- [Terraform: aws_quicksight_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_data_source)
