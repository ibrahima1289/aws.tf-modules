# Amazon Elastic File System (EFS)

## Comprehensive Overview

Amazon Elastic File System (EFS) is a fully managed, elastic, cloud-native Network File System (NFS) that provides simple, scalable file storage for use with AWS Cloud services and on-premises resources. Unlike traditional file systems that require capacity planning and manual scaling, EFS automatically grows and shrinks as you add and remove files, eliminating the need for provisioning and managing storage infrastructure.

EFS is designed to provide massively parallel shared access to thousands of Amazon EC2 instances and AWS Lambda functions, making it ideal for applications that require a shared file system. It offers the performance and consistency required for a broad range of workloads, from simple content repositories and development environments to sophisticated big data analytics and media processing applications.

Built on AWS's highly available and durable infrastructure, EFS automatically replicates your data across multiple Availability Zones within an AWS Region, protecting against component failure and ensuring high availability and durability. The service supports the NFSv4.1 and NFSv4.0 protocols, allowing easy integration with existing applications and tools that use standard file system semantics.

EFS integrates seamlessly with other AWS services including Amazon EC2, Amazon ECS, Amazon EKS, AWS Lambda, Amazon SageMaker, and AWS Backup, enabling you to build sophisticated cloud-native applications with minimal complexity. Whether you're running containerized applications, big data analytics, web serving, content management, or machine learning workloads, EFS provides the scalable, shared file storage foundation your applications need.

## Detailed Key Features

### 1. Elastic and Scalable Storage
- **Automatic Scaling:** Storage capacity grows and shrinks automatically as files are added or removed
- **Petabyte Scale:** Scale to petabytes of data without disrupting applications
- **No Capacity Planning:** Eliminate the need to provision storage in advance
- **Pay for What You Use:** Only pay for the storage you actually consume
- **Instant Elasticity:** New storage is immediately available when files are created
- **Seamless Scaling:** Applications experience no downtime during scaling events

### 2. High Performance and Throughput
- **General Purpose Performance Mode:** Low-latency file operations (default mode)
- **Max I/O Performance Mode:** Higher aggregate throughput and operations per second for large-scale applications
- **Bursting Throughput:** Default mode providing burst speeds up to 100 MiB/s per TiB of storage
- **Provisioned Throughput:** Configure specific throughput independent of storage size
- **Elastic Throughput:** Automatically scales throughput up and down based on workload demands (recommended)
- **Low Latency:** Single-digit millisecond read and write latencies

### 3. Highly Available and Durable
- **Multi-AZ Redundancy:** Data automatically replicated across multiple Availability Zones
- **Regional Storage:** Standard storage class for multi-AZ availability
- **One Zone Storage:** Option for single-AZ deployment at lower cost
- **99.999999999% Durability:** Eleven nines of durability for Standard storage class
- **99.99% Availability:** Four nines availability SLA
- **Automatic Replication:** No manual intervention required for data redundancy

### 4. Flexible Access and Connectivity
- **NFSv4.1 and NFSv4.0 Support:** Standard protocol compatibility
- **POSIX Compliance:** Full POSIX file system semantics
- **Concurrent Access:** Thousands of clients can access simultaneously
- **EC2 Integration:** Mount from any EC2 instance in your VPC
- **Container Integration:** Native support for ECS, EKS, and Fargate
- **Lambda Integration:** Access EFS from serverless functions
- **On-Premises Access:** Connect via AWS Direct Connect or VPN
- **Cross-Region Access:** Use VPC peering or Transit Gateway for multi-region access

### 5. Security and Compliance
- **Encryption at Rest:** AES-256 encryption using AWS KMS
- **Encryption in Transit:** TLS 1.2 encryption for data in motion
- **VPC Isolation:** File systems are isolated within your VPC
- **Security Groups:** Control network access using standard AWS security groups
- **IAM Integration:** Fine-grained access control using IAM policies
- **POSIX Permissions:** Standard Linux file and directory permissions
- **Access Points:** Application-specific entry points with enforced user identity
- **Compliance:** HIPAA, PCI-DSS, SOC, ISO, FedRAMP compliance

### 6. Lifecycle Management and Storage Classes
- **Standard Storage Class:** Frequently accessed files stored across multiple AZs
- **Infrequent Access (IA):** Lower-cost storage for files not accessed daily
- **Automatic Lifecycle Policies:** Move files to IA based on access patterns
- **Intelligent-Tiering:** EFS Intelligent-Tiering automatically optimizes costs
- **Archive Storage Class:** Lowest-cost storage for long-term archive (available since 2024)
- **One Zone Storage Classes:** IA and Standard options in single AZ for cost savings

### 7. Backup and Data Protection
- **AWS Backup Integration:** Automated backup policies and retention management
- **Point-in-Time Recovery:** Restore from any backup within retention period
- **Cross-Region Backup:** Replicate backups to different regions for disaster recovery
- **Incremental Backups:** Only changed blocks are backed up after the initial backup
- **Backup Compliance:** Enforce backup policies using AWS Organizations
- **Replication:** EFS Replication for automatic, continuous replication to another region

### 8. Management and Monitoring
- **AWS Management Console:** Web-based interface for easy management
- **AWS CLI and SDKs:** Programmatic access and automation
- **CloudWatch Integration:** Monitor file system metrics and set alarms
- **CloudTrail Logging:** Audit API calls for compliance and security
- **Tagging Support:** Organize and track costs using resource tags
- **Service Quotas:** Monitor and request increases for service limits

## Key Components and Configuration

### File System Configuration

**Performance Mode:**
- **General Purpose (Default):** Ideal for latency-sensitive workloads (web serving, CMS, home directories)
  - Latency: As low as 600 microseconds
  - Operations per second: Up to 35,000 per file system
