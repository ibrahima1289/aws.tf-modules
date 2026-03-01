# Amazon Relational Database Service (RDS)

## Overview

Amazon RDS (Relational Database Service) is a fully managed relational database service that makes it easy to set up, operate, and scale databases in the cloud. RDS supports multiple database engines including MySQL, PostgreSQL, MariaDB, Oracle Database, and Microsoft SQL Server.

## Key Features

### Multi-Engine Support
- **PostgreSQL**: Open-source, ACID-compliant, advanced features
- **MySQL**: Most popular open-source database
- **MariaDB**: MySQL-compatible with enhanced performance
- **Oracle Database**: Enterprise-grade commercial database (EE, SE2, SE1, SE)
- **Microsoft SQL Server**: Microsoft's relational database (Enterprise, Standard, Express, Web editions)
- **Amazon Aurora**: AWS-built MySQL and PostgreSQL compatible engine (see separate guide)

### Core Capabilities
- **Automated Backups**: Point-in-time recovery with 0-35 day retention
- **High Availability**: Multi-AZ deployments for automatic failover
- **Read Replicas**: Scale read-heavy workloads horizontally
- **Storage Autoscaling**: Automatically grow storage as needed
- **Encryption**: At-rest (KMS) and in-transit (SSL/TLS)
- **Performance Insights**: Database performance monitoring and tuning
- **Enhanced Monitoring**: Real-time operating system metrics
- **Automated Patching**: Automated minor version upgrades
- **Blue/Green Deployments**: Safe deployment strategy for updates

### Storage Types
- **General Purpose SSD (gp3)**: Cost-effective, baseline 3,000 IOPS, 125 MB/s throughput
- **General Purpose SSD (gp2)**: Previous generation, 3 IOPS per GB
- **Provisioned IOPS SSD (io1)**: High-performance, up to 64,000 IOPS
- **Provisioned IOPS SSD (io2)**: Higher durability than io1, same performance
- **Magnetic (standard)**: Legacy storage type (not recommended)

## Use Cases

### E-Commerce Applications
- High-traffic transactional workloads
- Multi-AZ for high availability
- Read replicas for product catalog queries
- Performance Insights for query optimization

### SaaS Applications
- Multi-tenant database architectures
- Automated backups for data protection
- Encryption for compliance requirements
- Cross-region read replicas for global reach

### Enterprise Applications
- Oracle/SQL Server migration to cloud
- Windows Authentication (Active Directory integration)
- License flexibility (BYOL or license-included)
- High-performance storage with Provisioned IOPS

### Analytics & Reporting
- Read replicas dedicated to reporting workloads
- PostgreSQL for advanced analytics features
- Separation of OLTP and OLAP workloads
- Export snapshots to S3 for data lake integration

### Development & Testing
- Cost-effective db.t3 instances
- Quick provisioning and deletion
- Snapshot restore for consistent test data
- Blue/green deployments for safe testing

## Architecture Patterns

### Multi-AZ Deployment (High Availability)
```
┌──────────────────────┐         ┌──────────────────────┐
│ Availability Zone A  │         │ Availability Zone B  │
│                      │         │                      │
│  ┌────────────────┐  │         │  ┌────────────────┐  │
│  │   Primary DB   │  │Sync Rep │  │   Standby DB   │  │
│  │  (Read/Write)  │◄-├─────────┤─►│  (Automatic    │  │
│  └────────────────┘  │         │  │   Failover)    │  │
│         │            │         │  └────────────────┘  │
│         ▼            │         │         │            │
│  ┌────────────────┐  │         │  ┌────────────────┐  │
│  │  EBS Storage   │  │         │  │  EBS Storage   │  │
│  └────────────────┘  │         │  └────────────────┘  │
└──────────────────────┘         └──────────────────────┘
```

### Read Replica Architecture
```
                     ┌─────────────────────────┐
                     │    Application Layer    │
                     └───────┬────────────┬────┘
                             │            │
                 Writes      │            │      Reads
                             ▼            ▼
             ┌──────────────────┐   ┌──────────────────┐
             │   Primary DB     │   │  Read Replica 1  │
             │   (Read/Write)   │──►│   (Read Only)    │
             └──────────────────┘   └──────────────────┘
                     │ Async          
                     │ Replication    ┌──────────────────┐
                     └───────────────►│  Read Replica 2  │
                                      │   (Read Only)    │
                                      └──────────────────┘
```

## Database Engines Comparison

| Feature | PostgreSQL | MySQL | MariaDB | Oracle | SQL Server |
|---------|-----------|-------|---------|--------|------------|
| **License** | Open Source | Open Source | Open Source | Commercial/BYOL | License Included |
| **Max Storage** | 64 TB | 64 TB | 64 TB | 64 TB | 16 TB |
| **Multi-AZ** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Read Replicas** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Encryption** | ✅ KMS | ✅ KMS | ✅ KMS | ✅ TDE/KMS | ✅ TDE/KMS |
| **IAM Auth** | ✅ Yes | ✅ Yes | ✅ Yes | ❌ No | ❌ No |
| **Min Instance** | db.t3.micro | db.t3.micro | db.t3.micro | db.t3.medium | db.t3.small |
| **CloudWatch Logs** | postgresql | error, general, slowquery, audit | error, general, slowquery, audit | alert, audit, trace, listener | error, agent |

## Best Practices

### Cost Optimization
1. **Right-size instances** - Use Performance Insights to identify over-provisioned instances
2. **Use gp3 storage** - Better price/performance than gp2
3. **Enable storage autoscaling** - Avoid over-provisioning storage
4. **Delete old snapshots** - Retain only necessary backups
5. **Use Reserved Instances** - For long-term production workloads
6. **Leverage Aurora** - For compatible workloads (can be more cost-effective at scale)

### High Availability
1. **Enable Multi-AZ** - For production databases
2. **Configure backup retention** - Minimum 7 days, 30 days for production
3. **Test failover procedures** - Regularly verify failover works as expected
4. **Use read replicas** - For disaster recovery in other regions

### Security
1. **Enable encryption at rest** - Use KMS for new databases
2. **Use SSL/TLS** - For data in transit
3. **Enable IAM authentication** - Instead of database passwords
4. **Use VPC** - Never expose RDS publicly in production
5. **Rotate credentials** - Use AWS Secrets Manager
6. **Enable deletion protection** - For production databases

### Performance
1. **Choose appropriate instance class** - Match workload characteristics
2. **Enable Performance Insights** - For query-level visibility
3. **Use parameter groups** - Tune database parameters for workload
4. **Monitor CloudWatch metrics** - CPU, IOPS, connections, replication lag
5. **Use read replicas** - Offload read-heavy workloads

## Resources

- **Official Documentation**: https://docs.aws.amazon.com/rds/
- **RDS Pricing**: https://aws.amazon.com/rds/pricing/
- **Best Practices**: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.html
- **Related Terraform Module**: [README.md](README.md)

---

**Last Updated**: February 2026  
**Service Category**: Database Services
