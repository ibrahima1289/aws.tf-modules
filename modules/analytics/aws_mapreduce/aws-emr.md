# Amazon EMR (Elastic MapReduce)

## Overview

**Amazon EMR** (Elastic MapReduce) is AWS's fully managed **big data platform** for processing and analysing large datasets using open-source frameworks such as **Apache Hadoop**, **Apache Spark**, **Apache Hive**, **Apache HBase**, **Presto/Trino**, **Flink**, and more. EMR provisions, configures, and tunes clusters automatically — eliminating the heavy lifting of managing distributed infrastructure.

EMR supports three deployment modes: **EMR on EC2** (classic clusters), **EMR on EKS** (Spark on Kubernetes), and **EMR Serverless** (fully managed, no cluster management).

---

## Key Features

| Feature | Description |
|---|---|
| **Managed Hadoop Ecosystem** | Pre-installed, pre-configured open-source frameworks (Spark, Hive, HBase, Presto, Flink, etc.) |
| **EMR Serverless** | Run Spark/Hive jobs without provisioning or managing clusters |
| **EMR on EKS** | Submit Spark jobs to an existing Amazon EKS cluster |
| **Auto Scaling** | Automatically scale cluster nodes up/down based on workload demand |
| **Spot Instances** | Use EC2 Spot for task nodes to reduce cost by up to 90% |
| **EMR Studio** | Managed Jupyter-based IDE for interactive development and collaboration |
| **EMR Notebooks** | Git-backed notebooks attached to live clusters |
| **Lake Formation Integration** | Fine-grained access control on S3 data lake tables |
| **S3 as Storage Layer** | Decouple compute from storage using S3 instead of HDFS |
| **Step Execution** | Submit and orchestrate jobs as ordered steps within a cluster |

---

## Deployment Modes

### 1. EMR on EC2 (Provisioned Clusters)

Traditional cluster model with full control over node types, software configurations, and lifecycle.

```
┌────────────────────────────────────────────────────┐
│                   EMR Cluster (EC2)                │
│                                                    │
│  ┌──────────────┐   ┌──────────────────────────┐   │
│  │  Master Node │   │      Core Nodes          │   │
│  │  (NameNode,  │──►│  (HDFS DataNode +        │   │
│  │   YARN RM)   │   │   YARN NodeManager)      │   │
│  └──────────────┘   └──────────────────────────┘   │
│                     ┌──────────────────────────┐   │
│                     │   Task Nodes (optional)  │   │
│                     │   (YARN NodeManager only;│   │
│                     │    Spot-friendly)        │   │
│                     └──────────────────────────┘   │
└────────────────────────────────────────────────────┘
              │                    │
       Amazon S3              Amazon S3
     (Input Data)           (Output Data)
```

### 2. EMR Serverless

No cluster provisioning — submit Spark or Hive jobs to an **application** and EMR manages all compute.

```
  Job Submission (API / console / Step Functions)
           │
  ┌────────▼───────────────────────────────────┐
  │         EMR Serverless Application         │
  │  (Spark or Hive; pre-initialised workers)  │
  │  Auto-scales workers per job               │
  └────────────────────────────────────────────┘
           │
        Amazon S3 (data in / out)
```

### 3. EMR on EKS

Run Apache Spark jobs on an existing Amazon EKS cluster.

```
  Job Submission (StartJobRun API)
           │
  ┌────────▼──────────────────┐
  │   Amazon EKS Cluster      │
  │   (Virtual Cluster)       │
  │   Spark Driver + Executors│
  │   run as Kubernetes Pods  │
  └───────────────────────────┘
           │
        Amazon S3 (data in / out)
```

---

## Cluster Node Types (EMR on EC2)

| Node Type | Role | Spot-safe? |
|---|---|---|
| **Master** | Manages cluster — runs NameNode, YARN ResourceManager, and job coordination | No (use On-Demand) |
| **Core** | Stores HDFS data and runs YARN tasks | Cautious (HDFS data loss risk on termination) |
| **Task** | Runs YARN tasks only — no HDFS data | ✅ Yes (ideal for Spot) |

---

## Supported Frameworks