- **Max I/O:** For applications requiring higher aggregate throughput (big data, media processing)
  - Higher latency: Low single-digit milliseconds
  - Operations per second: 500,000+
  - Trade-off: Slightly higher latencies for massively parallel operations

**Throughput Mode:**
- **Elastic (Recommended):** Automatically scales throughput based on workload
  - Read throughput: Up to 3 GiB/s
  - Write throughput: Up to 1 GiB/s
  - Best for: Unpredictable or spiky workloads
- **Bursting:** Scales with file system size
  - Base rate: 50 MiB/s per TiB of storage
  - Burst rate: 100 MiB/s per TiB (uses burst credits)
  - Best for: Throughput that scales with storage
- **Provisioned:** Fixed throughput independent of storage size
  - Range: 1 MiB/s to 1,024 MiB/s
  - Best for: Known, consistent throughput requirements

**Real-Life Example - Media Company:**
A video production company with 50 TiB of footage chooses:
- **Performance Mode:** Max I/O (hundreds of editors accessing simultaneously)
- **Throughput Mode:** Elastic (variable load - heavy during editing hours, light overnight)
- **Storage Class:** Standard (frequently accessed footage) + IA (archived projects)
- **Result:** Handles 200 concurrent editors with smooth performance, automatically scales for rendering jobs

### Storage Classes and Lifecycle Policies

**Available Storage Classes:**
1. **EFS Standard:** Multi-AZ, frequently accessed data
   - Price: ~$0.30/GB-month
2. **EFS Standard-IA:** Multi-AZ, infrequently accessed
   - Price: ~$0.025/GB-month (92% savings)
   - Access charge: $0.01 per GB read
3. **EFS One Zone:** Single AZ, frequently accessed
   - Price: ~$0.16/GB-month (47% savings vs Standard)
4. **EFS One Zone-IA:** Single AZ, infrequent access
   - Price: ~$0.0133/GB-month (96% savings vs Standard)
   - Best for: Non-critical, reproducible data

**Lifecycle Policy Configuration:**
```bash
aws efs put-lifecycle-configuration \
  --file-system-id fs-12345678 \
  --lifecycle-policies \
    "[{\"TransitionToIA\":\"AFTER_30_DAYS\"}, \
      {\"TransitionToPrimaryStorageClass\":\"AFTER_1_ACCESS\"}]"
```

**Real-Life Example - Software Company:**
A SaaS company stores customer uploads:
- Active projects: EFS Standard (3 TB)
- Projects inactive >30 days: Auto-transition to IA (47 TB)
- Accessed IA files: Auto-move back to Standard
- **Monthly Savings:** (47 TB × $0.275) = $12,925/month saved

### Access Points

Access Points provide application-specific entry points into an EFS file system.

**Configuration Parameters:**
- `Path`: Directory within the file system
- `PosixUser`: User ID and group ID to enforce
- `RootDirectory`: Creation info for root directory
- `Permissions`: POSIX permissions for the root directory

**Real-Life Example - Multi-Tenant Application:**
```bash
# Create access point for Tenant A
aws efs create-access-point \
  --file-system-id fs-12345678 \
  --posix-user Uid=1001,Gid=1001 \
  --root-directory "Path=/tenants/tenant-a,CreationInfo={OwnerUid=1001,OwnerGid=1001,Permissions=755}"

# Create access point for Tenant B
aws efs create-access-point \
  --file-system-id fs-12345678 \
  --posix-user Uid=1002,Gid=1002 \
  --root-directory "Path=/tenants/tenant-b,CreationInfo={OwnerUid=1002,OwnerGid=1002,Permissions=755}"
```

**Benefits:**
- Enforced directory isolation
- Simplified access management
- No need for complex mounting logic in applications
- Perfect for containerized multi-tenant applications

### Mount Targets

Mount targets are network endpoints through which EC2 instances access the file system.

**Configuration:**
- **Subnet:** One mount target per Availability Zone
- **Security Group:** Control network access
- **IP Address:** Automatically assigned or specify static

```bash
# Create mount target in each AZ
aws efs create-mount-target \
  --file-system-id fs-12345678 \
  --subnet-id subnet-abcd1234 \
  --security-groups sg-12345678

aws efs create-mount-target \
  --file-system-id fs-12345678 \
  --subnet-id subnet-efgh5678 \
  --security-groups sg-12345678
```

**Best Practice:** Create mount targets in all AZs where you have compute resources for optimal performance and availability.

## Advanced Configurations and Use Cases

### 1. Lambda Integration for Serverless Applications

**Use Case:** Process uploaded files with Lambda without managing servers.

```python
import os
import json

# Lambda function with EFS mount at /mnt/efs
def lambda_handler(event, context):
    efs_path = '/mnt/efs/uploads'
    
    # List files in EFS
    files = os.listdir(efs_path)
    
    # Process each file
    for filename in files:
        filepath = os.path.join(efs_path, filename)
        with open(filepath, 'r') as f:
            content = f.read()
            # Process content...
            
        # Move processed file
        processed_path = os.path.join('/mnt/efs/processed', filename)
        os.rename(filepath, processed_path)
    
    return {
        'statusCode': 200,
        'body': json.dumps(f'Processed {len(files)} files')
    }
```

**Configuration:**
```bash
# Attach EFS to Lambda function
aws lambda update-function-configuration \
  --function-name processUploads \
  --file-system-configs "[
    {
      \"Arn\": \"arn:aws:elasticfilesystem:us-east-1:123456789012:access-point/fsap-12345678\",
      \"LocalMountPath\": \"/mnt/efs\"
    }
  ]"
```

### 2. Container Persistent Storage (EKS/ECS)

