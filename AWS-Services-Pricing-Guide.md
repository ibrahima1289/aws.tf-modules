# AWS Services Pricing Guide

A comprehensive reference for AWS service pricing with links to detailed documentation and real-world cost examples.

## Legend

| Label | Cost Range | Description |
|-------|------------|-------------|
| 🟢 | **FREE** | No charge for the service itself (may pay for underlying resources) |
| 🟤 | **$0 - $100/month** | Low to moderate cost for typical usage scenarios |
| 🔴 | **$100+/month** | High-cost services that can easily exceed $100/month in production |

---

## Compute Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **EC2** | [aws-ec2.md](modules/compute/aws_EC2s/aws-ec2/aws-ec2.md) | Per-second billing (60s minimum) | **Free Tier:** 750 hours/month of t2.micro or t3.micro (12 months)<br>• t3.medium (2 vCPU, 4 GB): $0.0416/hour = $30.37/month<br>• m5.large (2 vCPU, 8 GB): $0.096/hour = $70.08/month<br>• c5.xlarge (4 vCPU, 8 GB): $0.17/hour = $124.10/month<br>• Spot instance discount: 50-90% savings |
| 🟤 **Lambda** | [aws-lambda.md](modules/compute/aws_serverless/aws_lambda/aws-lambda.md) | Per request + duration | **Free Tier (Always Free):** 1M requests/month + 400,000 GB-seconds/month<br>• $0.20 per 1M requests (after free tier)<br>• $0.0000166667 per GB-second<br>• Example: 10M requests × 128MB × 200ms = $3.33/month (9M billable) |
| 🟤 **ECS** | [aws-ecs.md](modules/compute/aws_containers/aws_ecs/aws-ecs.md) | EC2 or Fargate pricing | • Fargate: $0.04048/vCPU-hour + $0.004445/GB-hour<br>• 0.5 vCPU, 1GB task = $0.024/hour = $17.54/month<br>• EC2 mode: Pay only for EC2 instances (ECS control plane free) |
| 🔴 **EKS** | [aws-eks.md](modules/compute/aws_containers/aws_eks/aws-eks.md) | Cluster + worker nodes | • Control plane: $0.10/hour = $73/month per cluster<br>• Worker nodes: Standard EC2 pricing<br>• Example: 1 cluster + 3 × t3.medium = $73 + $91.11 = $164.11/month |
| 🟢 **Elastic Beanstalk** | [aws-elastic-beanstalk.md](modules/compute/aws_elastic_beanstalk/aws-elastic-beanstalk.md) | No additional charge | • Free service - pay only for underlying resources<br>• Example: 2 × t3.small + ALB = $29.93 + $16.20 = $46.13/month |
| 🟢 **Batch** | [aws-batch.md](modules/compute/aws_batch/aws-batch.md) | No additional charge | • Free service - pay for EC2/Fargate compute used<br>• Example: 100 jobs × 10 min × c5.large = $2.83 |

## Storage Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **S3** | [aws-s3.md](modules/storage/aws_s3/aws-s3.md) | Per GB stored + requests | **Free Tier (12 months):** 5 GB Standard storage, 20,000 GET, 2,000 PUT requests/month<br>• Standard: $0.023/GB/month (first 50 TB)<br>• 1 TB storage = $23.55/month<br>• PUT requests: $0.005 per 1,000<br>• GET requests: $0.0004 per 1,000<br>• Data transfer out: $0.09/GB (first 10 TB) |
| 🟤 **EBS** | [aws-ebs.md](modules/storage/aws_ebs/aws-ebs.md) | Per GB-month + IOPS | **Free Tier (12 months):** 30 GB of gp2/gp3 storage + 2M I/Os + 1 GB snapshots<br>• gp3: $0.08/GB/month, 100 GB = $8/month<br>• io2: $0.125/GB/month + $0.065 per provisioned IOPS<br>• 500 GB + 5,000 IOPS = $62.50 + $325 = $387.50/month<br>• Snapshot: $0.05/GB/month |
| 🟤 **EFS** | [aws-efs.md](modules/storage/aws_efs/aws-efs.md) | Pay for storage used | • Standard: $0.30/GB/month<br>• Infrequent Access: $0.025/GB/month<br>• 100 GB Standard = $30/month<br>• 1 TB with lifecycle (20% IA) = $300 × 0.8 + $25 × 0.2 = $245/month |
| 🔴 **FSx for Windows** | [aws-fsx-windows.md](modules/storage/aws_fsx/aws_fsx_windows/aws-fsx-windows.md) | Per GB-month + throughput | • SSD: $0.13/GB/month<br>• HDD: $0.013/GB/month<br>• 1 TB SSD + 64 MB/s = $133.12 + $36 = $169.12/month |
| 🔴 **FSx for Lustre** | [aws-fsx-lustre.md](modules/storage/aws_fsx/aws_fsx_lustre/aws-fsx-lustre.md) | Per GB-month | • Scratch: $0.140/GB/month<br>• Persistent (125 MB/s/TiB): $0.145/GB/month<br>• 10 TB persistent = $1,484/month |
| 🟤 **Storage Gateway** | [aws-storage-gateway.md](modules/storage/aws_storage_gateway/aws-storage-gateway.md) | Gateway + storage | • Gateway: Free (run on your hardware)<br>• S3 storage: Standard S3 pricing<br>• Data transfer: $0.09/GB out to on-premises |

