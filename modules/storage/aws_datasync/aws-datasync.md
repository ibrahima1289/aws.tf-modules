# AWS DataSync

[AWS DataSync](https://aws.amazon.com/datasync/) is a fully managed online data transfer service that automates and accelerates moving data between on-premises storage, edge locations, other cloud providers, and AWS storage services. DataSync handles the undifferentiated heavy lifting of data movement — scheduling, monitoring, encryption, retries, and performance tuning — so you do not have to build or maintain custom transfer scripts.

## Core Concepts

*   **Agent-Based On-Premises Transfers:** When moving data from on-premises NFS, SMB, HDFS, or object storage, a lightweight DataSync **agent** (a virtual machine or EC2 instance) is deployed in your environment. It connects to AWS over TLS and manages the data transfer.
*   **Agentless AWS-to-AWS Transfers:** When both source and destination are AWS services (e.g., S3 to S3, EFS to EFS), no agent is required.
*   **Incremental Transfers:** After the initial full copy, DataSync detects only changed files/objects and copies only the differences, dramatically reducing transfer time and cost for recurring jobs.
*   **Parallel Data Streams:** DataSync uses multiple parallel connections to saturate available bandwidth — typically 10× faster than open-source tools like `rsync`.
*   **Data Validation:** Optionally verifies data integrity by comparing checksums at source and destination after every transfer.

---

## Key Components

### 1. Agent

The DataSync **agent** is a virtual appliance (VMware ESXi, Microsoft Hyper-V, or KVM) or an EC2 instance that you deploy near your source storage. It:

*   Reads data from the on-premises storage system (NFS, SMB, HDFS, S3-compatible, Azure Blob, Google Cloud Storage)
*   Compresses and encrypts data in transit using TLS 1.2
*   Authenticates to the DataSync service endpoint in AWS
*   Manages bandwidth throttling and retry logic

Agents are not required for transfers between two AWS services.

### 2. Locations

A **location** defines an endpoint — either a source or a destination. DataSync supports:

| Location Type | Direction | Agent Required |
|--------------|-----------|----------------|
| [Amazon S3](https://docs.aws.amazon.com/datasync/latest/userguide/create-s3-location.html) (all storage classes) | Source or Dest | No |
| [Amazon EFS](https://docs.aws.amazon.com/datasync/latest/userguide/create-efs-location.html) | Source or Dest | No |
| [Amazon FSx for Windows](https://docs.aws.amazon.com/datasync/latest/userguide/create-fsx-location.html) | Source or Dest | No |
| [Amazon FSx for Lustre](https://docs.aws.amazon.com/datasync/latest/userguide/create-fsx-lustre-location.html) | Source or Dest | No |
| [Amazon FSx for ONTAP](https://docs.aws.amazon.com/datasync/latest/userguide/create-fsx-ontap-location.html) | Source or Dest | No |
| [Amazon FSx for OpenZFS](https://docs.aws.amazon.com/datasync/latest/userguide/create-fsx-openzfs-location.html) | Source or Dest | No |
| NFS (on-premises or EC2) | Source or Dest | Yes (on-prem) |
| SMB (on-premises or EC2) | Source or Dest | Yes (on-prem) |
| HDFS (Hadoop) | Source | Yes |
| Object storage (S3-compatible, Azure Blob, GCS) | Source or Dest | Yes |
| [AWS Snowcone](https://docs.aws.amazon.com/datasync/latest/userguide/create-snowcone-location.html) | Source | Built-in |

### 3. Tasks

A **task** ties together a source location, a destination location, and a set of transfer options:

*   **Transfer Mode:** Transfer only modified files, or transfer all files regardless of modification time.
*   **Bandwidth Limit:** Throttle to a maximum MB/s to avoid saturating production network links.
*   **Scheduling:** Run on-demand or on a cron schedule (e.g., nightly at 02:00).
*   **File Filtering:** Include or exclude files by name pattern (e.g., `*.tmp`, `/logs/**`).
*   **Task Reports:** Detailed per-file transfer results stored in S3, showing status, bytes transferred, errors.
*   **Verification:** Verify data integrity after transfer (full verification or point-in-time verification).
*   **Preserve Metadata:** Optionally preserve POSIX permissions, timestamps, ownership, and extended attributes.

### 4. Task Executions

Each run of a task creates a **task execution**. You can monitor:

*   Phase: Launching → Preparing → Transferring → Verifying → Success/Error
*   Files transferred, bytes transferred, files skipped, files verified, errors
*   Duration and throughput (MB/s)

Execution details are visible in the console, CLI, and CloudWatch Metrics.

---

## Transfer Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│ On-Premises / Edge                                                   │
│                                                                      │
│  ┌────────────────┐    TLS 1.2      ┌──────────────────────────────┐ │
│  │ NFS / SMB /    │ ─────────────► │  DataSync Agent VM           │ │
│  │ HDFS / S3-comp │                │  (VMware / Hyper-V / KVM)    │ │
│  └────────────────┘                └──────────────┬───────────────┘ │
└─────────────────────────────────────────────────── │ ───────────────┘
                                                     │ TLS / Direct Connect / VPN
                         ┌───────────────────────────▼───────────────────────┐
                         │  AWS DataSync Service (managed, multi-threaded)   │
                         └───────────────────────────┬───────────────────────┘
                                                     │
              ┌──────────────────────────────────────▼─────────────────────┐
              │ Destination                                                 │
              │  Amazon S3 │ Amazon EFS │ Amazon FSx │ AWS Snowcone        │
              └────────────────────────────────────────────────────────────┘
```

---

## Security

*   **Encryption in Transit:** All data transferred by the agent is encrypted with TLS 1.2 before leaving your network.
*   **Encryption at Rest:** The destination storage service applies its own encryption (SSE-S3, SSE-KMS, EFS encryption, FSx encryption).
*   **IAM Roles:** DataSync uses IAM execution roles to read from source locations and write to destination locations. Fine-grained permissions can restrict access to specific buckets, prefixes, or file systems.
*   **VPC Endpoints:** DataSync can communicate with AWS storage services over [VPC interface endpoints](https://docs.aws.amazon.com/datasync/latest/userguide/datasync-in-vpc.html), keeping traffic off the public internet.
*   **Agent Activation:** The agent must be activated by providing a one-time activation key from the DataSync console — it cannot connect to AWS without this step.
*   **AWS PrivateLink:** Agents can be configured to use AWS PrivateLink endpoints, ensuring all traffic stays within the AWS network.

---

## Monitoring

*   **[Amazon CloudWatch Metrics](https://docs.aws.amazon.com/datasync/latest/userguide/monitor-datasync.html):** `BytesTransferred`, `FilesTransferred`, `FilesVerified`, `FilesSkipped`, `FilesDeleted`, `TaskExecutionResultStatus`.
*   **[Amazon CloudWatch Logs](https://docs.aws.amazon.com/datasync/latest/userguide/monitor-datasync.html):** Per-file transfer logs for detailed auditing; can be sent to a CloudWatch log group.
*   **[AWS CloudTrail](https://docs.aws.amazon.com/datasync/latest/userguide/security_iam_service-with-iam.html):** API-level audit trail of all DataSync control-plane operations.
*   **Task Reports:** Detailed CSV/JSON reports of each task execution stored in a specified S3 bucket.
*   **EventBridge:** Trigger Lambda functions or SNS notifications on task execution state changes (e.g., notify on failure).

---

## Pricing

*   **Data transferred:** Charged per GB transferred. There is no charge for the DataSync service itself beyond the per-GB transfer fee.
*   **Agent:** No charge for running the agent VM itself; you pay only for the EC2 instance (if deployed on EC2) or your own hypervisor.
*   **Task reports:** S3 storage charges apply for stored reports.
*   **Data transfer out of AWS:** Standard [AWS data transfer pricing](https://aws.amazon.com/ec2/pricing/on-demand/#Data_Transfer) applies for data leaving AWS.

See [AWS DataSync Pricing](https://aws.amazon.com/datasync/pricing/) for current per-GB rates by region.

---

## Real-Life Use Cases

*   **One-Time Migration to AWS:** Move a 200 TB NFS share from an on-premises NetApp to Amazon EFS in one weekend using DataSync, eliminating months of manual `rsync` scripting.
*   **Ongoing Hybrid Sync:** Keep a secondary copy of frequently updated files from an on-premises SMB share in Amazon S3 Standard-IA, synced nightly with only changed files transferred.
*   **Multi-Cloud Migration:** Migrate data from Azure Blob Storage or Google Cloud Storage to Amazon S3 using an agent deployed in the source cloud.
*   **Snowcone Field Collection:** A geophysics crew uses Snowcone in the field; when they return to a location with connectivity, DataSync automatically syncs the accumulated data to Amazon S3.
*   **Data Lake Ingestion:** Continuously ingest HDFS data from an on-premises Hadoop cluster into Amazon S3 to feed an AWS-based analytics pipeline.
*   **Cross-Region Replication:** Replicate an EFS file system from `us-east-1` to `eu-west-1` on a schedule, providing a geographically distributed backup.

---

## DataSync vs. Other Transfer Options

| Scenario | Recommended Tool |
|----------|-----------------|
| < 1 TB, fast internet | [S3 Transfer Acceleration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html) |
| > 10 TB, offline | [AWS Snow Family](https://aws.amazon.com/snow/) |
| Continuous hybrid access | [AWS Storage Gateway](https://aws.amazon.com/storagegateway/) |
| Ongoing online migration | **AWS DataSync** |
| SFTP/FTPS/FTP protocol | [AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/) |
| Database migration | [AWS DMS](https://aws.amazon.com/dms/) |

---

## Related Services

*   [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) — primary destination for most DataSync tasks
*   [Amazon EFS](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html) — fully managed NFS file system target
*   [Amazon FSx](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html) — Windows, Lustre, ONTAP, and OpenZFS file system targets
*   [AWS Snow Family](https://aws.amazon.com/snow/) — offline transfer option; Snowcone includes a built-in DataSync agent
*   [AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/) — SFTP/FTPS/FTP protocol-based transfers into S3/EFS
*   [AWS Storage Gateway](https://aws.amazon.com/storagegateway/) — hybrid cloud storage for ongoing on-premises integration
*   [AWS Backup](https://aws.amazon.com/backup/) — policy-driven backup for AWS storage services