**Kubernetes Persistent Volume Configuration:**

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: efs-sc
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-12345678::fsap-abcdefgh
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: efs-claim
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: efs-sc
  resources:
    requests:
      storage: 5Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 5
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        volumeMounts:
        - name: persistent-storage
          mountPath: /usr/share/nginx/html
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: efs-claim
```

**Benefits:**
- All pods share the same content
- Automatic scaling without storage concerns
- Persistent data survives pod restarts

### 3. Big Data and Analytics

**Scenario:** EMR cluster analyzing 100TB of log files.

```bash
# Mount EFS on EMR cluster nodes
sudo mount -t nfs4 -o nfsvers=4.1 \
  fs-12345678.efs.us-east-1.amazonaws.com:/ /mnt/efs

# Spark job reading from EFS
spark-submit \
  --master yarn \
  --deploy-mode cluster \
  --conf spark.executor.instances=50 \
  process_logs.py /mnt/efs/logs/
```

**Performance Optimization:**
- Use Max I/O performance mode
- Enable Elastic throughput
- Distribute data across multiple directories
- Use parallel processing to maximize throughput

### 4. Hybrid Cloud File Sharing

**Connect On-Premises to EFS:**

```bash
# On-premises server configuration
# Requires AWS Direct Connect or VPN

# Install NFS client
sudo yum install -y nfs-utils

# Mount EFS
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 \
  10.0.1.50:/ /mnt/aws-efs

# Add to /etc/fstab for persistence
echo "10.0.1.50:/ /mnt/aws-efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" | \
  sudo tee -a /etc/fstab
```

**Use Cases:**
- Gradual cloud migration
- Hybrid backup solutions
- Disaster recovery
- Distributed team collaboration

### 5. Machine Learning Training Data

**SageMaker Integration:**

```python
import sagemaker
from sagemaker.pytorch import PyTorch

# Define EFS file system configuration
file_system_id = 'fs-12345678'
file_system_type = 'EFS'
file_system_access_mode = 'ro'  # Read-only
file_system_directory_path = '/training-data'

# Create SageMaker estimator with EFS
estimator = PyTorch(
    entry_point='train.py',
    role=role,
    framework_version='1.9.0',
    py_version='py38',
    instance_count=4,
    instance_type='ml.p3.8xlarge',
    subnets=['subnet-12345678'],
    security_group_ids=['sg-12345678'],
    input_mode='File',
    # Attach EFS
    file_system_id=file_system_id,
    file_system_type=file_system_type,
    file_system_access_mode=file_system_access_mode,
    file_system_directory_path=file_system_directory_path
)

estimator.fit()
```

**Benefits:**
- No need to copy large datasets to S3
- Multiple training jobs access same data
- Faster training iteration
- Cost savings on data transfer

## Security Best Practices

### 1. Enable Encryption

**Encryption at Rest:**
```bash
# Create encrypted file system
aws efs create-file-system \
  --encrypted \
  --kms-key-id arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012 \
  --performance-mode generalPurpose \
  --throughput-mode elastic \
  --tags Key=Name,Value=encrypted-efs
```

**Encryption in Transit:**
```bash
# Mount with TLS encryption
sudo mount -t efs -o tls fs-12345678:/ /mnt/efs
```

### 2. Network Security

**Security Group Configuration:**
```bash
# Create security group for EFS
aws ec2 create-security-group \
  --group-name efs-sg \
  --description "Security group for EFS mount targets" \
  --vpc-id vpc-12345678

# Allow NFS traffic from application security group
aws ec2 authorize-security-group-ingress \
  --group-id sg-efs123456 \
  --protocol tcp \
  --port 2049 \
  --source-group sg-app123456

# For encrypted transit, also allow port 2999
aws ec2 authorize-security-group-ingress \
  --group-id sg-efs123456 \
  --protocol tcp \
  --port 2999 \
  --source-group sg-app123456
```

### 3. IAM Access Control

**File System Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EnforceEncryptionInTransit",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "AllowReadWriteAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/EFS-App-Role"
      },
      "Action": [
        "elasticfilesystem:ClientMount",
        "elasticfilesystem:ClientWrite"
      ],
      "Resource": "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678"
    },
    {
      "Sid": "AllowReadOnlyAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/EFS-ReadOnly-Role"
      },
      "Action": "elasticfilesystem:ClientMount",
      "Resource": "arn:aws:elasticfilesystem:us-east-1:123456789012:file-system/fs-12345678",
      "Condition": {
        "Bool": {
          "elasticfilesystem:AccessedViaMountTarget": "true"
        }
      }
    }
  ]
}
```

### 4. Access Points for Application Isolation

**Create Isolated Access Points:**
```bash
# Production application access point
aws efs create-access-point \
  --file-system-id fs-12345678 \
  --posix-user Uid=1000,Gid=1000 \
  --root-directory "Path=/apps/production,CreationInfo={OwnerUid=1000,OwnerGid=1000,Permissions=755}" \
  --tags Key=Environment,Value=Production

# Development application access point
aws efs create-access-point \
  --file-system-id fs-12345678 \
  --posix-user Uid=2000,Gid=2000 \
  --root-directory "Path=/apps/development,CreationInfo={OwnerUid=2000,OwnerGid=2000,Permissions=755}" \
  --tags Key=Environment,Value=Development
```

### 5. Regular Security Audits

**CloudTrail Monitoring:**
```bash
# Query CloudTrail for EFS API calls
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::EFS::FileSystem \
  --max-results 50
```

**CloudWatch Alarms for Unusual Activity:**
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name efs-unusual-client-connections \
  --alarm-description "Alert on unusual number of client connections" \
  --metric-name ClientConnections \
  --namespace AWS/EFS \
  --statistic Sum \
  --period 300 \
  --evaluation-periods 2 \
  --threshold 1000 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=FileSystemId,Value=fs-12345678
