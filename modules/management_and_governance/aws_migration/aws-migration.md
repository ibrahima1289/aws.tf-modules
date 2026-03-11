# AWS Migration Services

## Overview

AWS provides a comprehensive suite of migration services that help organizations move applications, servers, databases, and data to the AWS Cloud securely and efficiently. The two primary services for application and server migration are **AWS Application Migration Service (MGN)** and **AWS Server Migration Service (SMS)**.

---

## AWS Application Migration Service (AWS MGN)

AWS MGN is the **primary recommended service** for lift-and-shift (rehost) migrations. It simplifies and expedites the migration of physical servers, virtual machines, and cloud instances to AWS with minimal downtime.

### Key Features

| Feature | Description |
|---|---|
| **Continuous Replication** | Continuously replicates source servers to AWS staging area using block-level replication |
| **Minimal Cutover Window** | Reduces downtime to minutes during the final cutover |
| **Agent-Based** | Installs a lightweight AWS Replication Agent on source servers |
| **Multi-Platform** | Supports physical servers, VMware, Hyper-V, and other cloud providers |
| **Post-Launch Actions** | Automate post-migration tasks using built-in action templates |
| **Test & Cutover Launches** | Perform non-disruptive test launches before the final cutover |

### How It Works

```
Source Server                 AWS MGN                    AWS Target
─────────────           ─────────────────          ─────────────────
  App Server   ──────►  Replication Agent  ──────►  Staging Area
  DB Server    ──────►  (Block-level sync) ──────►  → Test Launch
  Web Server   ──────►  Continuous sync    ──────►  → Cutover Launch
```

1. **Install Agent** – Deploy the AWS Replication Agent on source servers
2. **Initial Sync** – Full disk replication to the AWS staging area
3. **Continuous Replication** – Ongoing delta replication keeps data in sync
4. **Test Launch** – Launch test instances to validate before cutover
5. **Cutover** – Perform the final cutover with minutes of downtime
6. **Decommission** – Shut down source servers after successful migration

### Supported Sources

- Physical servers (on-premises)
- VMware vSphere VMs
- Microsoft Hyper-V VMs
- AWS EC2 instances (cross-region / cross-account)
- Other cloud providers (Azure, GCP, etc.)

---

## AWS Server Migration Service (AWS SMS)

> ⚠️ **AWS SMS is deprecated.** AWS recommends using **AWS MGN** for all new server migration projects. AWS SMS reached end-of-support on **March 31, 2023**.

AWS SMS was an agentless service that orchestrated and automated the migration of on-premises VMware vSphere, Microsoft Hyper-V/SCVMM, and Azure VMs to AWS.

### Key Differences vs AWS MGN

| Feature | AWS SMS (Deprecated) | AWS MGN (Recommended) |
|---|---|---|
| Agent Required | No (agentless) | Yes (lightweight agent) |
| Replication Type | Snapshot-based (incremental) | Block-level (continuous) |
| Cutover Downtime | Higher | Minimal (minutes) |
| Status | **Deprecated** | **Actively supported** |

---

## The 6 R's of AWS Migration Strategy

