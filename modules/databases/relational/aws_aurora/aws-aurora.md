# AWS Aurora

Amazon Aurora is a MySQL and PostgreSQL-compatible relational database built for the cloud, combining the performance and availability of traditional enterprise databases with the simplicity and cost-effectiveness of open source databases.

## Overview

Aurora delivers up to 5x the performance of MySQL and 3x the performance of PostgreSQL with the security, availability, and reliability of commercial databases at 1/10th the cost. It provides built-in security, continuous backups, serverless compute, up to 15 read replicas, automated multi-Region replication, and integrations with other AWS services.

## Key Features

- **High Performance**: Up to 5x MySQL, 3x PostgreSQL throughput
- **Auto-Scaling Storage**: Automatically grows from 10 GB to 128 TB
- **High Availability**: 99.99% SLA with 6-way replication across 3 AZs
- **Up to 15 Read Replicas**: Low-latency read scaling
- **Serverless Options**: Serverless v1 (classic) and v2 (instant scaling)
- **Global Databases**: Multi-region replication with < 1 second lag
- **Backtrack**: Rewind database to any point in time (MySQL only)
- **Fast Clone**: Copy-on-write cloning in minutes
- **I/O-Optimized Storage**: Predictable pricing for high I/O workloads

## Architecture

Aurora uses a distributed, fault-tolerant, self-healing storage system that:
- Replicates data 6 times across 3 Availability Zones
- Continuously backs up data to Amazon S3
- Automatically detects and repairs disk failures
- Performs point-in-time recovery without database downtime

### Cluster Components

**Writer Instance**: Handles all write operations and reads (1 per cluster)
**Reader Instances**: Handle read-only queries (up to 15 per cluster)
**Cluster Volume**: Distributed storage layer shared by all instances

### Endpoints

- **Cluster Endpoint**: Always points to the writer instance
- **Reader Endpoint**: Load-balances across all reader instances
- **Custom Endpoints**: User-defined routing to specific instances
- **Instance Endpoints**: Direct connection to individual instances

## Deployment Modes

### 1. Provisioned Clusters
Traditional instance-based deployment with predictable performance.

**Use Cases**: Production workloads, consistent traffic, performance-critical apps
**Instance Types**: T3/T4g (burstable), R5/R6g/R6i (memory-optimized), X2g (high-memory)
**Pricing**: Hourly instance + storage ($0.10/GB) + I/O ($0.20 per 1M requests)

### 2. Serverless v2
Instantly scalable compute with fine-grained capacity control.

**Use Cases**: Variable workloads, dev/test, multi-tenant apps
**Capacity**: 0.5 to 128 ACUs in 0.5 ACU increments
**Scaling**: Scales up/down in seconds
**Pricing**: $0.12 per ACU-hour + storage + I/O

### 3. Serverless v1 (Classic)
Original serverless with automatic pause capability.

**Use Cases**: Infrequent workloads, development databases, serverless apps
**Capacity**: 2 to 256 capacity units
**Auto-Pause**: Pauses after configurable inactivity period
**Pricing**: $0.06 per capacity unit-hour (no I/O charges)
**Data API**: HTTP-based query interface

### 4. Global Database
Multi-region deployment for disaster recovery and low-latency global reads.

**Use Cases**: Global applications, disaster recovery, compliance
**Regions**: 1 primary + up to 5 secondary regions
**Replication Lag**: < 1 second
**Failover Time**: < 1 minute

### 5. I/O-Optimized
Storage type with unlimited I/O for predictable pricing.

**Use Cases**: High-throughput workloads, > 650M I/O requests/month
**Pricing**: ~40% higher instance cost, unlimited I/O included
**Break-even**: ~85 million I/O requests per month

## Engine Options

### Aurora MySQL
- **Versions**: MySQL 5.7, 8.0
- **Unique Features**:
  - Backtrack (rewind database up to 72 hours)
  - Parallel Query (accelerate analytics)
  - Clone from RDS MySQL

