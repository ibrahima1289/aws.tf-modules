# AWS Snow Family

The [AWS Snow Family](https://aws.amazon.com/snow/) is a collection of physical edge computing and data transfer devices designed to move large amounts of data into and out of AWS in situations where network transfer is too slow, too costly, or simply not available. Each device in the family combines local compute capabilities with petabyte-scale offline data migration, making it practical to work with data at remote locations — factory floors, military bases, ships at sea, or disaster-recovery sites — before syncing it back to the AWS cloud.

## Core Concepts

*   **Offline Data Transfer:** Instead of sending data over the internet, AWS ships a ruggedised physical appliance to your location. You load data onto it, ship it back to AWS, and AWS ingests the data into [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) (or [Amazon Glacier](https://docs.aws.amazon.com/amazonglacier/latest/dev/introduction.html)).
*   **Edge Computing:** Every Snow device can run EC2-compatible instances and [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) functions locally, so you can process and filter data before it ever reaches the cloud.
*   **Chain of Custody:** AWS tracks the physical device throughout its journey. Data is automatically encrypted with 256-bit keys managed by [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html), and the encryption key never leaves AWS.
*   **No Network Required:** The devices operate fully air-gapped when needed — useful in government, defence, or remote industrial settings.

---

## The Snow Family Devices

### 1. AWS Snowcone

[AWS Snowcone](https://aws.amazon.com/snowcone/) is the smallest and most portable member of the family.

*   **Form Factor:** Weighs 4.5 lbs (≈ 2 kg); fits in a backpack. Designed for the harshest environments — dust, humidity, and extreme temperatures.
*   **Storage:** 8 TB HDD (Snowcone) or 14 TB SSD (Snowcone SSD).
*   **Compute:** 2 vCPUs, 4 GB RAM — enough to run lightweight EC2 instances (`sbe1.*` instance family) or [AWS IoT Greengrass](https://docs.aws.amazon.com/greengrass/v2/developerguide/what-is-iot-greengrass.html).
*   **Connectivity:** USB-C power; 2× 1/10 GbE RJ45 ports. Can also transfer data online via [AWS DataSync](https://docs.aws.amazon.com/datasync/latest/userguide/what-is-datasync.html) when a network is available.
*   **Real-Life Use Cases:**
    *   IoT sensor data collection on oil rigs or wind farms
    *   Content creation and field video collection in remote areas
    *   Tactical military edge deployments

---

### 2. AWS Snowball Edge

[AWS Snowball Edge](https://aws.amazon.com/snowball/) is the mid-range device, available in two configurations:

#### Snowball Edge Storage Optimized

*   **Storage:** 80 TB usable HDD + 1 TB SSD (for block storage volumes).
*   **Compute:** 40 vCPUs, 80 GB RAM.
*   **Best For:** Large-scale data migrations and local storage where compute needs are secondary.
*   **Real-Life Use Case:** Migrating a 500 TB on-premises data lake to Amazon S3 when the available WAN link would take months to transfer the data.

#### Snowball Edge Compute Optimized

*   **Storage:** 28 TB NVMe SSD (usable) + optional 1 TB SATA SSD.
*   **Compute:** 52 vCPUs, 208 GB RAM; optional NVIDIA V100 GPU.
*   **Best For:** Machine learning inference, video analysis, and high-performance edge computing where data is generated faster than it can be sent to the cloud.
*   **Real-Life Use Case:** Running a computer-vision model on a manufacturing assembly line to detect defects in real time, with results synced to AWS nightly.

**Shared Snowball Edge Features:**

*   Supports EC2-compatible instances (`sbe-c.*` and `sbe-g.*` families), [Amazon EBS](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEBS.html)-compatible block volumes, [Amazon S3-compatible object storage](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-adapter.html), and [NFS](https://docs.aws.amazon.com/snowball/latest/developer-guide/shared-nfs-overview.html).
*   Managed via [AWS OpsHub](https://docs.aws.amazon.com/snowball/latest/developer-guide/aws-opshub.html) (GUI) or the [Snowball Edge Client](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-client.html) (CLI).
*   Cluster mode: Up to 16 Snowball Edge devices can be clustered for increased durability and throughput.

---

### 3. AWS Snowmobile

[AWS Snowmobile](https://aws.amazon.com/snowmobile/) is an exabyte-scale migration service delivered in a 45-foot ruggedised shipping container pulled by a semi-trailer truck.

*   **Capacity:** Up to 100 PB per Snowmobile.
*   **Transfer Speed:** Up to 1 Tb/s via a high-speed network connection at your data centre.
*   **Security:** GPS tracking, alarm monitoring, 24/7 video surveillance, optional dedicated security personnel, and tamper-evident hardware.
*   **Real-Life Use Case:** A media company with 50+ PB of archived video content moves its entire digital library to [Amazon S3 Glacier](https://docs.aws.amazon.com/amazonglacier/latest/dev/introduction.html) in a matter of weeks rather than years over the network.
*   **Availability:** Ordered directly through AWS; not self-service. AWS sends a team to connect and operate the vehicle on-site.

---

## Key Components and Configuration

### 1. Jobs

A Snow Family deployment starts with creating a **job** in the [AWS Management Console](https://console.aws.amazon.com/snowfamily) or via the [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/snowball/index.html).

*   **Import Job:** Transfer data *into* AWS. You load data onto the device and ship it back; AWS imports it into S3.
*   **Export Job:** Transfer data *out of* AWS. AWS pre-loads data from S3 onto the device before shipping it to you.
*   **Local Compute and Storage Job** (Snowball Edge / Snowcone): Device is used exclusively for edge compute — no data import/export to AWS required.

### 2. Data Transfer Interfaces

| Interface | Devices | Description |
|-----------|---------|-------------|
| [S3-compatible API](https://docs.aws.amazon.com/snowball/latest/developer-guide/using-adapter.html) | All | Use standard S3 SDK/CLI commands locally on the device |
| [NFS Mount](https://docs.aws.amazon.com/snowball/latest/developer-guide/shared-nfs-overview.html) | Snowball Edge, Snowcone | Mount the device as a network file share |
| [AWS DataSync Agent](https://docs.aws.amazon.com/datasync/latest/userguide/what-is-datasync.html) | Snowcone | Online transfer when a network connection is available |
| Direct QSFP/SFP+ | Snowmobile | 1 Tb/s fibre connection at the data centre |

### 3. Edge Compute

Every Snowball Edge and Snowcone can run compute workloads locally using:

*   **EC2-compatible instances** — deploy AMIs from AWS or custom images. Instance families: `sbe1.*` (Snowcone), `sbe-c.*` (Compute Optimized), `sbe-g.*` (GPU).
*   **[AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)** — deploy Lambda functions that trigger on S3 PUT events on the device.
*   **[AWS IoT Greengrass](https://docs.aws.amazon.com/greengrass/v2/developerguide/what-is-iot-greengrass.html)** — synchronise IoT device software and data processing logic from the cloud.

### 4. Security

*   **Encryption at Rest:** All data is automatically encrypted with 256-bit AES keys. The device uses a [Trusted Platform Module (TPM)](https://docs.aws.amazon.com/snowball/latest/developer-guide/security.html) to keep keys protected.
*   **Key Management:** Encryption keys are managed by [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html); the plaintext key never leaves AWS. You must have KMS access to unlock the device.
*   **Tamper Evident:** Devices include an E Ink display that shows a tamper-evident shipping label and unlock code. If the device is physically tampered with, the keys are destroyed.
*   **Network Isolation:** Devices do not require internet access; they communicate only with your local network. AWS access is required only to create/complete jobs.
*   **IAM Policies:** Access to the Snowball job API and KMS keys is controlled by standard [AWS IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html) policies.

### 5. Lifecycle of a Snow Job

```
 ┌─────────────────────────────────────────────────────────────┐
 │ 1. Create Job (Console / CLI / SDK)                         │
 │    - Choose device type, S3 bucket, KMS key, SNS topic      │
 └──────────────────────────┬──────────────────────────────────┘
                            ↓
 ┌─────────────────────────────────────────────────────────────┐
 │ 2. AWS prepares and ships the device to your address        │
 └──────────────────────────┬──────────────────────────────────┘
                            ↓
 ┌─────────────────────────────────────────────────────────────┐
 │ 3. You receive the device and unlock it with a              │
 │    manifest + unlock code from the Console                  │
 └──────────────────────────┬──────────────────────────────────┘
                            ↓
 ┌─────────────────────────────────────────────────────────────┐
 │ 4. Transfer data using S3 adapter, NFS, or DataSync         │
 │    Run edge compute workloads (optional)                    │
 └──────────────────────────┬──────────────────────────────────┘
                            ↓
 ┌─────────────────────────────────────────────────────────────┐
 │ 5. Power off and ship the device back to AWS                │
 │    using the pre-paid return label on the E Ink display     │
 └──────────────────────────┬──────────────────────────────────┘
                            ↓
 ┌─────────────────────────────────────────────────────────────┐
 │ 6. AWS receives the device, verifies integrity,             │
 │    imports data into S3, and erases the device              │
 │    (NIST 800-88 standard)                                   │
 └──────────────────────────┬──────────────────────────────────┘
                            ↓
 ┌─────────────────────────────────────────────────────────────┐
 │ 7. Job completion notification via SNS                      │
 └─────────────────────────────────────────────────────────────┘
```

### 6. OpsHub — GUI Management

[AWS OpsHub](https://docs.aws.amazon.com/snowball/latest/developer-guide/aws-opshub.html) is a downloadable desktop application for managing Snow devices without using the CLI.

*   Unlock and configure devices
*   Launch and manage EC2 instances on the device
*   Monitor device metrics (storage usage, instance state, network)
*   Transfer files via a drag-and-drop interface

---

## Device Comparison

| Feature | Snowcone | Snowball Edge Storage Optimized | Snowball Edge Compute Optimized | Snowmobile |
|---------|----------|---------------------------------|----------------------------------|------------|
| **Storage** | 8 TB HDD / 14 TB SSD | 80 TB HDD + 1 TB SSD | 28 TB NVMe SSD | Up to 100 PB |
| **vCPUs** | 2 | 40 | 52 | N/A |
| **RAM** | 4 GB | 80 GB | 208 GB | N/A |
| **GPU** | No | No | Optional (V100) | N/A |
| **EC2 Instances** | `sbe1.*` | `sbe-c.*` | `sbe-c.*`, `sbe-g.*` | N/A |
| **NFS** | Yes | Yes | Yes | No |
| **DataSync** | Yes | No | No | No |
| **Clustering** | No | Up to 16 nodes | Up to 16 nodes | No |
| **Weight** | 4.5 lbs | 49.7 lbs | 49.7 lbs | 45-ft container |
| **Use Case** | Portable edge / small migration | Large migration | ML / video at the edge | Exabyte migration |

---

## Pricing

Snow Family pricing has two components:

*   **Service Fee:** A flat fee per job based on the device type and rental duration (typically 10 days free, then a daily fee for extended use).
*   **Data Transfer:** Transferring data *into* AWS via Snow is **free**. Transferring data *out of* AWS (export jobs) is charged at standard [S3 data transfer rates](https://aws.amazon.com/s3/pricing/).
*   **Compute:** EC2 instance-hours on Snowball Edge Compute Optimized are billed per hour at the applicable instance rate.

See the [AWS Snow Family Pricing](https://aws.amazon.com/snowball/pricing/) page for current fees by region and device type.

---

## Purpose and Real-Life Use Cases

*   **Large-Scale Data Migration:** Moving petabytes of on-premises data (backups, media archives, genomics datasets) to Amazon S3 when the available bandwidth would make a network transfer take months or years.
*   **Disconnected / Intermittent Connectivity:** Processing data at remote sites (mining operations, naval vessels, Antarctic research stations) where reliable internet is unavailable.
*   **Disaster Recovery Staging:** Pre-loading disaster-recovery data onto Snowball Edge devices stored at alternate sites, ready to be shipped back to AWS if the primary region is unavailable.
*   **Content Distribution:** Pre-loading Snowball Edge devices with software, media, or map data for distribution to remote field offices or deployed military units.
*   **Machine Learning at the Edge:** Running inference models locally on a Snowball Edge Compute Optimized device to make real-time decisions (quality control, anomaly detection) without cloud connectivity.
*   **HIPAA / Regulated Workloads:** Industries with strict data residency or air-gap requirements can process sensitive data locally on Snow devices without it ever traversing the public internet.

**When to choose Snow over Direct Connect / S3 Transfer Acceleration?**

*   **Choose Snow if:** You have more than ~10 TB to transfer, your available bandwidth is less than 1 Gbps, transfer time is constrained, or the environment is air-gapped.
*   **Choose [Direct Connect](https://aws.amazon.com/directconnect/) if:** You need ongoing, high-bandwidth connectivity between on-premises and AWS with consistent latency.
*   **Choose [S3 Transfer Acceleration](https://docs.aws.amazon.com/AmazonS3/latest/userguide/transfer-acceleration.html) if:** You have a fast internet connection and need to speed up S3 uploads from geographically distributed locations.

---

## Related AWS Services

*   [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html) — primary destination for Snow import jobs
*   [AWS DataSync](https://docs.aws.amazon.com/datasync/latest/userguide/what-is-datasync.html) — online alternative for smaller transfers; also used with Snowcone
*   [AWS Transfer Family](https://docs.aws.amazon.com/transfer/latest/userguide/what-is-aws-transfer-family.html) — SFTP/FTPS/FTP file transfer into S3 or EFS
*   [AWS Storage Gateway](https://docs.aws.amazon.com/storagegateway/latest/userguide/WhatIsStorageGateway.html) — hybrid cloud storage for ongoing on-premises integration
*   [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) — key management for device encryption
*   [AWS IoT Greengrass](https://docs.aws.amazon.com/greengrass/v2/developerguide/what-is-iot-greengrass.html) — IoT workload management on Snowcone / Snowball Edge