```

## Monitoring and Troubleshooting

### CloudWatch Metrics

**Key Metrics to Monitor:**

1. **BurstCreditBalance:** Available burst credits (Bursting mode only)
2. **ClientConnections:** Number of client connections
3. **DataReadIOBytes:** Bytes read per period
4. **DataWriteIOBytes:** Bytes written per period
5. **MetadataIOBytes:** Metadata operation bytes
6. **PercentIOLimit:** How close to I/O limit (Max I/O mode)
7. **PermittedThroughput:** Maximum throughput allowed
8. **TotalIOBytes:** Total bytes for all operations
9. **StorageBytes:** Size of file system (by storage class)

**Create Comprehensive Dashboard:**
```bash
aws cloudwatch put-dashboard \
  --dashboard-name EFS-Monitoring \
  --dashboard-body file://efs-dashboard.json
```

**efs-dashboard.json:**
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EFS", "ClientConnections", {"stat": "Sum"}],
          [".", "DataReadIOBytes", {"stat": "Sum"}],
          [".", "DataWriteIOBytes", {"stat": "Sum"}]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "EFS Activity",
        "yAxis": {"left": {"label": "Bytes"}}
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EFS", "BurstCreditBalance"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Burst Credit Balance"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/EFS", "StorageBytes", {"stat": "Average", "label": "Standard"}],
          ["...", {"stat": "Average", "label": "IA"}]
        ],
        "period": 3600,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Storage by Class"
      }
    }
  ]
}
```

### Performance Troubleshooting

**Problem: Slow Performance**

**Diagnosis:**
```bash
# Check current throughput
aws cloudwatch get-metric-statistics \
  --namespace AWS/EFS \
  --metric-name PermittedThroughput \
  --dimensions Name=FileSystemId,Value=fs-12345678 \
  --start-time 2026-02-22T00:00:00Z \
  --end-time 2026-02-22T23:59:59Z \
  --period 3600 \
  --statistics Average

# Check if hitting I/O limits (Max I/O mode)
aws cloudwatch get-metric-statistics \
  --namespace AWS/EFS \
  --metric-name PercentIOLimit \
  --dimensions Name=FileSystemId,Value=fs-12345678 \
  --start-time 2026-02-22T00:00:00Z \
  --end-time 2026-02-22T23:59:59Z \
  --period 300 \
  --statistics Maximum
```

**Solutions:**
- Switch to Elastic throughput mode
- Use Provisioned throughput for consistent performance
- Consider Max I/O performance mode for parallel workloads
- Optimize application I/O patterns
- Increase file system size (for Bursting mode)

**Problem: Mounting Failures**

**Common Causes and Solutions:**

1. **Security Group Issues:**
```bash
# Verify security group allows NFS
aws ec2 describe-security-groups \
  --group-ids sg-12345678 \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`2049`]'
```

2. **DNS Resolution:**
```bash
# Test DNS resolution
nslookup fs-12345678.efs.us-east-1.amazonaws.com

# Use mount target IP if DNS fails
sudo mount -t nfs4 10.0.1.50:/ /mnt/efs
```

3. **NFS Client Not Installed:**
```bash
# Amazon Linux 2
sudo yum install -y amazon-efs-utils

# Ubuntu
sudo apt-get install -y nfs-common
```

4. **Incorrect Mount Options:**
```bash
# Recommended mount options
sudo mount -t efs -o tls,iam fs-12345678:/ /mnt/efs

# Alternative with specific options
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
  fs-12345678.efs.us-east-1.amazonaws.com:/ /mnt/efs
```

### Logging and Auditing

**Enable Access Logging:**
While EFS doesn't have native access logs, you can use VPC Flow Logs:

```bash
aws ec2 create-flow-logs \
  --resource-type NetworkInterface \
  --resource-ids eni-12345678 \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /aws/efs/flowlogs \
  --deliver-logs-permission-arn arn:aws:iam::123456789012:role/flowlogsRole
```

**CloudTrail for API Auditing:**
```bash
# Query recent EFS API calls
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceType,AttributeValue=AWS::EFS::FileSystem \
  --start-time 2026-02-20T00:00:00Z \
  --max-results 100
```

## Cost Optimization

### Pricing Overview

**Standard Storage:**
- EFS Standard: $0.30/GB-month
- EFS One Zone: $0.16/GB-month

**Infrequent Access:**
- EFS Standard-IA: $0.025/GB-month
- EFS One Zone-IA: $0.0133/GB-month
- IA Access fee: $0.01/GB read

**Throughput:**
- Elastic/Bursting: Included
- Provisioned: $6.00/MB/s-month

**Requests:**
- Elastic mode: Included
- Bursting: Included

### Cost Optimization Strategies

**1. Implement Lifecycle Management**

```bash
# Aggressive cost savings - move to IA after 7 days
aws efs put-lifecycle-configuration \
  --file-system-id fs-12345678 \
  --lifecycle-policies \
    "[{\"TransitionToIA\":\"AFTER_7_DAYS\"}]"

# Balanced approach - 30 days
aws efs put-lifecycle-configuration \
  --file-system-id fs-12345678 \
  --lifecycle-policies \
    "[{\"TransitionToIA\":\"AFTER_30_DAYS\"}]"

# Conservative - 90 days
aws efs put-lifecycle-configuration \
  --file-system-id fs-12345678 \
  --lifecycle-policies \
    "[{\"TransitionToIA\":\"AFTER_90_DAYS\"}]"
```

**Potential Savings Example:**
- 100 TB file system
- 20 TB accessed frequently (Standard)
- 80 TB accessed rarely (IA after 30 days)

