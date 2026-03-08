# AWS Transfer Family

[AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/) is a fully managed file transfer service that lets you seamlessly migrate and run SFTP, FTPS, FTP, and AS2 (Applicability Statement 2) workflows directly into and out of Amazon S3 and Amazon EFS — without changing your clients, scripts, or partners. AWS manages the server infrastructure, high availability, auto-scaling, and protocol handling so you can focus on your business workflows.

## Core Concepts

*   **Protocol Lift-and-Shift:** Existing SFTP/FTPS/FTP clients connect to an AWS Transfer Family server exactly as they would connect to an on-premises FTP server. No client changes are required.
*   **Storage-Backed:** All files land directly in Amazon S3 or Amazon EFS. There is no intermediate storage tier — the file transfer server is a protocol gateway, not a separate file store.
*   **Managed File Transfer (MFT):** Transfer Family can trigger post-upload workflows (e.g., virus scanning, format conversion, routing) using Lambda, making it a full managed file transfer platform.
*   **B2B EDI via AS2:** The AS2 protocol enables encrypted, signed, and receipted machine-to-machine file exchange, used extensively for EDI (Electronic Data Interchange) with trading partners.
*   **Identity Flexibility:** Authenticate users with service-managed keys/passwords, Active Directory, AWS IAM Identity Center, or a custom identity provider via Lambda.

---

## Key Components

### 1. Servers (Endpoints)

A Transfer Family **server** is the managed endpoint your clients connect to. When creating a server, you choose:

*   **Protocol:** SFTP, FTPS, FTP, or AS2 (one or multiple protocols per server)
*   **Endpoint Type:**

| Endpoint Type | Description |
|--------------|-------------|
| **Public** | Publicly accessible endpoint with a DNS name managed by AWS (`server-id.server.transfer.region.amazonaws.com`) |
| **VPC** | Endpoint deployed inside your VPC; can be exposed to the internet via Elastic IP addresses |
| **VPC Internal** | Accessible only from within your VPC or connected networks (Direct Connect, VPN) — no internet access |

*   **Storage Backend:** Amazon S3 or Amazon EFS
*   **Custom Hostname:** Map a friendly domain (e.g., `sftp.mycompany.com`) using [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) or any DNS provider, pointing to the Transfer Family endpoint.

### 2. Protocols Supported

| Protocol | Port | Use Case |
|----------|------|----------|
| **SFTP** (SSH File Transfer Protocol) | 22 | Standard secure file transfer; most common |
| **FTPS** (FTP over SSL/TLS) | 990 (implicit), 21 (explicit) | Legacy partners requiring FTP with TLS |
| **FTP** (unencrypted) | 21 | Internal-only, trusted network transfers |
| **AS2** (Applicability Statement 2) | 443 | EDI partner exchange (X12, EDIFACT messages) |

SFTP and FTPS are the most commonly used protocols. FTP is available for backward compatibility but is strongly discouraged over the internet. AS2 is purpose-built for B2B EDI.

### 3. Users and Identity Providers

Transfer Family supports four identity provider types:

*   **Service Managed:** Users are created directly in the Transfer Family console with SSH public keys (SFTP/FTPS) or passwords (FTPS/FTP). Home directories and IAM roles are assigned per user.
*   **AWS IAM Identity Center:** Federate with corporate SSO for SFTP access.
*   **Active Directory (AWS Managed Microsoft AD or self-managed):** Authenticate users against an existing Windows AD domain using SFTP.
*   **Custom Lambda Provider:** Call any identity backend (LDAP, database, REST API) via a Lambda function that returns the user's IAM role, home directory, and allowed keys.

Each user is mapped to:
*   An **IAM role** that determines which S3 buckets or EFS paths they can access
*   A **home directory** (a specific S3 prefix or EFS directory)
*   Optionally, a **logical directory mapping** to present a virtual directory structure to the client (abstracting the underlying S3 path)

### 4. Managed Workflows