## Database Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **RDS** | [aws-rds.md](modules/databases/relational/aws_rds/aws-rds.md) | Instance + storage + backup | **Free Tier (12 months):** 750 hours/month db.t2.micro/t3.micro + 20 GB gp2 storage + 20 GB backups<br>• db.t3.medium (MySQL): $0.068/hour = $49.64/month<br>• db.r5.large (PostgreSQL): $0.24/hour = $175.20/month<br>• Storage (gp3): $0.115/GB/month<br>• Backup: $0.095/GB/month<br>• Example: t3.medium + 100GB + 50GB backup = $49.64 + $11.50 + $4.75 = $65.89/month |
| 🔴 **Aurora** | [aws-aurora.md](modules/databases/relational/aws_aurora/aws-aurora.md) | Instance + I/O + storage | • db.r5.large: $0.29/hour = $211.70/month<br>• Storage: $0.10/GB/month<br>• I/O: $0.20 per 1M requests<br>• 500 GB + 10M I/O/month = $50 + $2 = $52/month storage/I/O<br>• Total with instance: $263.70/month |
| 🟤 **DynamoDB** | [aws-dynamodb.md](modules/databases/non-relational/aws_dynamodb/aws-dynamodb.md) | On-demand or provisioned | **Free Tier (Always Free):** 25 GB storage + 25 WCU + 25 RCU + 2.5M stream reads<br>• **On-Demand:** $1.25 per million write requests, $0.25 per million reads<br>• 10M writes + 50M reads = $12.50 + $12.50 = $25<br>• **Provisioned:** $0.00065/hour per WCU = $0.47/month, $0.00013/hour per RCU = $0.09/month<br>• 10 WCU + 50 RCU = $4.70 + $4.50 = $9.20/month<br>• Storage: $0.25/GB/month |
| 🔴 **ElastiCache** | [aws-elasticache.md](modules/databases/non-relational/aws_elasticache/aws-elasticache.md) | Node-hour pricing | • **Redis:** cache.t3.micro = $0.017/hour = $12.41/month<br>• cache.r5.large = $0.188/hour = $137.24/month<br>• **Memcached:** cache.t3.medium = $0.068/hour = $49.64/month<br>• Backup storage (Redis): $0.085/GB/month |
| 🔴 **DocumentDB** | [aws-documentdb.md](modules/databases/non-relational/aws_documentdb/aws-documentdb.md) | Instance + I/O + storage | • db.r5.large: $0.277/hour = $202.21/month<br>• Storage: $0.10/GB/month<br>• I/O: $0.20 per 1M requests<br>• 3-node cluster + 200GB = $606.63 + $20 = $626.63/month |
| 🔴 **Redshift** | [aws-redshift.md](modules/databases/relational/aws_redshift/aws-redshift.md) | Node-hour pricing | • dc2.large: $0.25/hour = $182.50/month<br>• ra3.xlplus: $1.086/hour = $792.78/month<br>• 2-node ra3.4xlarge cluster = $4.344/hour = $3,171.12/month<br>• Managed storage (RA3): $0.024/GB/month |