```
Without Lifecycle Management:
100 TB × $0.30/GB = $30,000/month

With Lifecycle Management:
(20 TB × $0.30/GB) + (80 TB × $0.025/GB) = $6,000 + $2,000 = $8,000/month

Savings: $22,000/month (73% reduction)
```

**2. Choose Right Storage Class**

**Use One Zone for:**
- Development/test environments
- Data that can be easily recreated
- Non-critical workloads
- Cost-sensitive applications

**Savings:** 47% vs Standard, 96% vs Standard for IA

**3. Optimize Throughput Mode**

```bash
# Switch to Elastic for variable workloads (no additional cost)
aws efs update-file-system \
  --file-system-id fs-12345678 \
  --throughput-mode elastic

# Use Bursting if throughput scales with storage
# Only use Provisioned if you need consistent high throughput
# with small file system size
```

**Cost Comparison:**
- 1 TB file system needing 100 MB/s throughput
- Bursting: 50 MB/s baseline (insufficient)
- Provisioned: $600/month additional cost
- Elastic: Automatically provides 100 MB/s when needed, included

**4. Implement Data Retention Policies**

```bash
# Automated cleanup script
#!/bin/bash

EFS_MOUNT="/mnt/efs"
RETENTION_DAYS=365

# Delete files older than retention period
find "${EFS_MOUNT}/logs" -type f -mtime +${RETENTION_DAYS} -delete
find "${EFS_MOUNT}/temp" -type f -mtime +7 -delete
find "${EFS_MOUNT}/cache" -type f -mtime +1 -delete

echo "Cleanup completed: $(date)"
```

**5. Monitor and Optimize Access Patterns**

```bash
# Identify files in IA being frequently accessed
aws cloudwatch get-metric-statistics \
  --namespace AWS/EFS \
  --metric-name StorageBytes \
  --dimensions Name=FileSystemId,Value=fs-12345678 Name=StorageClass,Value=InfrequentAccess \
  --start-time 2026-02-01T00:00:00Z \
  --end-time 2026-02-28T23:59:59Z \
  --period 86400 \
  --statistics Average

# If IA access fees exceed Standard storage costs, adjust lifecycle policy
```

### Cost Calculation Examples

**Example 1: Web Application**
- Storage: 5 TB (all frequently accessed)
- Throughput: Elastic (included)
- Storage Class: EFS Standard

```
Monthly Cost:
5,000 GB × $0.30 = $1,500/month
```

**Example 2: Media Archive with Lifecycle**
- Storage: 50 TB total
  - 5 TB active (Standard)
  - 45 TB archive (IA)
- Throughput: Elastic
- Monthly IA reads: 1 TB

```
Monthly Cost:
Standard: 5,000 GB × $0.30 = $1,500
IA Storage: 45,000 GB × $0.025 = $1,125
IA Access: 1,000 GB × $0.01 = $10
Total: $2,635/month

Vs All Standard: 50,000 GB × $0.30 = $15,000/month
Savings: $12,365/month (82%)
```

**Example 3: Development Environment**
- Storage: 2 TB
- Storage Class: One Zone
- Throughput: Bursting

```
Monthly Cost:
2,000 GB × $0.16 = $320/month

Vs Standard: 2,000 GB × $0.30 = $600/month
Savings: $280/month (47%)
```

## Limits and Quotas

### Default Service Limits

**File System Limits:**
- File systems per account per region: 1,000
- Total throughput per file system: Up to 10 GB/s (aggregate)
- Read throughput: Up to 3 GB/s per file system (Elastic mode)
- Write throughput: Up to 1 GB/s per file system (Elastic mode)
- Maximum file size: 47.9 TiB per file
- Maximum directory depth: 1,000 levels
- Maximum file system size: Unlimited (petabyte-scale)

**Mount Target Limits:**
- Mount targets per VPC: Equal to number of Availability Zones
- Mount targets per file system: Limited by number of AZs in region

**Access Point Limits:**
- Access points per file system: 1,000

**Performance Limits (General Purpose):**
- Baseline throughput: 50 MiB/s per TiB stored
- Burst throughput: 100 MiB/s per TiB stored
- Operations per second: 35,000 per file system

**Performance Limits (Max I/O):**
- Operations per second: 500,000+ per file system
- Throughput: Same as General Purpose

### Request Quota Increases

```bash
# Request increase via Service Quotas
aws service-quotas request-service-quota-increase \
  --service-code elasticfilesystem \
  --quota-code L-848C634D \
  --desired-value 2000

# Check request status
aws service-quotas list-requested-service-quota-change-history-by-quota \
  --service-code elasticfilesystem \
  --quota-code L-848C634D
```

### Best Practices for Limits

1. **Monitor Current Usage:**
```bash
# Check number of file systems
aws efs describe-file-systems --query 'length(FileSystems)'

# Check access points per file system
aws efs describe-access-points \
  --file-system-id fs-12345678 \
  --query 'length(AccessPoints)'
```

2. **Plan for Growth:**
- Request quota increases proactively
- Design applications to work within limits
- Consider multiple file systems for very large deployments

3. **Optimize Operations:**
- Batch small file operations
- Use appropriate caching
- Avoid excessive metadata operations

## Multiple Real-Life Example Applications

### Example 1: High-Traffic WordPress Hosting Platform

**Scenario:** Hosting company managing 500 WordPress sites with varying traffic levels.

**Architecture:**
- Application Load Balancer
- Auto Scaling group (5-50 EC2 instances)
- RDS MySQL for databases
- EFS for shared WordPress files
- CloudFront for static content delivery

