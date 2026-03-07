# AWS Backup

[AWS Backup](https://aws.amazon.com/backup/) is a fully managed, centralized backup service that automates and consolidates the backup of data across AWS services and on-premises storage. Rather than configuring backup policies service by service, AWS Backup lets you define a single **backup plan** that applies to any supported resource across your entire AWS organization.

## Core Concepts

*   **Centralized Backup Management:** One place to define schedules, retention rules, lifecycle policies, and compliance reports for all supported AWS resources.
*   **Policy-Driven:** Backup plans are attached to resources via **resource assignments** (tag-based or explicit ARN). Any new resource that matches the tag is automatically protected.
*   **Backup Vaults:** Encrypted storage containers where recovery points are stored. Vaults are isolated from production — deleting a resource does not delete its backups.
*   **Cross-Region and Cross-Account Copies:** Recovery points can be automatically copied to a different AWS Region or a different AWS account, enabling disaster recovery and organizational separation of backup data.
*   **Compliance and Reporting:** Built-in compliance frameworks (e.g., PCI, HIPAA, NIST) and AWS Backup Audit Manager generate reports showing whether backup SLAs are being met.

---

## Key Components

### 1. Backup Plans

A **backup plan** is the core policy object. It defines:

*   **Backup Rules:** Schedule (cron or rate expression), backup window, lifecycle (transition to cold storage after N days, expire after M days), and optional cross-region/cross-account copy.
*   **Resource Assignments:** Which resources to protect — by resource ARN, tag key/value pair, or all resources of a given type in an account/org.

```
Backup Plan
├── Rule 1: Daily at 03:00 UTC, retain 35 days
│     └── Copy to us-west-2 vault, retain 90 days
└── Rule 2: Weekly on Sunday, retain 1 year
      └── Transition to cold storage after 30 days
```

### 2. Backup Vaults

*   **Default Vault:** Created automatically in each region.
*   **Custom Vaults:** You can create multiple vaults with different [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) keys, IAM access policies, and vault lock settings.
*   **Vault Lock:** Makes recovery points immutable (WORM — Write Once Read Many). Once locked, even the root user cannot delete backups before the retention period expires. Supports compliance with SEC 17a-4(f), CFTC 1.31, FINRA 4370.

### 3. Recovery Points

A **recovery point** is an individual backup snapshot stored in a vault. Its format depends on the source resource (e.g., EBS snapshot, RDS snapshot, DynamoDB export).

*   Stored with metadata: resource ARN, resource type, creation time, lifecycle status, vault name, encryption key.
*   Can be restored to the original account/region or cross-account/cross-region.

### 4. Supported Resources

| Service | Backup Type |
|---------|-------------|
| [Amazon EBS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEBS.html) | Volume snapshots |
| [Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) | AMI + EBS snapshots |
| [Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html) | DB snapshots |
| [Amazon Aurora](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/CHAP_AuroraOverview.html) | Cluster snapshots |
| [Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html) | On-demand backups |
| [Amazon EFS](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html) | File system backups |
| [Amazon FSx](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html) | File system backups |
| [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) | Continuous backups (PITR) |
| [AWS Storage Gateway](https://docs.aws.amazon.com/storagegateway/latest/userguide/WhatIsStorageGateway.html) | Volume Gateway volumes |
| [Amazon DocumentDB](https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html) | Cluster snapshots |
| [Amazon Neptune](https://docs.aws.amazon.com/neptune/latest/userguide/intro.html) | Cluster snapshots |
| [Amazon Timestream](https://docs.aws.amazon.com/timestream/latest/developerguide/what-is-timestream.html) | Table backups |
| [VMware Cloud on AWS](https://docs.aws.amazon.com/backup/latest/devguide/vmware-backups.html) | VM snapshots |

### 5. AWS Backup Audit Manager

[AWS Backup Audit Manager](https://docs.aws.amazon.com/aws-backup/latest/devguide/aws-backup-audit-manager.html) lets you define **backup controls** — guardrails that check whether your resources are being backed up in compliance with your policies.

*   **Controls:** Pre-built (e.g., "Backup resources must have a backup plan") or custom.
*   **Frameworks:** Group multiple controls into a named compliance framework aligned with a regulatory standard.
*   **Reports:** Daily compliance reports delivered to S3, showing which resources are compliant or non-compliant.

### 6. AWS Backup Gateway (VMware)

[AWS Backup Gateway](https://docs.aws.amazon.com/aws-backup/latest/devguide/backup-gateway.html) extends AWS Backup to on-premises VMware environments without requiring you to migrate VMs to AWS first.

*   Deploys a virtual appliance in your VMware vSphere, VMware Cloud, or Hyper-V environment.
*   Backs up VMware VMs directly to AWS Backup vaults.
*   Restore VMs to VMware or to [Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html).

---

## Backup Job Lifecycle

```
┌──────────────────────────────────────────────────────────────────────┐
│ Backup Plan triggers at scheduled time                               │
└────────────────────────────┬─────────────────────────────────────────┘
                             ↓
┌──────────────────────────────────────────────────────────────────────┐
│ AWS Backup creates a backup job for each matched resource            │
│ • Initiates snapshot / export on the source service                  │
└────────────────────────────┬─────────────────────────────────────────┘
                             ↓
┌──────────────────────────────────────────────────────────────────────┐
│ Recovery point stored in Backup Vault (encrypted, tagged)            │
│ • Lifecycle rule: transition to cold storage → expire                │
└────────────────────────────┬─────────────────────────────────────────┘
                             ↓
┌──────────────────────────────────────────────────────────────────────┐
│ Copy job (optional): copy recovery point to another region/account   │
└────────────────────────────┬─────────────────────────────────────────┘
                             ↓
┌──────────────────────────────────────────────────────────────────────┐
│ Restore job (on demand): restore recovery point to new resource      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Security

*   **Vault Encryption:** Each vault is encrypted with a KMS key (AWS-managed or customer-managed). Recovery points inherit the vault's encryption.
*   **Vault Lock:** Enforces WORM protection on a vault. Supports a *grace period* (1–7 days) during which the lock can be removed; after that it is permanent.
*   **IAM Roles:** AWS Backup uses a service role to take snapshots on your behalf. The role needs permissions on the source resource (e.g., `ec2:CreateSnapshot`, `rds:CreateDBSnapshot`).
*   **Resource-Based Vault Policies:** Control which principals can access, create, or delete recovery points in a vault, similar to S3 bucket policies.
*   **AWS Organizations Integration:** Apply backup policies across an entire organization using [Service Control Policies (SCPs)](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html) and **backup policies** at the org, OU, or account level.

---

## Pricing

*   **Warm storage:** Charged per GB-month of recovery points stored in a vault.
*   **Cold storage:** Lower per-GB rate; available for EFS, EBS, and S3 backups. Minimum 90-day retention applies.
*   **Restore:** No charge for restoring data; you pay only for the new resource provisioned (e.g., EBS volume, RDS instance).
*   **Cross-region copy:** Standard data transfer rates apply between regions.
*   **Audit Manager:** Charged per framework assessment per month.

See [AWS Backup Pricing](https://aws.amazon.com/backup/pricing/) for current rates by resource type and region.

---

## Real-Life Use Cases

*   **Compliance / Regulatory:** A financial services company must retain database backups for 7 years. Vault Lock enforces immutability so backups cannot be tampered with before the retention period expires.
*   **Multi-Account DR:** A SaaS provider automatically copies backups from a production account to an isolated DR account in a different region. If the production account is compromised, the DR account is unaffected.
*   **Tag-Based Protection:** A platform team tags every production resource with `Backup = true`. A backup plan automatically picks up new resources as they are created, with no manual intervention.
*   **VMware Migration Runway:** Before migrating VMs to EC2, an enterprise uses AWS Backup Gateway to start taking cloud backups of on-premises VMs, so the first cloud backup is already available on day 1 of migration.

---

## Related Services

*   [Amazon S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html) — object-level version history within S3
*   [AWS Elastic Disaster Recovery (DRS)](https://docs.aws.amazon.com/drs/latest/userguide/what-is-drs.html) — continuous replication for fast RTO/RPO
*   [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) — encryption key management for vaults
*   [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) — org-wide backup policy enforcement
*   [AWS Config](https://docs.aws.amazon.com/config/latest/developerguide/WhatIsConfig.html) — track backup compliance with managed config rules