### Aurora PostgreSQL
- **Versions**: PostgreSQL 11, 12, 13, 14, 15
- **Unique Features**:
  - Babelfish (SQL Server compatibility)
  - Extensions (PostGIS, pgvector, etc.)
  - Logical replication to external databases

## Common Use Cases

### E-Commerce Platforms
- High transaction throughput
- Auto-scaling for traffic spikes
- Read replicas for product catalog queries

### SaaS Applications
- Multi-tenant architecture
- Variable workload with Serverless v2
- Database cloning for customer onboarding

### Global Applications
- Low-latency reads worldwide with Global Database
- Multi-region disaster recovery
- Data sovereignty compliance

### Analytics & Reporting
- Parallel Query for analytics on operational data
- Dedicated readers for reporting workloads
- Custom endpoints for workload isolation

## Pricing

**Provisioned Instances** (us-east-1):
- db.t3.medium: $0.082/hour (~$60/month)
- db.r6g.large: $0.29/hour (~$212/month)
- db.r6g.xlarge: $0.58/hour (~$423/month)

**Storage**: $0.10/GB-month (auto-scales to 128 TB)
**I/O**: $0.20 per 1 million requests
**Backup**: $0.021/GB-month (beyond retention period)

**Serverless**:
- Serverless v2: $0.12 per ACU-hour
- Serverless v1: $0.06 per ACU-hour (no I/O charges)

**I/O-Optimized**: ~40% higher instance cost, unlimited I/O

### Example Costs

**Production Cluster**: 1 writer + 2 readers (db.r6g.large) + 500GB + 100M I/O
- Instances: 3 × $211.70 = $635.10
- Storage: 500GB × $0.10 = $50.00
- I/O: 100M × $0.20/1M = $20.00
- **Total: $705.10/month**

**Serverless v2 Dev**: 1 writer, 0.5-2 ACUs, 50GB, 8hrs/day
- Compute: 8hrs × 30 days × 1 ACU × $0.12 = $28.80
- Storage: 50GB × $0.10 = $5.00
- **Total: ~$35/month**

## Aurora vs RDS

| Feature | Aurora | RDS |
|---------|--------|-----|
| Architecture | Cluster-based | Single instance |
| Storage Limit | 128 TB (auto-scale) | 64 TB (manual) |
| Replication | Up to 15 low-latency replicas | Up to 15 cross-region |
| Failover | < 30 seconds | 60-120 seconds |
| Performance | 5x MySQL, 3x PostgreSQL | Standard |
| Serverless | v1 and v2 | Not available |
| Backtrack | Yes (MySQL) | No |
| Global DB | Multi-region < 1s lag | Read replicas only |
| Engines | MySQL, PostgreSQL | All RDS engines |
| Starting Cost | ~$60/month | ~$50/month |

**Choose Aurora for**: High performance, auto-scaling storage, serverless, global databases, fast cloning
**Choose RDS for**: MariaDB/Oracle/SQL Server, lower baseline costs, simpler pricing

## Best Practices

### High Availability
- Deploy at least 2 instances across multiple AZs
- Set promotion tiers for controlled failover
- Use Global Database for cross-region DR
- Enable deletion protection for production

### Performance
- Use latest generation instances (R6g/R6i)
- Enable Performance Insights
- Create custom endpoints for workload routing
- Use read replicas to offload read traffic
- Consider Parallel Query for analytics (MySQL)

### Security
- Enable encryption at rest with KMS
- Use IAM authentication
- Deploy in private subnets only
- Rotate credentials with Secrets Manager
- Enable database activity streams

### Cost Optimization
- Use Serverless v2 for variable workloads
- Use I/O-Optimized for high I/O workloads (> 650M/month)
- Delete unused snapshots
- Use Reserved Instances for production
- Clone instead of snapshot restore for dev/test

## Resources

- [Aurora User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/)
- [Aurora Pricing](https://aws.amazon.com/rds/aurora/pricing/)
- [Aurora Serverless](https://aws.amazon.com/rds/aurora/serverless/)
- [Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.BestPractices.html)
- [Terraform RDS Cluster Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster)