**EFS Configuration:**
```bash
# Create file system
aws efs create-file-system \
  --encrypted \
  --performance-mode generalPurpose \
  --throughput-mode elastic \
  --lifecycle-policies "[{\"TransitionToIA\":\"AFTER_30_DAYS\"}]" \
  --tags Key=Name,Value=wordpress-shared-storage

# Create mount targets in each AZ
for subnet in subnet-abc123 subnet-def456 subnet-ghi789; do
  aws efs create-mount-target \
    --file-system-id fs-12345678 \
    --subnet-id $subnet \
    --security-groups sg-efs123456
done

# Mount on each web server
sudo mount -t efs -o tls fs-12345678:/ /var/www/html/wp-content/uploads
```

**User Data Script:**
```bash
#!/bin/bash
yum install -y amazon-efs-utils
mkdir -p /var/www/html/wp-content/uploads
mount -t efs -o tls fs-12345678:/ /var/www/html/wp-content/uploads
echo "fs-12345678:/ /var/www/html/wp-content/uploads efs _netdev,tls 0 0" >> /etc/fstab
```

**Results:**
- Seamless auto-scaling from 5 to 50 instances during traffic spikes
- Zero file synchronization issues
- 70% cost reduction using IA for old uploads
- 99.99% uptime achieved

### Example 2: Genomics Research Pipeline

**Scenario:** Biotech company processing genomic sequences with compute clusters.

**Workflow:**
1. Upload raw sequencing data (100GB-1TB per sample)
2. Parallel processing on 100-node cluster
3. Analysis and variant calling
4. Long-term storage of results

**EFS Configuration:**
- Performance Mode: Max I/O
- Throughput Mode: Elastic
- Storage Classes: Standard (active) + IA (archive)
- Encryption: Enabled with customer-managed KMS key

**Batch Job Configuration:**
```python
import boto3
import os

def process_sample(sample_id):
    efs_input = f"/mnt/efs/raw-data/{sample_id}"
    efs_output = f"/mnt/efs/results/{sample_id}"
    
    # Processing happens here
    # All nodes read from shared EFS input
    # Write results to shared EFS output
    
    os.system(f"bwa mem -t 16 reference.fa {efs_input}/reads.fq > {efs_output}/aligned.sam")
    os.system(f"samtools sort {efs_output}/aligned.sam -o {efs_output}/sorted.bam")
    os.system(f"gatk HaplotypeCaller -I {efs_output}/sorted.bam -O {efs_output}/variants.vcf")

# AWS Batch automatically mounts EFS on all compute nodes
```

**Benefits:**
- Process 500+ samples concurrently
- No data transfer delays between steps
- Automatic archival of old results to IA (98% cost savings)
- Researchers access results via mounted EFS
- Total cost: $4,000/month vs $45,000 for all Standard storage

### Example 3: Video Rendering Farm

**Scenario:** Post-production studio rendering animations and visual effects.

**Architecture:**
- Source assets on EFS (textures, models, scenes)
- Render farm: 200 EC2 Spot instances
- Final outputs: Moved to S3 for distribution

**EFS Configuration:**
```bash
# High-performance file system
aws efs create-file-system \
  --encrypted \
  --performance-mode maxIO \
  --throughput-mode elastic \
  --tags Key=Project,Value=rendering-farm

# Create access point for each project
aws efs create-access-point \
  --file-system-id fs-12345678 \
  --posix-user Uid=1500,Gid=1500 \
  --root-directory "Path=/projects/movie-a,CreationInfo={OwnerUid=1500,OwnerGid=1500,Permissions=755}"
```

**Render Node Setup:**
```bash
#!/bin/bash
# Install EFS utils and mount
yum install -y amazon-efs-utils
mkdir /mnt/render-assets
mount -t efs -o tls,accesspoint=fsap-project-a fs-12345678:/ /mnt/render-assets

# Start render worker
cd /opt/blender
./blender -b /mnt/render-assets/scenes/scene.blend -o /mnt/render-assets/output/ -f $FRAME_NUMBER
```

**Cost Optimization:**
- Active projects: EFS Standard (5TB) = $1,500/month
- Archived projects: Lifecycle to IA (50TB) = $1,250/month
- Total: $2,750/month
- Spot instances save 70% on compute
- Overall 85% cost reduction vs on-premises render farm

### Example 4: Machine Learning Training Data Lake

**Scenario:** AI startup training models with 200TB of image data.

**Architecture:**
- EFS for training datasets
- SageMaker training jobs (10-100 instances)
- Jupyter notebooks for data exploration
- Continuous data augmentation pipeline

**Implementation:**
```python
import sagemaker
from sagemaker.tensorflow import TensorFlow

# Configure EFS for SageMaker
file_system_id = 'fs-12345678'
file_system_directory_path = '/training-data/imagenet'
file_system_access_mode = 'ro'
file_system_type = 'EFS'

# Create estimator
estimator = TensorFlow(
    entry_point='train.py',
    role=sagemaker_role,
    instance_count=20,
    instance_type='ml.p3.16xlarge',
    framework_version='2.9',
    py_version='py39',
    # EFS configuration
    subnets=['subnet-abc123', 'subnet-def456'],
    security_group_ids=['sg-ml123456'],
    file_system_id=file_system_id,
    file_system_type=file_system_type,
    file_system_access_mode=file_system_access_mode,
    file_system_directory_path=file_system_directory_path,
    hyperparameters={
        'epochs': 100,
        'batch-size': 256
    }
)

estimator.fit()
```

**Benefits:**
- No need to copy 200TB to S3 before each training job
- Multiple teams train simultaneously on same data
- Data augmentation updates available to all jobs immediately
- Cost savings: Eliminated $4,000/month in S3 transfer fees

### Example 5: Global Content Collaboration Platform

**Scenario:** International marketing agency with teams across 5 continents.

**Architecture:**
- Primary EFS in us-east-1
- Secondary EFS in eu-west-1 (using EFS Replication)
- Tertiary EFS in ap-southeast-1
- AWS Direct Connect from offices
- VPN for remote workers