[Transfer Family managed workflows](https://docs.aws.amazon.com/transfer/latest/userguide/transfer-workflows.html) run automatically after a file upload completes. Steps can include:

*   **Copy** — copy the file to another S3 prefix or bucket
*   **Tag** — apply S3 object tags (e.g., `source=sftp-partner`)
*   **Delete** — remove the original file after processing
*   **Decrypt** — decrypt PGP-encrypted files using a Lambda step
*   **Custom Lambda** — run any business logic (virus scan, format validation, triggering a downstream pipeline)
*   **Decompress** — unzip compressed uploads

Workflows are chained into pipelines and execute asynchronously after every successful upload.

### 5. AS2 Connectors and Agreements

For B2B EDI via AS2:

*   **Agreements:** Define the relationship between your local profile (your company's AS2 ID and certificate) and a partner profile (partner's AS2 ID and certificate).
*   **Connectors:** Enable **outbound** AS2 transfers from your S3 bucket to a trading partner's AS2 server. Transfer Family actively initiates the connection and delivers the message.
*   **Inbound:** Partners push AS2 messages to your Transfer Family server endpoint. Transfer Family validates signatures, decrypts, and stores in S3.

---

## Transfer Architecture

```
 External Clients / Partners
┌──────────────────────────────────────────────────────────────────┐
│  SFTP Client  │  FTPS Client  │  AS2 Trading Partner             │
│  (FileZilla,  │  (legacy ERP) │  (EDI X12 / EDIFACT)             │
│   WinSCP,     │               │                                  │
│   scripts)    │               │                                  │
└──────┬────────┴──────┬────────┴──────────────────────────────────┘
       │ port 22       │ port 990/21         │ port 443
       └───────────────┴─────────────────────┘
                               │
                ┌──────────────▼─────────────────────────────────┐
                │  AWS Transfer Family Server                    │
                │  (managed, HA, multi-AZ)                       │
                │  Identity Provider: Service / AD / Lambda      │
                │  Managed Workflows → Lambda steps              │
                └──────────────┬─────────────────────────────────┘
                               │ IAM role per user
              ┌────────────────▼──────────────────────────┐
              │ Storage Backend                           │
              │  Amazon S3 (prefix per user)              │
              │  Amazon EFS (directory per user)          │
              └───────────────────────────────────────────┘
```

---

## Security

*   **Encryption in Transit:** SFTP uses SSH encryption; FTPS uses TLS 1.2+; AS2 uses S/MIME signing and encryption (CMS). FTP is unencrypted — use only on trusted internal networks.
*   **Encryption at Rest:** Files are stored in S3 or EFS with SSE-S3, SSE-KMS, or customer-managed KMS keys.
*   **IAM Role Scoping:** Each Transfer user is assigned an IAM role scoped to their home directory. Using an S3 bucket policy condition like `s3:prefix` prevents users from accessing other users' data.
*   **VPC Security Groups:** VPC and VPC Internal endpoints are protected by security groups — restrict inbound access to partner IP ranges.
*   **SSH Host Key Rotation:** Transfer Family allows you to import and manage your own SSH host keys, so clients can verify the server identity and keys can be rotated without causing trust errors.
*   **AS2 Message Security:** AS2 agreements enforce signing (non-repudiation) and encryption per partner. Transfer Family manages certificate storage and validation.
*   **CloudTrail Audit:** All API calls and file transfer events (connect, disconnect, upload, download) are logged to CloudTrail and optionally to CloudWatch Logs.

---

## Monitoring

*   **[Amazon CloudWatch Metrics](https://docs.aws.amazon.com/transfer/latest/userguide/monitoring.html):** `FilesIn`, `FilesOut`, `BytesIn`, `BytesOut`, `OnlineUserCount`.
*   **[CloudWatch Logs](https://docs.aws.amazon.com/transfer/latest/userguide/monitoring.html):** Server-level logs show per-connection and per-transfer events. Enable at the server level with a CloudWatch log group ARN.
*   **[AWS CloudTrail](https://docs.aws.amazon.com/transfer/latest/userguide/security-incident-response.html):** API-level audit trail (who created users, changed IAM roles, modified server config).
*   **S3 Event Notifications / EventBridge:** Trigger downstream processing when a file lands in S3 (e.g., kick off a Step Functions workflow).
*   **Workflow Execution Logs:** Managed workflow steps log success/failure details to CloudWatch Logs for each uploaded file.

---

## Pricing

*   **Server Uptime:** Charged per protocol-hour the server is enabled (regardless of active connections). A server with SFTP and FTPS enabled is charged for two protocol-hours per hour.
*   **Data Uploaded:** Charged per GB uploaded to S3 or EFS.
*   **Data Downloaded:** Charged per GB downloaded from S3 or EFS.
*   **AS2 Messages:** Charged per AS2 message (MDN and payload counted separately).
*   **Managed Workflows:** Charged per file processed through a workflow.
*   **No charge** for the underlying S3 storage (S3 storage is billed separately by S3).

See [AWS Transfer Family Pricing](https://aws.amazon.com/aws-transfer-family/pricing/) for current rates.

> **Cost tip:** Disable servers when not in use (e.g., test servers outside business hours) — you are not charged for stopped servers.

---

## Real-Life Use Cases

*   **Legacy SFTP Server Migration:** Replace an on-premises WS_FTP or OpenSSH server with Transfer Family. All existing client connections, keys, and scripts work unchanged — files now land in S3.
*   **Partner File Exchange:** Healthcare company receives HL7/EDI files from insurance partners via SFTP. A managed workflow triggers a Lambda that validates and routes each file to the correct processing queue.
*   **B2B EDI via AS2:** A retailer exchanges X12 850 purchase orders and X12 856 advance ship notices with suppliers via AS2, with Transfer Family handling the protocol, signature verification, and MDN receipts.
*   **Secure File Drop Box:** Each vendor has an SFTP account mapped to their own S3 prefix (logical home directory). IAM scoping ensures they can only see their own files.
*   **Compliance-Driven FTPS:** A financial services firm's regulators require FTPS delivery of daily reports. Transfer Family's FTPS server sends to a regulator endpoint using the AS2 connector.
*   **Internal ETL Ingestion:** Internal batch jobs deposit CSV files via SFTP. A managed workflow unzips, tags with the ingestion date, and triggers a Glue crawler to update the data catalog.

---

## Transfer Family vs. Alternatives

| Scenario | Recommended |
|----------|------------|
| SFTP to S3 / EFS | **AWS Transfer Family** |
| Large-scale bulk migration | [AWS DataSync](https://aws.amazon.com/datasync/) |
| Offline / no connectivity | [AWS Snow Family](https://aws.amazon.com/snow/) |
| Ongoing hybrid storage | [AWS Storage Gateway](https://aws.amazon.com/storagegateway/) |
| Database migration | [AWS DMS](https://aws.amazon.com/dms/) |

---

## Related Services

*   [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) — primary file storage backend for Transfer Family
*   [Amazon EFS](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html) — NFS-based storage backend for POSIX file system requirements
*   [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) — custom identity providers and managed workflow steps
*   [AWS DataSync](https://aws.amazon.com/datasync/) — high-speed bulk data transfer; complementary to Transfer Family
*   [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html) — custom SFTP hostname DNS mapping
*   [AWS Certificate Manager](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html) — TLS certificates for FTPS servers
*   [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) — store SFTP user credentials and AS2 certificates
*   [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) — audit trail for all Transfer Family API and transfer events