| Framework | Purpose |
|---|---|
| **Apache Spark** | In-memory distributed data processing; ML, ETL, streaming |
| **Apache Hadoop MapReduce** | Batch processing using Map and Reduce phases |
| **Apache Hive** | SQL-like queries over large datasets (HiveQL) |
| **Apache HBase** | NoSQL wide-column store on top of HDFS |
| **Presto / Trino** | Fast interactive SQL on diverse data sources |
| **Apache Flink** | Real-time stream processing |
| **Apache Pig** | Scripting for complex data transformations |
| **Apache Zeppelin / Jupyter** | Interactive notebook environments |
| **TensorFlow / MXNet** | ML frameworks on EMR clusters |

---

## MapReduce Programming Model

The classic MapReduce paradigm consists of two phases:

```
Input Data (S3 / HDFS)
       │
  ┌────▼────┐
  │   Map   │  ── Transforms each input record into key-value pairs
  └────┬────┘
       │  (shuffle & sort)
  ┌────▼──────┐
  │  Reduce   │  ── Aggregates values for each unique key
  └────┬──────┘
       │
Output Data (S3 / HDFS)
```

### Example: Word Count (Hadoop MapReduce — Java concept)

```
Map phase:
  Input:  "the quick brown fox"
  Output: (the,1), (quick,1), (brown,1), (fox,1)

Shuffle & Sort:
  Groups identical keys together

Reduce phase:
  Input:  (the, [1,1,1])
  Output: (the, 3)
```

### Example: Word Count with Apache Spark (Python)

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("WordCount").getOrCreate()

# Read from S3
lines = spark.sparkContext.textFile("s3://my-bucket/input/")

# Map: split words; Reduce: count occurrences
word_counts = (
    lines
    .flatMap(lambda line: line.split(" "))
    .map(lambda word: (word.lower(), 1))
    .reduceByKey(lambda a, b: a + b)
    .sortBy(lambda x: x[1], ascending=False)
)

# Write results to S3
word_counts.saveAsTextFile("s3://my-bucket/output/word-count/")