**EFS Replication Setup:**
```bash
# Enable replication to Europe
aws efs create-replication-configuration \
  --source-file-system-id fs-12345678 \
  --destinations "[
    {
      \"Region\": \"eu-west-1\",
      \"FileSystemId\": \"fs-87654321\"
    }
  ]"

# Monitor replication
aws efs describe-replication-configurations \
  --file-system-id fs-12345678
```

**Access Configuration:**
```bash
# US Office
sudo mount -t efs -o tls fs-12345678:/ /mnt/shared

# EU Office (uses local replica)
sudo mount -t efs -o tls fs-87654321:/ /mnt/shared

# Asia Office (uses local replica)
sudo mount -t efs -o tls fs-abcdefgh:/ /mnt/shared
```

**Results:**
- 10x faster file access for international teams
- Automatic failover for disaster recovery
- Unified namespace for all users
- Real-time collaboration on large media files
- 60% reduction in file versioning conflicts

### Example 6: IoT Data Processing Platform

**Scenario:** Smart city processing sensor data from 100,000 devices.

**Data Flow:**
1. Devices send data to IoT Core
2. Lambda functions process and write to EFS
3. Batch jobs analyze historical data
4. Results served via API

**Lambda Function:**
```python
import json
import os
from datetime import datetime

def lambda_handler(event, context):
    # EFS mounted at /mnt/efs
    efs_path = '/mnt/efs/iot-data'
    
    for record in event['Records']:
        payload = json.loads(record['body'])
        device_id = payload['deviceId']
        timestamp = datetime.now().strftime('%Y-%m-%d')
        
        # Write data to EFS
        data_file = f"{efs_path}/{device_id}/{timestamp}.json"
        os.makedirs(os.path.dirname(data_file), exist_ok=True)
        
        with open(data_file, 'a') as f:
            f.write(json.dumps(payload) + '\n')
    
    return {'statusCode': 200}
```

**Benefits:**
- 10,000 concurrent Lambda functions writing to EFS
- No database bottlenecks
- Easy batch processing with EMR
- Cost: $2,000/month vs $15,000 for database storage

## Terraform Example

### Complete EFS Infrastructure

```hcl
# main.tf

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# KMS Key for encryption
resource "aws_kms_key" "efs" {
  description             = "KMS key for EFS encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-efs-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "efs" {
  name          = "alias/${var.project_name}-efs"
  target_key_id = aws_kms_key.efs.key_id
}

# EFS File System
resource "aws_efs_file_system" "main" {
  creation_token = "${var.project_name}-efs"
  encrypted      = true
  kms_key_id     = aws_kms_key.efs.arn

  performance_mode                = var.performance_mode
  throughput_mode                 = var.throughput_mode
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput : null

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = {
    Name        = "${var.project_name}-efs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Security Group for EFS
resource "aws_security_group" "efs" {
  name        = "${var.project_name}-efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from application servers"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  ingress {
    description     = "NFS over TLS"
    from_port       = 2999
    to_port         = 2999
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-efs-sg"
  }
}

# Mount Targets (one per AZ)
resource "aws_efs_mount_target" "main" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs.id]
}

# EFS Access Points
resource "aws_efs_access_point" "app" {
  file_system_id = aws_efs_file_system.main.id

  root_directory {
    path = "/applications"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  posix_user {
    gid = 1000
    uid = 1000
  }

  tags = {
    Name        = "${var.project_name}-app-access-point"
    Environment = var.environment
  }
}

resource "aws_efs_access_point" "data" {
  file_system_id = aws_efs_file_system.main.id

  root_directory {
    path = "/data"
    creation_info {
      owner_gid   = 2000
      owner_uid   = 2000
      permissions = "750"
    }
  }

  posix_user {
    gid = 2000
    uid = 2000
  }

  tags = {
    Name        = "${var.project_name}-data-access-point"
    Environment = var.environment
  }
}

# File System Policy
resource "aws_efs_file_system_policy" "main" {
  file_system_id = aws_efs_file_system.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceEncryptionInTransit"
        Effect = "Deny"
        Principal = {
          AWS = "*"
        }
        Action = "*"
        Resource = aws_efs_file_system.main.arn
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.admin_role_arn
        }
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = aws_efs_file_system.main.arn
      }
    ]
  })
}

# Backup Plan
resource "aws_backup_plan" "efs" {
  name = "${var.project_name}-efs-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.efs.name
    schedule          = "cron(0 2 * * ? *)"  # 2 AM daily

    lifecycle {
      delete_after = 30
    }
  }

  rule {
    rule_name         = "weekly_backup"
    target_vault_name = aws_backup_vault.efs.name
    schedule          = "cron(0 3 ? * 1 *)"  # 3 AM every Monday

    lifecycle {
      delete_after = 90
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_backup_vault" "efs" {
  name        = "${var.project_name}-efs-backup-vault"
  kms_key_arn = aws_kms_key.efs.arn

  tags = {
    Environment = var.environment
  }
}

resource "aws_backup_selection" "efs" {
  name         = "${var.project_name}-efs-backup-selection"
  plan_id      = aws_backup_plan.efs.id
  iam_role_arn = aws_iam_role.backup.arn

  resources = [
    aws_efs_file_system.main.arn
  ]
}

# IAM Role for AWS Backup
resource "aws_iam_role" "backup" {
  name = "${var.project_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "burst_credit_balance" {
  count               = var.throughput_mode == "bursting" ? 1 : 0
  alarm_name          = "${var.project_name}-efs-low-burst-credits"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BurstCreditBalance"
  namespace           = "AWS/EFS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000000000  # 1 TiB in bytes
  alarm_description   = "EFS burst credit balance is low"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "client_connections" {
  alarm_name          = "${var.project_name}-efs-high-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ClientConnections"
  namespace           = "AWS/EFS"
  period              = 300
  statistic           = "Sum"
  threshold           = 1000
  alarm_description   = "High number of client connections to EFS"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    FileSystemId = aws_efs_file_system.main.id
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "efs" {
  dashboard_name = "${var.project_name}-efs-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EFS", "ClientConnections", { stat = "Sum", label = "Client Connections" }],
            [".", "DataReadIOBytes", { stat = "Sum", label = "Read Throughput" }],
            [".", "DataWriteIOBytes", { stat = "Sum", label = "Write Throughput" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EFS Activity"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EFS", "StorageBytes", { stat = "Average" }]
          ]
          period = 3600
          stat   = "Average"
          region = var.aws_region
          title  = "Storage Size"
        }
      },
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EFS", "PermittedThroughput", { stat = "Average" }]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Permitted Throughput"
        }
      }
    ]
  })
}

# Outputs
output "file_system_id" {
  description = "The ID of the EFS file system"
  value       = aws_efs_file_system.main.id
}

output "file_system_arn" {
  description = "The ARN of the EFS file system"
  value       = aws_efs_file_system.main.arn
}

output "file_system_dns_name" {
  description = "The DNS name of the EFS file system"
  value       = aws_efs_file_system.main.dns_name
}

output "access_point_app_id" {
  description = "The ID of the application access point"
  value       = aws_efs_access_point.app.id
}

output "access_point_data_id" {
  description = "The ID of the data access point"
  value       = aws_efs_access_point.data.id
}

output "mount_command" {
  description = "Command to mount the EFS file system"
  value       = "sudo mount -t efs -o tls ${aws_efs_file_system.main.id}:/ /mnt/efs"
}
```