The **6 R's** framework (originally the "5 R's" by Gartner, extended by AWS) provides a structured approach for determining how each workload should be migrated to the cloud. Each "R" represents a different migration strategy.

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AWS 6 R's Migration Strategies                   │
├─────────────┬───────────────────────────────────────────────────────┤
│ Rehost      │  Lift & Shift                                         │
│ Replatform  │  Lift, Tinker & Shift                                 │
│ Repurchase  │  Drop & Shop                                          │
│ Refactor    │  Re-architect                                         │
│ Retire      │  Decommission                                         │
│ Retain      │  Keep as-is                                           │
└─────────────┴───────────────────────────────────────────────────────┘
```

---

### 1. 🔁 Rehost — "Lift and Shift"

Move applications to AWS **without any code or architectural changes**.

- **Best for:** Large-scale migrations where speed matters, or when the team lacks cloud expertise
- **Tooling:** AWS MGN, AWS VM Import/Export
- **Outcome:** Same application running on EC2 instances in AWS
- **Benefit:** Fast migration, immediate cloud benefits (elasticity, HA)
- **Drawback:** Does not take full advantage of cloud-native features

**Example:** Moving a 200-server on-premises data centre to EC2 instances using AWS MGN.

---

### 2. 🔧 Replatform — "Lift, Tinker, and Shift"

Make **minor optimizations** to leverage cloud capabilities without changing the core architecture.

- **Best for:** Applications that can benefit from managed services with minimal effort
- **Tooling:** AWS MGN + RDS, Elastic Beanstalk, Amazon ECS
- **Outcome:** Application runs on optimized AWS-managed services
- **Benefit:** Reduced operational overhead with some cloud-native advantage
- **Drawback:** Requires some refactoring effort

**Example:** Migrating a self-managed MySQL database on-premises to **Amazon RDS for MySQL**, keeping the application code unchanged.

---

### 3. 🛒 Repurchase — "Drop and Shop"

**Replace** an existing application with a **SaaS (Software-as-a-Service)** product or a different product entirely.

- **Best for:** Legacy CRM, ERP, or HR systems with available SaaS alternatives
- **Tooling:** AWS Marketplace, third-party SaaS
- **Outcome:** Existing license/app is dropped in favour of a SaaS offering
- **Benefit:** Eliminates maintenance burden, modern feature sets
- **Drawback:** Data migration, user retraining, potential feature gaps

**Example:** Replacing a self-hosted Microsoft Exchange server with **Microsoft 365** or **Google Workspace**.

---

### 4. 🏗️ Refactor / Re-architect — "Re-architect"

**Reimagine and redesign** how an application is architected and developed using cloud-native features.

- **Best for:** Applications that need to scale dramatically or add new capabilities impossible in their current form
- **Tooling:** AWS Lambda, Amazon ECS/EKS, Amazon Aurora, API Gateway, SQS/SNS
- **Outcome:** Fully cloud-native, microservices or serverless architecture
- **Benefit:** Maximum scalability, resilience, and agility; optimized cloud costs
- **Drawback:** Highest effort, time, and cost; requires deep cloud expertise

**Example:** Breaking a monolithic e-commerce application into **serverless microservices** using AWS Lambda, API Gateway, and DynamoDB.

---

### 5. 🗑️ Retire — "Decommission"

**Identify and shut down** applications that are no longer needed.

- **Best for:** Redundant, obsolete, or unused applications discovered during migration assessment
- **Tooling:** AWS Migration Hub, AWS Application Discovery Service
- **Outcome:** Application is decommissioned; resources are freed
- **Benefit:** Reduces cost, complexity, and attack surface
- **Drawback:** Requires thorough audit to confirm no hidden dependencies

**Example:** During a migration assessment, discovering that 20% of servers host applications no longer used by the business — these are turned off.

---

### 6. 🔒 Retain — "Keep as-is" / Revisit

**Keep** certain applications on-premises or in their current environment, either temporarily or permanently.

- **Best for:** Applications that recently underwent major upgrades, have strict regulatory/compliance requirements, or are too risky to migrate now
- **Tooling:** AWS Outposts (for hybrid), AWS Direct Connect
- **Outcome:** Application stays on-premises; migration is deferred or skipped
- **Benefit:** Avoids unnecessary risk for stable, low-priority systems
- **Drawback:** Misses out on cloud benefits; continues to incur on-premises costs

**Example:** Retaining a heavily customized, business-critical mainframe application while migrating all other workloads to AWS.

---

## Choosing the Right Migration Strategy

```
         Low Effort                                  High Effort
            │                                             │
    ────────┼─────────────────────────────────────────────┼────────
    Retire  │  Retain  │  Rehost  │  Replatform  │  Refactor
    ────────┼─────────────────────────────────────────────┼────────
            │                                             │
         Low Value                                  High Value