## Networking & Content Delivery

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **VPC** | [aws-vpc.md](modules/networking_content_delivery/aws_vpc/aws-vpc.md) | Free (components charged) | • VPC: Free<br>• NAT Gateway: $0.045/hour = $32.85/month + $0.045/GB processed<br>• 1 NAT + 1 TB data = $32.85 + $45 = $77.85/month<br>• VPN Connection: $0.05/hour = $36.50/month + data transfer |
| 🟤 **CloudFront** | [aws-cloudfront.md](modules/networking_content_delivery/aws_cloudfront/aws-cloudfront.md) | Data transfer + requests | **Free Tier (Always Free):** 1 TB data transfer out + 10M HTTP/HTTPS requests/month<br>• Data transfer out (US): $0.085/GB (first 10 TB after free tier)<br>• HTTPS requests: $0.0100 per 10,000<br>• 2 TB transfer + 20M requests = $87.10 (1 TB billable)<br>• Origin fetch: Standard data transfer pricing |
| 🟤 **Route 53** | [aws-route-53.md](modules/networking_content_delivery/aws_route_53/aws-route-53.md) | Hosted zone + queries | • Hosted zone: $0.50/month<br>• Standard queries: $0.40 per million (first 1 billion)<br>• 10 hosted zones + 100M queries = $5 + $40 = $45/month<br>• Latency-based routing: $0.60 per million queries |
| 🟤 **ELB (ALB/NLB)** | [aws-elb.md](modules/compute/aws_elb/aws-elb.md) | Per hour + LCU | • **ALB:** $0.0225/hour = $16.43/month + $0.008 per LCU-hour<br>• Average 10 LCU = $16.43 + $58.40 = $74.83/month<br>• **NLB:** $0.0225/hour + $0.006 per NLCU-hour<br>• **Classic LB:** $0.025/hour + $0.008/GB data processed |
| 🔴 **Transit Gateway** | [aws-transit-gateway.md](modules/networking_content_delivery/aws_transit_gateway/aws-transit-gateway.md) | Attachment + data processing | • Attachment: $0.05/hour = $36.50/month per VPC/VPN<br>• Data processing: $0.02/GB<br>• 5 VPCs + 10 TB/month = $182.50 + $200 = $382.50/month |
| 🟤 **PrivateLink** | [aws-privatelink.md](modules/networking_content_delivery/aws_privateLink/aws-privatelink.md) | Endpoint + data processing | • VPC Endpoint: $0.01/hour = $7.30/month<br>• Data processed: $0.01/GB<br>• 5 endpoints + 1 TB = $36.50 + $10 = $46.50/month |
| 🔴 **VPC Lattice** | [aws-vpc-lattice.md](modules/networking_content_delivery/aws_vpc_lattice/aws-vpc-lattice.md) | Per request + data processing | • Requests: $0.025 per million<br>• Data processing: $0.010/GB<br>• 1B requests + 10 TB = $25 + $100 = $125/month |
| 🔴 **Global Accelerator** | [aws-global-accelerator.md](modules/networking_content_delivery/aws_global_accelerator/aws-global-accelerator.md) | Fixed + data transfer | • Accelerator: $0.025/hour = $18.25/month<br>• DT-Premium: $0.015/GB (over internet pricing)<br>• 2 accelerators + 5 TB = $36.50 + $75 = $111.50/month |
| 🟢 **App Mesh** | [aws-app-mesh.md](modules/networking_content_delivery/aws_app_mesh/aws-app-mesh.md) | No additional charge | • Free - pay for underlying compute (ECS/EKS/EC2)<br>• Envoy proxy overhead: ~5-10% CPU/memory on tasks |

## Security, Identity & Compliance

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟢 **IAM** | [aws-iam.md](modules/security_identity_compliance/aws_iam/aws-iam.md) | Free | • Users, groups, roles, policies: Free<br>• No charges for IAM service |
| 🟤 **KMS** | [aws-kms.md](modules/security_identity_compliance/aws_kms/aws-kms.md) | Per key + requests | • Customer managed key: $1/month<br>• Requests: $0.03 per 10,000 (symmetric)<br>• 10 keys + 1M requests/month = $10 + $3 = $13/month<br>• Asymmetric key requests: $0.15 per 10,000 |
| 🟤 **Secrets Manager** | [aws-secrets-manager.md](modules/security_identity_compliance/aws_secrets_manager/aws-secrets-manager.md) | Per secret + API calls | • Secret: $0.40/month<br>• API calls: $0.05 per 10,000<br>• 50 secrets + 500K API calls = $20 + $2.50 = $22.50/month |
| 🟢 **Certificate Manager** | [aws-acm.md](modules/security_identity_compliance/aws_acm/aws-acm.md) | Free for public certs | • Public SSL/TLS certificates: Free<br>• Private CA: $400/month + $0.75 per certificate issued |
| 🟤 **WAF** | [aws-waf.md](modules/security_identity_compliance/aws_waf/aws-waf.md) | Web ACL + rules + requests | • Web ACL: $5/month<br>• Rule: $1/month each<br>• Requests: $0.60 per million<br>• 2 ACLs + 10 rules + 100M requests = $10 + $10 + $60 = $80/month |
| 🟢 **Shield Standard** | [aws-shield.md](modules/security_identity_compliance/aws_shield/aws-shield.md) | Free | • DDoS protection: Free for all customers |
| 🔴 **Shield Advanced** | [aws-shield.md](modules/security_identity_compliance/aws_shield/aws-shield.md) | Subscription + data transfer | • $3,000/month subscription<br>• Data transfer: Included (no additional charges for DDoS mitigation)<br>• 24/7 DDoS Response Team (DRT) access |
| 🔴 **GuardDuty** | [aws-guardduty.md](modules/security_identity_compliance/aws_guardduty/aws-guardduty.md) | Per GB analyzed | • CloudTrail events: $4.40 per million<br>• VPC Flow Logs: $1.00/GB<br>• DNS logs: $0.40/GB<br>• 10M CloudTrail + 500 GB VPC + 100 GB DNS = $44 + $500 + $40 = $584/month |
| 🔴 **Security Hub** | [aws-security-hub.md](modules/security_identity_compliance/aws_security_hub/aws-security-hub.md) | Per security check | • Security checks: $0.0010 each<br>• Finding ingestion: $0.00003 per finding<br>• 100K checks/month = $100/month |