### Variables File

```hcl
# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EFS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for mount targets (one per AZ)"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access EFS"
  type        = list(string)
}

variable "performance_mode" {
  description = "Performance mode (generalPurpose or maxIO)"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be either generalPurpose or maxIO."
  }
}

variable "throughput_mode" {
  description = "Throughput mode (bursting, provisioned, or elastic)"
  type        = string
  default     = "elastic"

  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.throughput_mode)
    error_message = "Throughput mode must be bursting, provisioned, or elastic."
  }
}

variable "provisioned_throughput" {
  description = "Provisioned throughput in MiB/s (required if throughput_mode is provisioned)"
  type        = number
  default     = null
}

variable "transition_to_ia" {
  description = "Lifecycle policy to transition to IA storage class"
  type        = string
  default     = "AFTER_30_DAYS"

  validation {
    condition = contains([
      "AFTER_7_DAYS",
      "AFTER_14_DAYS",
      "AFTER_30_DAYS",
      "AFTER_60_DAYS",
      "AFTER_90_DAYS"
    ], var.transition_to_ia)
    error_message = "Must be a valid transition period."
  }
}

variable "admin_role_arn" {
  description = "ARN of IAM role with admin access to EFS"
  type        = string
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms"
  type        = string
  default     = ""
}
```

### Usage Example

```hcl
# terraform.tfvars

aws_region     = "us-east-1"
project_name   = "webapp"
environment    = "production"
vpc_id         = "vpc-12345678"
subnet_ids     = ["subnet-abc123", "subnet-def456", "subnet-ghi789"]
allowed_security_groups = ["sg-app123456", "sg-lambda123456"]

performance_mode        = "generalPurpose"
throughput_mode         = "elastic"
transition_to_ia        = "AFTER_30_DAYS"

admin_role_arn          = "arn:aws:iam::123456789012:role/admin"
alarm_sns_topic_arn     = "arn:aws:sns:us-east-1:123456789012:alerts"
```

```bash
# Deploy
terraform init
terraform plan
terraform apply

# Get mount command
terraform output mount_command
```

## Conclusion

Amazon Elastic File System (EFS) provides a powerful, fully managed, elastic file storage solution that seamlessly integrates with AWS services and on-premises infrastructure. Its ability to automatically scale, handle massive concurrent access, and provide high availability makes it an ideal choice for a wide range of modern cloud applications.

**Key Advantages:**

1. **Simplicity:** No capacity planning, no provisioning, no management overhead - EFS automatically handles scaling and availability.

2. **Cost Efficiency:** With lifecycle management and Infrequent Access storage classes, you can achieve up to 96% cost savings compared to all-Standard storage.

3. **Performance:** From low-latency web serving to high-throughput big data analytics, EFS provides the performance characteristics needed for diverse workloads.

4. **Flexibility:** Support for thousands of concurrent connections, multiple protocols, and integration with EC2, containers, Lambda, and on-premises systems.

5. **Security:** Built-in encryption, IAM integration, VPC isolation, and compliance certifications ensure your data is protected.

6. **Reliability:** Multi-AZ replication, 99.999999999% durability, and automated backups provide enterprise-grade data protection.

**When to Use EFS:**

- Applications requiring shared file storage across multiple instances
- Container and serverless applications needing persistent storage
- Content management systems and web serving
- Big data and analytics workloads
- Machine learning training data lakes
- Development and testing environments
- Hybrid cloud file sharing
- Media processing and rendering workflows

**When to Consider Alternatives:**

- Object storage needs (use S3)
- Block storage for single instance (use EBS)
- Extremely high IOPS requirements (use EBS with io2)
- Windows file systems (use FSx for Windows File Server)
- Lustre high-performance computing (use FSx for Lustre)

Amazon EFS continues to evolve with new features like EFS Replication, Elastic Throughput, and Archive storage classes, making it an increasingly compelling choice for modern cloud-native applications. Whether you're building a simple content management system or a complex distributed application, EFS provides the scalable, reliable, and cost-effective file storage foundation your applications need to succeed.