spark.stop()
```

---

## EMR Steps

**Steps** are units of work submitted to a cluster in sequence or in parallel.

```hcl
resource "aws_emr_cluster" "example" {
  name          = "my-spark-cluster"
  release_label = "emr-7.0.0"
  applications  = ["Spark", "Hive"]

  ec2_attributes {
    subnet_id                         = aws_subnet.private.id
    instance_profile                  = aws_iam_instance_profile.emr.arn
    emr_managed_master_security_group = aws_security_group.emr_master.id
    emr_managed_slave_security_group  = aws_security_group.emr_slave.id
  }

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  core_instance_group {
    instance_type  = "m5.xlarge"
    instance_count = 2

    ebs_config {
      size                 = 100
      type                 = "gp3"
      volumes_per_instance = 1
    }
  }

  step {
    name              = "SparkETLJob"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = [
        "spark-submit",
        "--deploy-mode", "cluster",
        "--class", "com.example.ETLJob",
        "s3://my-bucket/jars/etl-job.jar",
        "--input",  "s3://my-bucket/raw/",
        "--output", "s3://my-bucket/processed/"
      ]
    }
  }

  service_role = aws_iam_role.emr_service.arn
  tags = { Name = "my-spark-cluster" }
}
```

---

## EMR Serverless Example

```hcl
resource "aws_emrserverless_application" "spark_app" {
  name          = "my-spark-app"
  release_label = "emr-7.0.0"
  type          = "SPARK"

  initial_capacity {
    initial_capacity_type = "Driver"
    initial_capacity_config {
      worker_count = 2
      worker_configuration {
        cpu    = "4 vCPU"
        memory = "16 GB"
      }
    }
  }

  maximum_capacity {
    cpu    = "200 vCPU"
    memory = "400 GB"
  }

  auto_stop_configuration {
    enabled              = true
    idle_timeout_minutes = 15
  }
}
```

---

## Storage Options

| Storage | Use Case | Notes |
|---|---|---|
| **Amazon S3** | Primary data lake storage | Recommended — decouples compute/storage; no HDFS needed |
| **HDFS (local)** | Intermediate shuffle/temp data | Local to cluster; lost when cluster terminates |
| **EMRFS** | S3-compatible Hadoop filesystem | Enables consistent S3 reads/writes from Hadoop tools |
| **Amazon EBS** | Persistent block storage for core nodes | Used alongside HDFS |

---

## Security

| Control | Details |
|---|---|
| **Encryption at Rest** | EBS volume encryption + EMRFS S3 encryption (SSE-S3/SSE-KMS) |
| **Encryption in Transit** | TLS between nodes and for EMRFS S3 traffic |
| **IAM Roles** | EC2 instance profile (data access) + EMR service role (cluster management) |
| **VPC** | Deploy cluster in a private VPC subnet; use security groups |
| **Kerberos** | Optional Kerberos authentication for cluster nodes |
| **Lake Formation** | Column- and row-level access control on Glue Catalog tables |
| **AWS CloudTrail** | API audit logging for all EMR operations |
| **EMR Block Public Access** | Prevents clusters from launching with public-facing ports |

---

## Auto Scaling

EMR can automatically scale core and task node groups based on YARN metrics.

```json
{
  "Constraints": {
    "MinCapacity": 2,
    "MaxCapacity": 20
  },
  "Rules": [
    {
      "Name": "ScaleOutOnYARNMemory",
      "Action": { "SimpleScalingPolicyConfiguration": { "ScalingAdjustment": 2, "CoolDown": 300 } },
      "Trigger": {
        "CloudWatchAlarmDefinition": {
          "MetricName": "YARNMemoryAvailablePercentage",
          "ComparisonOperator": "LESS_THAN",
          "Threshold": 15,
          "Period": 300
        }
      }
    }
  ]
}
```

---

## Monitoring

| Tool | Metrics |
|---|---|
| **Amazon CloudWatch** | Cluster health, running/pending containers, YARN memory, HDFS utilisation |
| **EMR Console** | Step status, application history, cluster events |
| **Spark History Server** | Spark job DAGs, stage timings, executor metrics |
| **Ganglia** | Real-time cluster metrics dashboard (EC2 mode) |
| **CloudTrail** | API-level audit logging |

---

## Pricing

| Component | Pricing Model |
|---|---|
| **EMR on EC2** | Per-second EMR fee per instance type + EC2 instance cost |
| **EMR Serverless** | Per vCPU-second + per GB-memory-second consumed |
| **EMR on EKS** | Per-second EMR fee per vCPU/memory used by Spark pods |
| **Spot Instances** | Up to 90% savings for task nodes vs On-Demand |
| **S3 storage** | Standard S3 rates for input/output data |

> Use the [AWS Cost Calculator](https://calculator.aws/#/) to estimate costs for your cluster size and job frequency.

---

## Common Use Cases

| Use Case | Pattern |
|---|---|
| **Large-scale ETL** | Read raw S3 data → transform with Spark → write Parquet to S3 data lake |
| **Machine Learning** | Train ML models with Spark MLlib or TensorFlow on large feature sets |
| **Log Processing** | Aggregate and analyse petabytes of application/infrastructure logs |
| **Data Lake Hydration** | Move data from RDBMS/Kafka into S3-based data lake |
| **Ad-hoc Analytics** | Interactive Presto/Trino queries on S3 via EMR Studio notebooks |
| **Genomics / Scientific Computing** | Parallel processing of large scientific datasets |

---

## When to Use EMR vs Alternatives

| Scenario | Recommended Service |
|---|---|
| Batch Spark/Hadoop ETL on large datasets | **EMR** ✅ |
| Simple ad-hoc SQL queries on S3 | **Athena** |
| Serverless ETL (Python/Scala, no cluster) | **AWS Glue** |
| Real-time stream processing | **Kinesis / MSK / Flink on EMR** |
| Data warehousing (structured analytics) | **Redshift** |
| Search and log analytics | **OpenSearch Service** |
| BI dashboards | **QuickSight** |

---

## Terraform Resources

| Resource | Description |
|---|---|
| [`aws_emr_cluster`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_cluster) | Provisioned EMR on EC2 cluster |
| [`aws_emr_instance_group`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_instance_group) | Additional instance group for a cluster |
| [`aws_emr_instance_fleet`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_instance_fleet) | Instance fleet with mixed On-Demand/Spot |
| [`aws_emr_security_configuration`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_security_configuration) | Encryption and security settings |
| [`aws_emrserverless_application`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emrserverless_application) | EMR Serverless application |
| [`aws_emr_studio`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_studio) | Managed Jupyter-based IDE |
| [`aws_emr_studio_session_mapping`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_studio_session_mapping) | User/group access to EMR Studio |

---

## Useful Links

- [Amazon EMR Documentation](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-what-is-emr.html)
- [EMR Serverless Documentation](https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/emr-serverless.html)
- [EMR on EKS Documentation](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/emr-eks.html)
- [EMR Best Practices](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-plan.html)
- [Terraform: aws_emr_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_cluster)