## Application Integration

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **SQS** | [aws-sqs.md](modules/application_integration/aws_sqs/aws-sqs.md) | Per request | **Free Tier (Always Free):** 1M requests/month<br>• Standard: $0.40 per million requests (after free tier)<br>• FIFO: $0.50 per million requests<br>• 100M requests = $39.60 (Standard, 99M billable) or $49.50 (FIFO)<br>• Data transfer: Standard AWS rates |
| 🔴 **SNS** | [aws-sns.md](modules/application_integration/aws_sns/aws-sns.md) | Per request + delivery | **Free Tier (Always Free):** 1M publishes + 100K HTTP deliveries + 1,000 emails<br>• Publish: $0.50 per million requests (after free tier)<br>• Email: $2.00 per 100,000 notifications<br>• SMS: $0.00645 per message (US)<br>• Mobile push: $0.50 per million<br>• 10M publishes + 5M emails = $4.50 + $98 = $102.50/month |
| 🔴 **EventBridge** | [aws-eventbridge.md](modules/application_integration/aws_eventbridge/aws-eventbridge.md) | Per event published | **Free Tier:** All AWS service events free, 3rd party SaaS events included<br>• Custom events: $1.00 per million<br>• Archive: $0.023/GB/month<br>• Replay: $0.023/GB<br>• 100M custom events + 100 GB archive = $100 + $2.30 = $102.30/month |
| 🔴 **Step Functions** | [aws-step-functions.md](modules/application_integration/aws_step_function/aws-step-functions.md) | Per state transition | **Free Tier (Always Free):** 4,000 state transitions/month<br>• Standard: $0.025 per 1,000 state transitions (after free tier)<br>• Express: $1.00 per million requests + $0.000083 per GB-second<br>• 10M transitions = $249.90/month (Standard, 9.996M billable)<br>• 100M Express (1s, 512MB) = $100 + $41.50 = $141.50/month |
| 🔴 **MQ** | [aws-mq.md](modules/application_integration/aws_mq/aws-mq.md) | Broker instance hours | • mq.t3.micro: $0.033/hour = $24.09/month<br>• mq.m5.large: $0.391/hour = $285.43/month<br>• Storage: $0.10/GB/month<br>• Active/standby pair: 2× instance cost<br>• Single m5.large + 20GB = $285.43 + $2 = $287.43/month |