```

| Strategy    | Cloud Benefit | Migration Effort | Risk  | Speed |
|-------------|--------------|-----------------|-------|-------|
| Rehost      | Low–Medium   | Low             | Low   | Fast  |
| Replatform  | Medium       | Medium          | Medium| Medium|
| Repurchase  | Medium–High  | Medium          | Medium| Medium|
| Refactor    | High         | High            | High  | Slow  |
| Retire      | High (cost)  | Very Low        | Low   | Fast  |
| Retain      | None         | None            | None  | N/A   |

---

## AWS Migration Hub

**AWS Migration Hub** provides a central location to track the progress of application migrations across multiple AWS and partner migration tools.

### Key Capabilities

- Centralized tracking dashboard for all migration activities
- Integrates with **AWS MGN**, **AWS DMS**, **AWS Application Discovery Service**
- Supports **Migration Hub Orchestrator** for automated workflow management
- Provides **Migration Hub Refactor Spaces** for incremental application refactoring

---

## AWS Application Discovery Service

Before migrating, use **AWS Application Discovery Service** to collect data about your on-premises environment.

| Discovery Method | Description |
|---|---|
| **Agentless Discovery** | VMware vCenter data collection via the Discovery Connector |
| **Agent-Based Discovery** | Detailed system/process data via the Discovery Agent installed on each server |

### Data Collected

- Server specifications (CPU, memory, disk, network)
- Running processes and network connections
- Performance utilisation metrics
- Application dependency mapping

---

## AWS Database Migration Service (AWS DMS)

For migrating databases alongside servers, **AWS DMS** enables continuous data replication with minimal downtime.

### Supported Migrations

| Source | Target |
|---|---|
| Oracle | Amazon Aurora |
| Microsoft SQL Server | Amazon RDS |
| MySQL / MariaDB | Amazon Redshift |
| PostgreSQL | Amazon DynamoDB |
| MongoDB | Amazon DocumentDB |
| SAP ASE | Amazon S3 (data lake) |

---

## Migration Best Practices

1. **Assess First** – Use AWS Application Discovery Service to map dependencies before migrating
2. **Start Small** – Begin with non-critical workloads to build team experience
3. **Test Thoroughly** – Leverage AWS MGN test launches before production cutover
4. **Automate** – Use Migration Hub Orchestrator and post-launch actions to reduce manual steps
5. **Optimize After Migration** – Right-size EC2 instances using AWS Compute Optimizer post-migration
6. **Security First** – Apply IAM least-privilege, enable AWS Security Hub, and encrypt data in transit and at rest
7. **Cost Management** – Use AWS Cost Explorer and AWS Trusted Advisor to monitor and optimize spend

---

## Reference Architecture

```
On-Premises                      AWS Cloud
──────────────────               ──────────────────────────────────
  Web Servers    ──────────────► EC2 (Auto Scaling Group)
  App Servers    ──── MGN ─────► EC2 in Private Subnet
  DB Servers     ──── DMS ─────► Amazon RDS / Aurora
  File Servers   ──────────────► Amazon S3 / EFS
  Legacy Apps    ──── Assess ──► Retire / Retain / Refactor
──────────────────               ──────────────────────────────────
        │                                      │
  Discovery Service ────────► Migration Hub (Central Tracking)
```

---

## Useful Links

- [AWS MGN Documentation](https://docs.aws.amazon.com/mgn/latest/ug/what-is-application-migration-service.html)
- [AWS Migration Hub](https://docs.aws.amazon.com/migrationhub/latest/ug/whatishub.html)
- [AWS Application Discovery Service](https://docs.aws.amazon.com/application-discovery/latest/userguide/what-is-appdiscovery.html)
- [AWS DMS Documentation](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html)
- [AWS 6 R's Migration Strategies](https://aws.amazon.com/blogs/enterprise-strategy/6-strategies-for-migrating-applications-to-the-cloud/)
