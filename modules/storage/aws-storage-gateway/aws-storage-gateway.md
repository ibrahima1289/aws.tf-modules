# AWS Storage Gateway

[AWS Storage Gateway](https://aws.amazon.com/storagegateway/) is a hybrid cloud storage service that gives your on-premises applications access to virtually unlimited AWS cloud storage through standard storage protocols (NFS, SMB, iSCSI, VTL). The gateway runs as a virtual machine (VM) on your on-premises hypervisor or as a dedicated hardware appliance, providing a local cache for low-latency access to frequently used data while seamlessly tiering cold data to Amazon S3, Amazon FSx for Windows File Server, Amazon EBS snapshots, or Amazon S3 Glacier.

## Core Concepts

*   **Hybrid Cloud Bridge:** Storage Gateway acts as a transparent bridge — your existing servers and applications interact with NFS, SMB, or iSCSI protocols as if talking to a local storage array, while the gateway asynchronously syncs data to AWS.
*   **Local Cache:** Frequently accessed data is cached on the gateway's local disk (or the hardware appliance's NVMe cache), delivering low-latency access without requiring all data to be recalled from the cloud.
*   **Transparent Tiering:** Cold or infrequently accessed data is automatically tiered to cost-efficient AWS storage (S3, S3 Glacier Flexible Retrieval, S3 Glacier Deep Archive) without any application changes.
*   **Four Gateway Types:** Each type maps to a specific use case — File (NFS/SMB), File (FSx), Volume (block storage), and Tape (virtual tape library).
*   **On-Premises or AWS:** Gateways run as a VM on VMware ESXi, Microsoft Hyper-V, or KVM, or as an Amazon EC2 instance for cloud-side access. A dedicated [Storage Gateway Hardware Appliance](https://aws.amazon.com/storagegateway/hardware-appliance/) is also available for environments without a hypervisor.

---

## Key Components

### 1. Gateway Types

AWS Storage Gateway offers four distinct gateway types:

#### 1.1 S3 File Gateway

*   **Protocol:** NFS v3/v4.1 and SMB 2/3
*   **Backend:** Amazon S3 (any storage class)
*   **Use case:** Expose S3 buckets as a shared NFS/SMB file share to on-premises Linux and Windows servers
*   **Key features:**
    *   Files are stored as individual S3 objects (1:1 mapping — file = object)
    *   Supports S3 Intelligent-Tiering, S3 Standard-IA, S3 Glacier Instant Retrieval as target storage class
    *   Integrated with S3 lifecycle policies, S3 Replication, S3 Object Lock, and S3 Event Notifications
    *   Active Directory integration for SMB share authentication
    *   Cache local writes and serve reads from cache before falling back to S3

#### 1.2 FSx File Gateway

*   **Protocol:** SMB 2/3 (Windows-native)
*   **Backend:** Amazon FSx for Windows File Server
*   **Use case:** Extend an Amazon FSx for Windows File Server share to on-premises Windows clients with a local cache
*   **Key features:**
    *   Full Windows ACL and DFS namespace support
    *   Local cache dramatically reduces latency for frequently accessed home directories and shared drives
    *   Same FSx file system is accessible from both AWS (EC2, ECS, EKS) and on-premises simultaneously

#### 1.3 Volume Gateway — Cached Mode

*   **Protocol:** iSCSI (block storage)
*   **Backend:** Amazon S3 (primary) + Amazon EBS (snapshots)
*   **Use case:** Present cloud-backed block volumes to on-premises servers as iSCSI LUNs
*   **Key features:**
    *   Primary data stored in S3; only the working set is cached locally
    *   Point-in-time EBS snapshots can be taken on demand or on schedule
    *   Snapshots can be restored as EBS volumes, enabling rapid migration to EC2
    *   Volumes appear as local iSCSI targets to Windows/Linux servers (usable by any iSCSI initiator)

#### 1.4 Volume Gateway — Stored Mode

*   **Protocol:** iSCSI (block storage)
*   **Backend:** Local disk (primary) + Amazon S3 (asynchronous backup via EBS snapshots)
*   **Use case:** On-premises servers need full local performance; cloud backup is secondary
*   **Key features:**
    *   All data is stored on-premises for minimum latency; snapshots are sent to S3 asynchronously
    *   Disaster recovery: restore EBS snapshots to AWS EC2 after an on-premises outage
    *   Lower bandwidth consumption than cached mode (only snapshot deltas are sent to AWS)

#### 1.5 Tape Gateway (Virtual Tape Library — VTL)

*   **Protocol:** iSCSI VTL (virtual tape drives + virtual tape library media changer)
*   **Backend:** Amazon S3 (active tapes) → Amazon S3 Glacier Flexible Retrieval or Glacier Deep Archive (archived tapes)
*   **Use case:** Replace physical tape infrastructure with a cloud-backed VTL compatible with existing backup software (Veeam, Commvault, Veritas NetBackup, Backup Exec, etc.)
*   **Key features:**
    *   Presents a virtual tape library with virtual drives and cartridges to backup software — no application changes required
    *   Active virtual tapes stored in S3 for fast retrieval; archive to Glacier with a single click (or automatically after a threshold)
    *   Eliminates tape rotation logistics, off-site courier costs, and hardware refresh cycles
    *   Unlimited virtual tape capacity (up to 5 PB per tape shelf)

---

## Gateway Type Comparison

| Feature | S3 File | FSx File | Volume Cached | Volume Stored | Tape |
|---------|---------|---------|--------------|--------------|------|
| Protocol | NFS / SMB | SMB | iSCSI | iSCSI | iSCSI VTL |
| Primary storage | Amazon S3 | FSx for Windows | Amazon S3 | Local disk | Amazon S3 |
| Local cache | Yes | Yes | Yes (hot data) | Yes (all data) | Yes |
| Cold tier | S3 storage classes | FSx | EBS snapshots | EBS snapshots | Glacier |
| Windows ACLs | SMB only | Yes (full) | N/A | N/A | N/A |
| Block storage | No | No | Yes | Yes | No |
| Backup software compat. | No | No | Limited | Limited | Yes (VTL) |
| Typical use case | Hybrid file shares | Windows home dirs | DR block volumes | On-prem + DR | Tape replacement |

---

## Architecture Overview

```
  On-Premises
┌──────────────────────────────────────────────────────────────────────┐
│  Application Servers / Backup Software / File Clients                │
│       │ NFS/SMB         │ iSCSI           │ iSCSI VTL                │
│  ┌────▼──────────────────▼─────────────────▼────────────────────┐   │
│  │         Storage Gateway VM (VMware / Hyper-V / KVM)          │   │
│  │         or Hardware Appliance                                  │   │
│  │   ┌─────────────────────────────────────────────────────┐    │   │
│  │   │  Local Cache (SSD / NVMe)  ← hot data served here  │    │   │
│  │   └───────────────────────┬─────────────────────────────┘    │   │
│  └───────────────────────────│────────────────────────────────── │   │
└───────────────────────────── │ ──────────────────────────────────┘
                               │ Internet / Direct Connect / VPN
              ┌────────────────▼───────────────────────────────────┐
              │  AWS Storage Backend                               │
              │  S3 File → Amazon S3 (any class)                  │
              │  FSx File → Amazon FSx for Windows                │
              │  Volume  → Amazon S3 + EBS Snapshots              │
              │  Tape    → Amazon S3 → S3 Glacier Deep Archive    │
              └────────────────────────────────────────────────────┘
```

---

## Security

*   **Encryption in Transit:** All data sent from the gateway to AWS is encrypted using TLS 1.2 over HTTPS. For iSCSI volumes, CHAP authentication protects the iSCSI connection.
*   **Encryption at Rest:** Data stored in S3 is encrypted with SSE-S3 or SSE-KMS. EBS snapshots are encrypted with KMS. Glacier archives are encrypted with AES-256.
*   **Customer-Managed Keys (CMK):** You can specify a KMS CMK for encrypting S3 objects written by the gateway.
*   **VPC Endpoints:** Storage Gateway can communicate with AWS services over [VPC interface endpoints](https://docs.aws.amazon.com/storagegateway/latest/userguide/gateway-private-link.html) (AWS PrivateLink), keeping traffic off the public internet.
*   **IAM Roles:** The gateway uses an IAM service role with scoped permissions to write to specific S3 buckets, read/write FSx file systems, create EBS snapshots, and access KMS keys.
*   **Active Directory:** S3 File Gateway and FSx File Gateway support AD integration for SMB authentication, enforcing Windows ACLs and user-level access controls.
*   **CloudTrail:** All Storage Gateway API calls are logged to CloudTrail for audit and compliance.

---

## Monitoring

*   **[Amazon CloudWatch Metrics](https://docs.aws.amazon.com/storagegateway/latest/userguide/monitoring-overview.html):** `CacheHitPercent`, `CacheUsed`, `CloudBytesUploaded`, `CloudBytesDownloaded`, `ReadBytes`, `WriteBytes`, `QueuedWrites`, `TimeSinceLastRecoveryPoint`.
*   **[CloudWatch Alarms](https://docs.aws.amazon.com/storagegateway/latest/userguide/monitoring-overview.html):** Alert on `CacheHitPercent` dropping below threshold (cache too small), or `QueuedWrites` growing (upload bandwidth saturation).
*   **[CloudWatch Logs](https://docs.aws.amazon.com/storagegateway/latest/userguide/monitoring-overview.html):** SMB and NFS audit logs (file-level access events) for S3 and FSx File Gateways.
*   **[CloudTrail](https://docs.aws.amazon.com/storagegateway/latest/userguide/logging-using-cloudtrail.html):** API-level audit trail of all gateway management operations.
*   **Health Notifications:** The Storage Gateway console shows gateway connectivity status, last successful upload time, and available cache.

---

## Pricing

*   **S3 File Gateway:** Charged per GB of data written to S3 via the gateway. Standard S3 storage and request pricing also applies.
*   **FSx File Gateway:** No additional charge for the gateway; you pay for the underlying FSx for Windows File Server.
*   **Volume Gateway:** Charged per GB-month of data stored in AWS (snapshots in S3/EBS) plus per GB written to the cloud.
*   **Tape Gateway:** Charged per GB-month of virtual tape data stored in S3 (active tapes) and Glacier (archived tapes) plus per GB written.
*   **Hardware Appliance:** One-time hardware purchase price (no subscription fee for the appliance itself).
*   **Data Transfer Out of AWS:** Standard data transfer rates apply for data retrieved from AWS to the gateway.

See [AWS Storage Gateway Pricing](https://aws.amazon.com/storagegateway/pricing/) for current rates by region and gateway type.

---

## Real-Life Use Cases

*   **Hybrid Cloud File Share:** A media company's on-premises video editing workstations mount an NFS share backed by S3 File Gateway. Working footage is cached locally for sub-millisecond access; finished content is automatically tiered to S3 Standard-IA.
*   **Tape Modernization:** A healthcare provider's Veeam backup jobs write to a virtual tape library (Tape Gateway). Virtual tapes are automatically archived to S3 Glacier Deep Archive at $0.00099/GB-month — eliminating physical tape costs.
*   **Disaster Recovery for Block Storage:** An ERP system's data volumes are backed by Volume Gateway (Stored Mode). Daily EBS snapshots are taken automatically. After an on-premises disaster, snapshots are restored as EBS volumes attached to EC2 within minutes.
*   **Windows Home Directories:** A company's 500 Windows workstations connect to FSx File Gateway for home directory shares. The local cache handles daily active files; FSx stores the full dataset with Windows ACLs intact.
*   **Backup to Cloud:** Legacy UNIX servers use iSCSI Volume Gateway (Cached Mode) as their backup target. No changes to backup scripts required — the gateway presents standard iSCSI LUNs.
*   **Compliance Archive:** Legal documents stored via S3 File Gateway with SSE-KMS encryption and S3 Object Lock (WORM) for SEC 17a-4 compliance.

---

## Storage Gateway vs. Other Options

| Scenario | Recommended |
|----------|------------|
| Ongoing on-premises file/block access to AWS | **AWS Storage Gateway** |
| One-time or recurring bulk data migration | [AWS DataSync](https://aws.amazon.com/datasync/) |
| Offline, > 10 TB migration | [AWS Snow Family](https://aws.amazon.com/snow/) |
| SFTP / FTPS protocol access to S3 | [AWS Transfer Family](https://aws.amazon.com/aws-transfer-family/) |
| Fully cloud-native file system | Amazon EFS or FSx (no gateway) |

---

## Related Services

*   [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) — primary backend for S3 File Gateway and Volume Gateway
*   [Amazon FSx for Windows File Server](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html) — backend for FSx File Gateway
*   [Amazon S3 Glacier](https://docs.aws.amazon.com/amazonglacier/latest/dev/introduction.html) — archive tier for Tape Gateway virtual tapes
*   [Amazon EBS Snapshots](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSSnapshots.html) — snapshot target for Volume Gateway; restores to EC2 for DR
*   [AWS Backup](https://aws.amazon.com/backup/) — centralized backup policy management including Storage Gateway volumes
*   [AWS DataSync](https://aws.amazon.com/datasync/) — high-throughput online data migration (complementary to Storage Gateway)
*   [AWS Snow Family](https://aws.amazon.com/snow/) — offline data transfer for large migrations
*   [AWS Direct Connect](https://aws.amazon.com/directconnect/) — dedicated private network connection for Storage Gateway deployments requiring consistent low-latency bandwidth