## Analytics

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **Athena** | [aws-athena.md](modules/analytics/aws_athena/aws-athena.md) | Per TB scanned | • $5.00 per TB of data scanned<br>• 100 queries × 10 GB each = $5<br>• Partitioning/compression reduces costs by 50-90%<br>• 1 TB scanned with Parquet (90% reduction) = $0.50 vs $5.00 |
| 🟤 **Glue** | [aws-glue.md](modules/analytics/aws_glue/aws-glue.md) | DPU-hour + catalog | **Free Tier (Always Free):** 1M objects stored in Data Catalog/month + 1M requests<br>• ETL Job: $0.44 per DPU-hour<br>• Data Catalog: $1.00 per 100,000 objects stored (after 1M)<br>• Crawler: $0.44 per DPU-hour<br>• 10 DPU job × 30 min daily = $0.44 × 10 × 0.5 × 30 = $66/month<br>• 2M catalog objects = $10/month (1M billable) |
| 🔴 **Kinesis Data Streams** | [aws-kinesis.md](modules/analytics/aws_kinesis/aws-kinesis.md) | Shard hour + PUT payload | • Shard: $0.015/hour = $10.95/month<br>• PUT Payload Unit (25 KB): $0.014 per million<br>• Extended retention (7 days): $0.023/shard-hour<br>• 10 shards + 100M records = $109.50 + $1.40 = $110.90/month |
| 🔴 **Kinesis Firehose** | [aws-kinesis-firehose.md](modules/analytics/aws_kinesis/aws-kinesis-firehose.md) | Per GB ingested | • Data ingestion: $0.029/GB<br>• Format conversion: $0.018/GB<br>• VPC delivery: $0.01/hour per AZ<br>• 10 TB/month = $290 (ingestion only)<br>• With Parquet conversion: $290 + $180 = $470/month |
| 🔴 **MSK (Kafka)** | [aws-msk.md](modules/analytics/aws-msk/aws-msk.md) | Broker + storage | • kafka.t3.small: $0.048/hour = $35.04/month<br>• kafka.m5.large: $0.210/hour = $153.30/month<br>• Storage: $0.10/GB/month<br>• 3-broker cluster (m5.large) + 1 TB = $459.90 + $100 = $559.90/month |
| 🔴 **EMR** | [aws-emr.md](modules/analytics/aws_emr/aws-emr.md) | EC2 cost + EMR charge | • EMR charge: Additional 25% of EC2 cost<br>• Example: 5 × m5.xlarge EC2 = $0.192/hour × 5 = $0.96/hour<br>• EMR fee: $0.96 × 0.25 = $0.24/hour<br>• Total: $1.20/hour = $876/month for continuous cluster |
| 🔴 **QuickSight** | [aws-quicksight.md](modules/analytics/aws_quicksight/aws-quicksight.md) | Per user/session | • Reader: $0.30/session (max $5/month)<br>• Author: $18/month (annual), $24/month (monthly)<br>• Enterprise: $18/month reader, $24/month author<br>• 10 authors + 100 readers = $240 + $500 = $740/month |

## Machine Learning & AI

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **SageMaker** | [aws-sagemaker.md](modules/ml_and_ai/aws_sagemaker/aws-sagemaker.md) | Instance hours + storage | • **Training:** ml.m5.xlarge = $0.269/hour<br>• **Hosting:** ml.t3.medium = $0.065/hour = $47.45/month<br>• **Notebooks:** ml.t3.medium = $0.0582/hour = $42.48/month<br>• Studio storage: $0.023/GB/month<br>• Example: 1 endpoint + 10 GB = $47.45 + $0.23 = $47.68/month |
| 🔴 **Comprehend** | [aws-comprehend.md](modules/ml_and_ai/aws_comprehend/aws-comprehend.md) | Per unit (100 chars) | • Sentiment/Entities: $0.0001 per unit<br>• Key phrases: $0.0001 per unit<br>• Custom classification: $3.00 per custom model/month + $0.0005 per unit<br>• 1M documents (avg 500 chars) = 5M units = $500 |
| 🟤 **Rekognition** | [aws-rekognition.md](modules/ml_and_ai/aws_rekognition/aws-rekognition.md) | Per image/minute | • Image analysis: $0.001 per image (first 1M/month)<br>• Face detection: $0.001 per image<br>• Video analysis: $0.10 per minute<br>• 100K images = $100<br>• 1,000 minutes video = $100 |
| 🔴 **Lex** | [aws-lex.md](modules/ml_and_ai/aws_lex/aws-lex.md) | Per request | • Text: $0.00075 per request<br>• Speech: $0.004 per request<br>• 100K text requests = $75/month<br>• 50K speech requests = $200/month |

## Developer Tools

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **CodeCommit** | [aws-codecommit.md](modules/developer_tools/aws_codecommit/aws-codecommit.md) | Per active user | **Free Tier (Always Free):** 5 active users/month + 50 GB storage + 10,000 Git requests<br>• $1.00 per additional active user/month<br>• Storage: $0.06/GB/month (after 50 GB)<br>• 20 users = $15/month (15 billable users) |
| 🟤 **CodeBuild** | [aws-codebuild.md](modules/developer_tools/aws_codebuild/aws-codebuild.md) | Per build minute | **Free Tier (Always Free):** 100 build minutes/month (general1.small)<br>• general1.small: $0.005/minute<br>• general1.medium: $0.01/minute<br>• general1.large: $0.02/minute<br>• 1,000 builds × 5 min × medium = 5,000 min × $0.01 = $50/month |
| 🟢 **CodeDeploy** | [aws-codedeploy.md](modules/developer_tools/aws_codedeploy/aws-codedeploy.md) | Free for EC2/Lambda/ECS | • EC2/Lambda: Free<br>• On-premises: $0.02 per instance update |
| 🟤 **CodePipeline** | [aws-codepipeline.md](modules/developer_tools/aws_codepipeline/aws-codepipeline.md) | Per active pipeline | **Free Tier (Always Free):** 1 active pipeline/month<br>• $1.00 per active pipeline/month (after free tier)<br>• 10 pipelines = $9/month (1 free + 9 × $1) |
| 🟢 **Cloud9** | [aws-cloud9.md](modules/developer_tools/aws_cloud9/aws-cloud9.md) | No additional charge | • Free - pay for underlying EC2 instance<br>• t2.micro: $0.0116/hour = $8.47/month<br>• Auto-hibernation after 30 min saves costs |
| 🟢 **CloudShell** | [aws-cloudshell.md](modules/developer_tools/aws_cloudshell/aws-cloudshell.md) | Free | • Completely free<br>• 1 GB persistent storage per region included<br>• No charges for compute time |

## Management & Governance

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **CloudWatch** | [aws-cloudwatch.md](modules/management_and_governance/aws_cloudwatch/aws-cloudwatch.md) | Metrics + logs + dashboards | **Free Tier (Always Free):** 10 custom metrics + 10 alarms + 5 GB logs + 3 dashboards + 1M API requests<br>• Standard metrics: Free (5-min intervals)<br>• Custom metrics: $0.30/metric/month (after 10)<br>• Logs ingestion: $0.50/GB (after 5 GB)<br>• Logs storage: $0.03/GB/month<br>• Dashboard: $3/month (after 3)<br>• 100 custom metrics + 100 GB logs = $27 + $47.50 = $74.50/month |
| 🟤 **CloudTrail** | [aws-cloudtrail.md](modules/management_and_governance/aws_cloudtrail/aws-cloudtrail.md) | Per event recorded | **Free Tier (Always Free):** First trail with management events delivered to S3<br>• Additional trail: $2.00 per 100,000 management events<br>• Data events: $0.10 per 100,000 events<br>• Insights: $0.35 per 100,000 write events analyzed<br>• CloudTrail Lake: 5-year event data store included (new accounts) |
| 🟤 **Systems Manager** | [aws-systems-manager.md](modules/management_and_governance/aws_systems_manager/aws-systems-manager.md) | Feature-based | • Parameter Store: Standard free, Advanced $0.05/parameter/month<br>• Session Manager: Free<br>• Automation: $0.002 per step<br>• OpsCenter: $0.06 per OpsItem<br>• 1,000 automation steps = $2/month |
| 🟢 **CloudFormation** | [aws-cloudformation.md](modules/management_and_governance/aws_cloudformation/aws-cloudformation.md) | Free | • No charges for CloudFormation itself<br>• Pay only for AWS resources created |
| 🔴 **Config** | [aws-config.md](modules/management_and_governance/aws_config/aws-config.md) | Per item + rules | • Configuration items: $0.003 per item recorded<br>• Rules: $0.001 per evaluation (first 100K), $0.0005 after<br>• 10,000 items + 5 rules × 20K evaluations = $30 + $100 = $130/month |
| 🟢 **Organizations** | [aws-organizations.md](modules/management_and_governance/aws_organizations/aws-organizations.md) | Free | • No charge for AWS Organizations<br>• Consolidated billing: Free |

## Migration & Transfer

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🔴 **DMS** | [aws-dms.md](modules/migration_and_transfer/aws_dms/aws-dms.md) | Instance hours + storage | • dms.t3.medium: $0.073/hour = $53.29/month<br>• dms.c5.2xlarge: $0.6528/hour = $476.54/month<br>• Replication storage: $0.115/GB/month<br>• Single-AZ medium + 50 GB = $53.29 + $5.75 = $59.04/month |
| 🟤 **DataSync** | [aws-datasync.md](modules/migration_and_transfer/aws_datasync/aws-datasync.md) | Per GB transferred | • Data copied: $0.0125/GB<br>• 10 TB transfer = $128<br>• Includes network acceleration and data validation |
| 🔴 **Snow Family** | [aws-snow.md](modules/migration_and_transfer/aws_snow/aws-snow.md) | Device rental + shipping | • **Snowball Edge Storage:** $300 first 10 days, $30/day after<br>• **Snowcone:** $200 first 5 days, $30/day after<br>• Shipping: Included (US)<br>• 30-day project: $300 + (20 × $30) = $900 |

## Additional Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟤 **API Gateway** | [aws-api-gateway.md](modules/networking_content_delivery/aws_api_gateway/aws-api-gateway.md) | Per million requests | **Free Tier (12 months):** 1M REST API calls/month<br>• REST API: $3.50 per million requests (after free tier)<br>• HTTP API: $1.00 per million requests<br>• WebSocket: $1.00 per million messages + $0.25 per million connection minutes<br>• 10M REST calls = $31.50/month (9M billable)<br>• Caching: $0.02/hour per GB |
| 🟤 **AppSync** | [aws-appsync.md](modules/networking_content_delivery/aws_appsync/aws-appsync.md) | Query + real-time updates | • Query/mutation: $4.00 per million<br>• Real-time updates: $2.00 per million<br>• 5M queries + 10M updates = $20 + $20 = $40/month |
| 🔴 **Cognito** | [aws-cognito.md](modules/security_identity_compliance/aws_cognito/aws-cognito.md) | Per MAU (Monthly Active User) | **Free Tier (Always Free):** 50,000 MAUs/month<br>• 50,001-100,000: $0.0055/MAU<br>• 100,001-1,000,000: $0.0046/MAU<br>• 500K MAUs = Free (50K) + $275 + $1,840 = $2,115/month |
| 🟤 **Backup** | [aws-backup.md](modules/management_and_governance/aws_backup/aws-backup.md) | Storage + restore | • Warm backup: $0.05/GB/month<br>• Cold backup: $0.01/GB/month<br>• Restore: $0.02/GB<br>• 1 TB warm + monthly 100 GB restore = $51.20 + $2 = $53.20/month |

## Cost Optimization Tips

### General Strategies
1. **Reserved Instances / Savings Plans:** 30-72% savings for predictable workloads
2. **Spot Instances:** Up to 90% savings for fault-tolerant workloads  
3. **Right-sizing:** Monitor and adjust instance sizes to match actual usage
4. **Auto Scaling:** Scale down during low-traffic periods
5. **S3 Lifecycle Policies:** Move infrequent data to cheaper storage classes
6. **Data Transfer Optimization:** Use VPC endpoints, CloudFront, and regional resources

### Service-Specific Optimizations
- **Lambda:** Optimize memory allocation (CPU scales with memory)
- **DynamoDB:** Use on-demand for unpredictable, provisioned for steady workloads
- **RDS/Aurora:** Use Aurora Serverless for variable workloads
- **S3:** Use Intelligent-Tiering for unknown access patterns
- **EC2:** Use Graviton instances (20-40% better price-performance)
- **CloudWatch:** Reduce custom metric frequency, filter logs before ingestion

### Monitoring Tools
- **AWS Cost Explorer:** Visualize and analyze costs
- **AWS Budgets:** Set custom cost and usage budgets with alerts
- **Cost Anomaly Detection:** ML-powered unusual spending detection
- **Compute Optimizer:** Right-sizing recommendations
- **Trusted Advisor:** Best practice checks including cost optimization

---

## Sources and References

### Official AWS Pricing Resources
- **AWS Pricing Calculator:** https://calculator.aws/
- **AWS Free Tier:** https://aws.amazon.com/free/
- **AWS Pricing Overview:** https://aws.amazon.com/pricing/

### Compute Service Pricing
- **EC2 Pricing:** https://aws.amazon.com/ec2/pricing/
- **Lambda Pricing:** https://aws.amazon.com/lambda/pricing/
- **ECS Pricing:** https://aws.amazon.com/ecs/pricing/
- **EKS Pricing:** https://aws.amazon.com/eks/pricing/
- **Elastic Beanstalk:** https://aws.amazon.com/elasticbeanstalk/pricing/
- **AWS Batch:** https://aws.amazon.com/batch/pricing/

### Storage Service Pricing
- **S3 Pricing:** https://aws.amazon.com/s3/pricing/
- **EBS Pricing:** https://aws.amazon.com/ebs/pricing/
- **EFS Pricing:** https://aws.amazon.com/efs/pricing/
- **FSx Pricing:** https://aws.amazon.com/fsx/pricing/
- **Storage Gateway:** https://aws.amazon.com/storagegateway/pricing/

### Database Service Pricing
- **RDS Pricing:** https://aws.amazon.com/rds/pricing/
- **Aurora Pricing:** https://aws.amazon.com/rds/aurora/pricing/
- **DynamoDB Pricing:** https://aws.amazon.com/dynamodb/pricing/
- **ElastiCache Pricing:** https://aws.amazon.com/elasticache/pricing/
- **DocumentDB Pricing:** https://aws.amazon.com/documentdb/pricing/
- **Redshift Pricing:** https://aws.amazon.com/redshift/pricing/

### Networking & Content Delivery Pricing
- **VPC Pricing:** https://aws.amazon.com/vpc/pricing/
- **CloudFront Pricing:** https://aws.amazon.com/cloudfront/pricing/
- **Route 53 Pricing:** https://aws.amazon.com/route53/pricing/
- **Elastic Load Balancing:** https://aws.amazon.com/elasticloadbalancing/pricing/
- **Transit Gateway:** https://aws.amazon.com/transit-gateway/pricing/
- **PrivateLink Pricing:** https://aws.amazon.com/privatelink/pricing/
- **VPC Lattice Pricing:** https://aws.amazon.com/vpc/lattice/pricing/
- **Global Accelerator:** https://aws.amazon.com/global-accelerator/pricing/
- **App Mesh:** https://aws.amazon.com/app-mesh/pricing/

### Security, Identity & Compliance Pricing
- **KMS Pricing:** https://aws.amazon.com/kms/pricing/
- **Secrets Manager:** https://aws.amazon.com/secrets-manager/pricing/
- **Certificate Manager:** https://aws.amazon.com/certificate-manager/pricing/
- **WAF Pricing:** https://aws.amazon.com/waf/pricing/
- **Shield Pricing:** https://aws.amazon.com/shield/pricing/
- **GuardDuty Pricing:** https://aws.amazon.com/guardduty/pricing/
- **Security Hub:** https://aws.amazon.com/security-hub/pricing/

### Application Integration Pricing
- **SQS Pricing:** https://aws.amazon.com/sqs/pricing/
- **SNS Pricing:** https://aws.amazon.com/sns/pricing/
- **EventBridge Pricing:** https://aws.amazon.com/eventbridge/pricing/
- **Step Functions:** https://aws.amazon.com/step-functions/pricing/
- **Amazon MQ:** https://aws.amazon.com/amazon-mq/pricing/

### Analytics Service Pricing
- **Athena Pricing:** https://aws.amazon.com/athena/pricing/
- **Glue Pricing:** https://aws.amazon.com/glue/pricing/
- **Kinesis Pricing:** https://aws.amazon.com/kinesis/pricing/
- **MSK Pricing:** https://aws.amazon.com/msk/pricing/
- **EMR Pricing:** https://aws.amazon.com/emr/pricing/
- **QuickSight Pricing:** https://aws.amazon.com/quicksight/pricing/

### Machine Learning & AI Pricing
- **SageMaker Pricing:** https://aws.amazon.com/sagemaker/pricing/
- **Comprehend Pricing:** https://aws.amazon.com/comprehend/pricing/
- **Rekognition Pricing:** https://aws.amazon.com/rekognition/pricing/
- **Lex Pricing:** https://aws.amazon.com/lex/pricing/

### Developer Tools Pricing
- **CodeCommit Pricing:** https://aws.amazon.com/codecommit/pricing/
- **CodeBuild Pricing:** https://aws.amazon.com/codebuild/pricing/
- **CodeDeploy Pricing:** https://aws.amazon.com/codedeploy/pricing/
- **CodePipeline Pricing:** https://aws.amazon.com/codepipeline/pricing/
- **Cloud9 Pricing:** https://aws.amazon.com/cloud9/pricing/
- **CloudShell:** https://aws.amazon.com/cloudshell/ (Free)

### Management & Governance Pricing
- **CloudWatch Pricing:** https://aws.amazon.com/cloudwatch/pricing/
- **CloudTrail Pricing:** https://aws.amazon.com/cloudtrail/pricing/
- **Systems Manager:** https://aws.amazon.com/systems-manager/pricing/
- **CloudFormation:** https://aws.amazon.com/cloudformation/pricing/
- **Config Pricing:** https://aws.amazon.com/config/pricing/
- **Organizations:** https://aws.amazon.com/organizations/pricing/

### Migration & Transfer Pricing
- **DMS Pricing:** https://aws.amazon.com/dms/pricing/
- **DataSync Pricing:** https://aws.amazon.com/datasync/pricing/
- **Snow Family:** https://aws.amazon.com/snow/pricing/

### Additional Services Pricing
- **API Gateway:** https://aws.amazon.com/api-gateway/pricing/
- **AppSync Pricing:** https://aws.amazon.com/appsync/pricing/
- **Cognito Pricing:** https://aws.amazon.com/cognito/pricing/
- **AWS Backup:** https://aws.amazon.com/backup/pricing/

### Additional Documentation
- **AWS Well-Architected Framework - Cost Optimization:** https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/
- **AWS Cost Management:** https://aws.amazon.com/aws-cost-management/
- **AWS Cost Explorer:** https://aws.amazon.com/aws-cost-management/aws-cost-explorer/
- **AWS Budgets:** https://aws.amazon.com/aws-cost-management/aws-budgets/
- **AWS Trusted Advisor:** https://aws.amazon.com/premiumsupport/technology/trusted-advisor/
- **AWS Compute Optimizer:** https://aws.amazon.com/compute-optimizer/

---

**Last Updated:** February 2026  
**Pricing Region:** US East (N. Virginia) unless otherwise specified  
**Disclaimer:** All pricing is subject to change. Always verify current pricing using the official AWS sources listed above before making purchasing decisions.
