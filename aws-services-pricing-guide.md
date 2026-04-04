# AWS Services Pricing Guide

A comprehensive reference for AWS service pricing with links to detailed documentation and real-world cost examples.

## Legend

| Label | Cost Range | Description |
|-------|------------|-------------|
| 🟢 | **FREE** | No charge for the service itself (may pay for underlying resources) |
| 🟡 | **$0 - $100/month** | Low to moderate cost for typical usage scenarios |
| 🔴 | **$100+/month** | High-cost services that can easily exceed $100/month in production |

---

## Compute Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **EC2** | [aws-ec2.md](modules/compute/aws_EC2s/aws-ec2/aws-ec2.md) | Per-second billing (60s minimum) | **Free Tier:** 750 hours/month of t2.micro or t3.micro (12 months)<br>• t3.medium (2 vCPU, 4 GB): $0.0416/hour = $30.37/month<br>• m5.large (2 vCPU, 8 GB): $0.096/hour = $70.08/month<br>• c5.xlarge (4 vCPU, 8 GB): $0.17/hour = $124.10/month<br>• Spot instance discount: 50-90% savings |
| 🟢 **Auto Scaling Group** | [aws-auto-scaling-grp.md](modules/compute/aws_EC2s/aws_auto_scaling_grp/aws-auto-scaling-grp.md) | No additional charge | • Auto Scaling: Free — pay only for EC2 instances launched<br>• Scheduled, dynamic, and predictive scaling: all Free<br>• Example: ASG scaling 2→10 × m5.large = pay only for active instance-hours |
| 🟡 **Lightsail** | [aws-lightsail.md](modules/compute/aws_EC2s/aws_lightsail/aws-lightsail.md) | Fixed monthly bundle | • $3.50/month (512 MB RAM, 1 vCPU, 20 GB SSD, 1 TB transfer)<br>• $5/month (1 GB RAM, 1 vCPU, 40 GB SSD, 2 TB transfer)<br>• $10/month (2 GB RAM, 1 vCPU, 60 GB SSD, 3 TB transfer)<br>• $40/month (8 GB RAM, 2 vCPU, 160 GB SSD, 5 TB transfer) |
| 🟢 **Image Builder** | [aws-image-builder.md](modules/compute/aws_EC2s/aws_image_builder/aws-image-builder.md) | No additional charge | • Image Builder: Free — pay for EC2 build instances + S3/EBS AMI storage<br>• 1-hour build on c5.large = $0.085 + snapshot storage cost |
| 🟡 **Lambda** | [aws-lambda.md](modules/compute/aws_serverless/aws_lambda/aws-lambda.md) | Per request + duration | **Free Tier (Always Free):** 1M requests/month + 400,000 GB-seconds/month<br>• $0.20 per 1M requests (after free tier)<br>• $0.0000166667 per GB-second<br>• 10M requests × 128MB × 200ms = $3.33/month (9M billable) |
| 🟡 **Fargate** | [aws-fargate.md](modules/compute/aws_serverless/aws_fargate/aws-fargate.md) · [Module](modules/compute/aws_serverless/aws_fargate/README.md) · [Wrapper](tf-plans/aws_fargate/README.md) | Per vCPU-hour + GB-hour | • vCPU: $0.04048/hour; Memory: $0.004445/GB-hour<br>• 0.5 vCPU + 1 GB task = $0.024/hour = $17.54/month<br>• 4 vCPU + 8 GB = $0.196/hour = $143.08/month |
| 🟡 **ECS** | [aws-ecs.md](modules/compute/aws_containers/aws_ecs/aws-ecs.md) | EC2 or Fargate pricing | • ECS control plane: Free<br>• EC2 mode: Standard EC2 pricing only<br>• Fargate mode: See Fargate pricing above |
| 🔴 **EKS** | [aws-eks.md](modules/compute/aws_containers/aws_eks/aws-eks.md) | Cluster + worker nodes | • Control plane: $0.10/hour = $73/month per cluster<br>• Worker nodes: Standard EC2 pricing<br>• 1 cluster + 3 × t3.medium = $73 + $91.11 = $164.11/month |
| 🟡 **ECR** | [aws-ecr.md](modules/compute/aws_containers/aws_ecr/aws-ecr.md) | Storage + data transfer | **Free Tier (Always Free):** 500 MB/month private repo storage<br>• Storage: $0.10/GB-month<br>• Data transfer out to internet: $0.09/GB; within same region: Free<br>• 10 GB images = $1/month |
| 🟡 **App Runner** | [aws-app-runner.md](modules/compute/aws_containers/aws_app_runner/aws-app-runner.md) | Per vCPU-hour + GB-hour | • Active: $0.064/vCPU-hour + $0.007/GB-hour<br>• Provisioned (idle): $0.007/vCPU-hour<br>• 1 vCPU + 2 GB active 50% of time = ~$26/month |
| 🟢 **App2Container** | [aws-app2container.md](modules/compute/aws_containers/aws_app2container/aws-app2container.md) | No additional charge | • Tool: Free — pay for ECR, ECS/EKS, and CodePipeline resources it creates<br>• One-time containerization of existing Java/.NET apps |
| 🟢 **Batch** | [aws-batch.md](modules/compute/aws_containers/aws_batch/aws-batch.md) | No additional charge | • Free service - pay for EC2/Fargate compute used<br>• 100 jobs × 10 min × c5.large = $2.83 |
| 🟢 **Elastic Beanstalk** | [aws-elastic-beanstalk.md](modules/compute/aws_elastic_beanstalk/aws-elastic-beanstalk.md) · [Module](modules/compute/aws_elastic_beanstalk/README.md) · [Wrapper](tf-plans/aws_elastic_beanstalk/README.md) | No additional charge | • Free service - pay only for underlying resources<br>• 2 × t3.small + ALB = $29.93 + $16.20 = $46.13/month |
| 🟡 **ELB (ALB/NLB/GLB)** | [aws-elb.md](modules/compute/aws_elb/aws-elb.md) | Per hour + LCU | • **ALB** [aws-alb.md](modules/compute/aws_elb/aws_alb/aws-alb.md): $0.0225/hr + $0.008/LCU-hr; avg 10 LCU = $74.83/month<br>• **NLB** [aws-nlb.md](modules/compute/aws_elb/aws_nlb/aws-nlb.md): $0.0225/hr + $0.006/NLCU-hr<br>• **GLB** [aws-glb.md](modules/compute/aws_elb/aws_glb/aws-glb.md): $0.0035/hr + $0.004/GLCU-hr<br>• Classic LB: $0.025/hr + $0.008/GB |

## Storage Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **S3** | [aws-s3.md](modules/storage/aws_s3/aws-s3.md) | Per GB stored + requests | **Free Tier (12 months):** 5 GB Standard storage, 20,000 GET, 2,000 PUT requests/month<br>• Standard: $0.023/GB/month (first 50 TB)<br>• 1 TB storage = $23.55/month<br>• PUT requests: $0.005 per 1,000<br>• GET requests: $0.0004 per 1,000<br>• Data transfer out: $0.09/GB (first 10 TB) |
| 🟡 **EBS** | [aws-ebs.md](modules/storage/aws_ebs/aws-ebs.md) · [Module](modules/storage/aws_ebs/README.md) · [Wrapper](tf-plans/aws_ebs/README.md) | Per GB-month + IOPS | **Free Tier (12 months):** 30 GB of gp2/gp3 storage + 2M I/Os + 1 GB snapshots<br>• gp3: $0.08/GB/month, 100 GB = $8/month<br>• io2: $0.125/GB/month + $0.065 per provisioned IOPS<br>• 500 GB + 5,000 IOPS = $62.50 + $325 = $387.50/month<br>• Snapshot: $0.05/GB/month |
| 🟡 **EFS** | [aws-efs.md](modules/storage/aws_efs/aws-efs.md) | Pay for storage used | • Standard: $0.30/GB/month<br>• Infrequent Access: $0.025/GB/month<br>• 100 GB Standard = $30/month<br>• 1 TB with lifecycle (20% IA) = $300 × 0.8 + $25 × 0.2 = $245/month |
| 🔴 **FSx for Windows** | [aws-fsx-windows.md](modules/storage/aws_fsx/aws_fsx_windows/aws-fsx-windows.md) | Per GB-month + throughput | • SSD: $0.13/GB/month<br>• HDD: $0.013/GB/month<br>• 1 TB SSD + 64 MB/s = $133.12 + $36 = $169.12/month |
| 🔴 **FSx for Lustre** | [aws-fsx-lustre.md](modules/storage/aws_fsx/aws_fsx_lustre/aws-fsx-lustre.md) | Per GB-month | • Scratch: $0.140/GB/month<br>• Persistent (125 MB/s/TiB): $0.145/GB/month<br>• 10 TB persistent = $1,484/month |
| 🟡 **Storage Gateway** | [aws-storage-gateway.md](modules/storage/aws-storage-gateway/aws-storage-gateway.md) · [Module](modules/storage/aws-storage-gateway/README.md) · [Wrapper](tf-plans/aws_storage_gateway/README.md) | Gateway + data written + storage | • Gateway activation: Free (pay for underlying VM or hardware appliance)<br>• **S3 File Gateway:** $0.01/GB written to S3; standard [S3 pricing](https://aws.amazon.com/s3/pricing/) for storage<br>• **Volume Gateway:** $0.01/GB stored in AWS (S3 + EBS snapshots); $0.05/GB-month EBS snapshot<br>• **Tape Gateway:** $0.01/GB written; $0.004/GB-month active (S3); $0.00099/GB-month archived (Deep Archive)<br>• **Hardware Appliance:** One-time ~$14,000 purchase; no gateway subscription fee<br>• Data transfer out to on-premises: $0.09/GB<br>• See [AWS Storage Gateway Pricing](https://aws.amazon.com/storagegateway/pricing/) for current region rates |

## Database Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **RDS** | [aws-rds.md](modules/databases/relational/aws_rds/aws-rds.md) | Instance + storage + backup | **Free Tier (12 months):** 750 hours/month db.t2.micro/t3.micro + 20 GB gp2 storage + 20 GB backups<br>• db.t3.medium (MySQL): $0.068/hour = $49.64/month<br>• db.r5.large (PostgreSQL): $0.24/hour = $175.20/month<br>• db.r6g.large: $0.192/hour = $140.16/month<br>• Storage (gp3): $0.115/GB/month<br>• Multi-AZ deployment: 2× instance cost<br>• Backup: $0.095/GB/month<br>• Example: r6g.large + 100GB gp3 + Multi-AZ = $280.32 + $11.50 = $291.82/month |
| 🔴 **Aurora** | [aws-aurora.md](modules/databases/relational/aws_aurora/aws-aurora.md) | Instance + I/O + storage | **Free Tier (12 months):** 750 hours/month of db.t3.small or db.t4g.small + 20 GB storage<br>• **Provisioned:** db.r6g.large = $0.29/hour = $211.70/month<br>• db.r6i.xlarge = $0.58/hour = $423.40/month<br>• Storage: $0.10/GB/month (auto-scales to 128 TB)<br>• I/O: $0.20 per 1M requests<br>• **I/O-Optimized:** ~40% higher instance cost, unlimited I/O included<br>• **Serverless v2:** $0.12 per ACU-hour; 2 ACUs = $0.24/hour = $175.20/month<br>• **Serverless v1:** $0.06 per ACU-hour; 4 ACUs = $0.24/hour = $175.20/month; no I/O charges<br>• **Backup:** $0.021/GB/month (beyond retention period)<br>• Example Provisioned: 2-node cluster (r6g.large) + 200GB + 50M I/O = $423.40 + $20 + $10 = $453.40/month<br>• Example Serverless v2: 1 writer + 1 reader (avg 2 ACUs each) = $350.40/month + storage/I/O<br>• Example I/O-Optimized: 2-node cluster (r6g.large) + 200GB = ~$593.20 + $20 = $613.20/month (no I/O charges) |
| 🟡 **DynamoDB** | [aws-dynamodb.md](modules/databases/non-relational/aws_dynamodb/aws-dynamodb.md) | On-demand or provisioned | **Free Tier (Always Free):** 25 GB storage + 25 WCU + 25 RCU + 2.5M stream reads<br>• **On-Demand:** $1.25 per million write requests, $0.25 per million reads<br>• 10M writes + 50M reads = $12.50 + $12.50 = $25<br>• **Provisioned:** $0.00065/hour per WCU = $0.47/month, $0.00013/hour per RCU = $0.09/month<br>• 10 WCU + 50 RCU = $4.70 + $4.50 = $9.20/month<br>• Storage: $0.25/GB/month<br>• **Global Tables:** Same pricing + data transfer costs<br>• **Streams:** $0.02 per 100,000 read request units<br>• **Backups:** On-demand: $0.10/GB; continuous (PITR): $0.20/GB/month |
| 🔴 **ElastiCache** | [aws-elasticache.md](modules/databases/non-relational/aws_elasticache/aws-elasticache.md) | Node-hour pricing | **Free Tier (12 months):** 750 hours/month cache.t2.micro or cache.t3.micro<br>• **Redis:** cache.t3.micro = $0.017/hour = $12.41/month<br>• cache.r5.large = $0.188/hour = $137.24/month<br>• cache.r6g.large = $0.209/hour = $152.57/month<br>• **Memcached:** cache.t3.medium = $0.068/hour = $49.64/month<br>• Backup storage (Redis): $0.085/GB/month<br>• 3-node cluster (r6g.large) = $457.71/month |
| 🔴 **DocumentDB** | [aws-documentdb.md](modules/databases/non-relational/aws_documentdb/aws-documentdb.md) | Instance + I/O + storage | **Free Tier:** None (no free tier for DocumentDB)<br>• **Instances:** db.t3.medium = $0.076/hour = $55.48/month; db.r5.large = $0.277/hour = $202.21/month; db.r6g.large = $0.261/hour = $190.53/month<br>• **Storage:** $0.10/GB/month (auto-scales, no pre-provisioning required)<br>• **I/O (standard):** $0.20 per 1M read/write I/Os<br>• **I/O-Optimized (`iopt1`):** ~25% higher instance cost, no per-I/O charges (break-even at ~1B I/Os/month)<br>• **Backup:** $0.021/GB/month (beyond the free 1× cluster storage included)<br>• **Data transfer out:** $0.09/GB (first 10 TB/month)<br>• **Example dev (1× db.t3.medium + 20 GB):** $55.48 + $2 = $57.48/month<br>• **Example prod HA (3× db.r5.large + 200 GB + 50M I/O):** $606.63 + $20 + $10 = $636.63/month<br>• **Example I/O-Optimized (3× db.r5.large + 200 GB):** ~$758.29 + $20 = $778.29/month (no I/O charges)<br>• [DocumentDB Pricing](https://aws.amazon.com/documentdb/pricing/) |

## Networking & Content Delivery

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **VPC** | [aws-vpc.md](modules/networking_content_delivery/aws_vpc/aws-vpc.md) | Free (components charged) | • VPC: Free<br>• NAT Gateway: $0.045/hour = $32.85/month + $0.045/GB processed<br>• 1 NAT + 1 TB data = $32.85 + $45 = $77.85/month<br>• VPN Connection: $0.05/hour = $36.50/month + data transfer |
| 🟡 **CloudFront** | [aws-cloudfront.md](modules/networking_content_delivery/aws_cloudfront/aws-cloudfront.md) | Data transfer + requests | **Free Tier (Always Free):** 1 TB data transfer out + 10M HTTP/HTTPS requests/month<br>• Data transfer out (US): $0.085/GB (first 10 TB after free tier)<br>• HTTPS requests: $0.0100 per 10,000<br>• 2 TB transfer + 20M requests = $87.10 (1 TB billable)<br>• Origin fetch: Standard data transfer pricing |
| 🟡 **Route 53** | [aws-route-53.md](modules/networking_content_delivery/aws_route_53/aws-route-53.md) | Hosted zone + queries | • Hosted zone: $0.50/month<br>• Standard queries: $0.40 per million (first 1 billion)<br>• 10 hosted zones + 100M queries = $5 + $40 = $45/month<br>• Latency-based routing: $0.60 per million queries |
| 🟡 **ELB (ALB/NLB)** | [aws-elb.md](modules/compute/aws_elb/aws-elb.md) | Per hour + LCU | • **ALB:** $0.0225/hour = $16.43/month + $0.008 per LCU-hour<br>• Average 10 LCU = $16.43 + $58.40 = $74.83/month<br>• **NLB:** $0.0225/hour + $0.006 per NLCU-hour<br>• **Classic LB:** $0.025/hour + $0.008/GB data processed |
| 🔴 **Transit Gateway** | [aws-transit-gateway.md](modules/networking_content_delivery/aws_transit_gateway/aws-transit-gateway.md) | Attachment + data processing | • Attachment: $0.05/hour = $36.50/month per VPC/VPN<br>• Data processing: $0.02/GB<br>• 5 VPCs + 10 TB/month = $182.50 + $200 = $382.50/month |
| 🟡 **PrivateLink** | [aws-privatelink.md](modules/networking_content_delivery/aws_privateLink/aws-privatelink.md) | Endpoint + data processing | • VPC Endpoint: $0.01/hour = $7.30/month<br>• Data processed: $0.01/GB<br>• 5 endpoints + 1 TB = $36.50 + $10 = $46.50/month |
| 🔴 **VPC Lattice** | [aws-vpc-lattice.md](modules/networking_content_delivery/aws_vpc_lattice/aws-vpc-lattice.md) | Per request + data processing | • Requests: $0.025 per million<br>• Data processing: $0.010/GB<br>• 1B requests + 10 TB = $25 + $100 = $125/month |
| 🔴 **Global Accelerator** | [aws-global-accelerator.md](modules/networking_content_delivery/aws_global_accelerator/aws-global-accelerator.md) | Fixed + data transfer | • Accelerator: $0.025/hour = $18.25/month<br>• DT-Premium: $0.015/GB (over internet pricing)<br>• 2 accelerators + 5 TB = $36.50 + $75 = $111.50/month |
| 🟢 **App Mesh** | [aws-app-mesh.md](modules/networking_content_delivery/aws_app_mesh/aws-app-mesh.md) | No additional charge | • Free - pay for underlying compute (ECS/EKS/EC2)<br>• Envoy proxy overhead: ~5-10% CPU/memory on tasks |
| 🟡 **Cloud Map** | [aws-cloud-map.md](modules/networking_content_delivery/aws_cloudMap/aws-cloud-map.md) | Per namespace + API calls | • Namespace: Free; registered instances: Free<br>• API calls: $0.10 per 1M calls<br>• DNS queries via Route 53: $0.60 per 1M<br>• 10M service discovery API calls = $1/month |
| 🟢 **Internet Gateway** | [aws-internet-gateway.md](modules/networking_content_delivery/aws_internet_gateway/aws-internet-gateway.md) | Free | • Internet Gateway itself: Free<br>• Data transfer out to internet: $0.09/GB (standard EC2 rates apply) |
| 🟢 **Route Table** | [aws-route-table.md](modules/networking_content_delivery/aws_route_table/aws-route-table.md) | Free | • Route tables and routes: Free<br>• Pay for the resources routes point to (NAT Gateway: $0.045/hr, TGW: $0.05/hr) |

## Security, Identity & Compliance

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟢 **IAM** | [aws-iam.md](modules/security_identity_compliance/aws_iam/aws-iam.md) | Free | • Users, groups, roles, policies: Free<br>• No charges for IAM service |
| 🟢 **Artifact** | [aws-artifact.md](modules/security_identity_compliance/aws_artifact/aws-artifact.md) | Free | • AWS compliance reports (SOC, PCI, ISO): Free<br>• Agreements (BAA, NDA): Free<br>• No charges for downloading compliance documents |
| 🔴 **Audit Manager** | [aws-audit-manager.md](modules/security_identity_compliance/aws_audit_manager/aws-audit-manager.md) | Per assessment resource | • $1.25/assessment-resource/month<br>• Evidence collection: included<br>• 100 resources across 2 frameworks = $250/month |
| 🟢 **Certificate Manager** | [aws-certificate-manager.md](modules/security_identity_compliance/aws_certificate_manager/aws-certificate-manager.md) · [Module](modules/security_identity_compliance/aws_certificate_manager/README.md) | Free for public certs | • Public SSL/TLS certificates: Free<br>• Private CA: $400/month + $0.75 per certificate issued |
| 🔴 **CloudHSM** | [aws-cloudhsm.md](modules/security_identity_compliance/aws_cloudHSM/aws-cloudhsm.md) | Per HSM instance-hour | • $1.60/hour per HSM = $1,168/month<br>• HA requires minimum 2 HSMs = $2,336/month<br>• No charge for cluster management |
| 🟢 **Security Groups** | [aws-security-groups.md](modules/security_identity_compliance/aws_security_group/aws-security-groups.md) | Free | • Security groups and rules: Free<br>• Pay only for traffic through associated resources |
| 🟢 **NACLs** | [aws-nacls.md](modules/security_identity_compliance/aws_nacl/aws-nacls.md) · [Module](modules/security_identity_compliance/aws_nacl/README.md) | Free | • Network ACLs and rules: Free<br>• Stateless filtering at subnet level; no additional charges |
| 🟡 **KMS** | [aws-kms.md](modules/security_identity_compliance/aws_kms/aws-kms.md) | Per key + requests | • Customer managed key: $1/month<br>• Requests: $0.03 per 10,000 (symmetric)<br>• 10 keys + 1M requests/month = $10 + $3 = $13/month<br>• Asymmetric key requests: $0.15 per 10,000 |
| 🟡 **Secrets Manager** | [aws-secrets-manager.md](modules/security_identity_compliance/aws_secrets_manager/aws-secrets-manager.md) | Per secret + API calls | • Secret: $0.40/month<br>• API calls: $0.05 per 10,000<br>• 50 secrets + 500K API calls = $20 + $2.50 = $22.50/month |
| 🟡 **WAF** | [aws-waf.md](modules/security_identity_compliance/aws_waf/aws-waf.md) · [Module](modules/security_identity_compliance/aws_waf/README.md) · [Wrapper](tf-plans/aws_waf/README.md) | Web ACL + rules + requests | • Web ACL: $5/month<br>• Rule: $1/month each<br>• Requests: $0.60 per million<br>• Bot Control rule group: $10/month + $1/million requests<br>• 2 ACLs + 10 rules + 100M requests = $10 + $10 + $60 = $80/month |
| 🟢 **RAM** | [aws-ram.md](modules/security_identity_compliance/aws_ram/aws-ram.md) | Free | • Resource Access Manager: Free<br>• Pay for the shared resources themselves (Transit Gateway, subnets, etc.) |
| 🔴 **Detective** | [aws-detective.md](modules/security_identity_compliance/aws_detective/aws-detective.md) | Per GB ingested | • $2.00/GB of data ingested (GuardDuty + CloudTrail + VPC Flow Logs)<br>• 100 GB/month = $200<br>• 30-day free trial available |
| 🔴 **Directory Service** | [aws-directory-service.md](modules/security_identity_compliance/aws_directory_service/aws-directory-service.md) | Per domain controller-hour | • Simple AD (small): $0.05/hour = $36.50/month<br>• Simple AD (large): $0.15/hour = $109.50/month<br>• Managed Microsoft AD (standard): $0.16/hour = $116.80/month<br>• Managed Microsoft AD (enterprise): $0.31/hour = $226.30/month |
| 🔴 **Firewall Manager** | [aws-firewall-manager.md](modules/security_identity_compliance/aws_firwall_manager/aws-firewall-manager.md) · [Module](modules/security_identity_compliance/aws_firwall_manager/README.md) | Per policy per region | • $100/month per policy per region<br>• Covers WAF, Shield Advanced, Security Groups, Network Firewall policies<br>• 5 policies × 3 regions = $1,500/month<br>• [Firewall Manager Pricing](https://aws.amazon.com/firewall-manager/pricing/) |
| 🔴 **GuardDuty** | [aws-guardduty.md](modules/security_identity_compliance/aws_guardDuty/aws-guardduty.md) | Per GB analyzed | • CloudTrail events: $4.40 per million<br>• VPC Flow Logs: $1.00/GB<br>• DNS logs: $0.40/GB<br>• 10M CloudTrail + 500 GB VPC + 100 GB DNS = $44 + $500 + $40 = $584/month |
| 🟡 **Inspector** | [aws-inspector.md](modules/security_identity_compliance/aws_inspector/aws-inspector.md) | Per resource scanned | • EC2 instances: $0.11/instance-month<br>• Lambda functions: $0.09/function-month<br>• Container images: $0.01/image scanned<br>• 100 EC2 + 50 Lambda = $11 + $4.50 = $15.50/month |
| 🟡 **Macie** | [aws-macie.md](modules/security_identity_compliance/aws_macie/aws-macie.md) | Per GB classified | • S3 bucket inventory: $0.003/bucket/month<br>• Sensitive data discovery: $1.00/GB (first month); $0.10/GB thereafter<br>• 100 buckets + 100 GB = $0.30 + $100 = $100.30 (first month) |
| 🔴 **Network Firewall** | [aws-network-firewall.md](modules/security_identity_compliance/aws_network_firewall/aws-network-firewall.md) · [Module](modules/security_identity_compliance/aws_network_firewall/README.md) | Per endpoint + GB processed | • Firewall endpoint: $0.395/hour = $288.35/month per AZ<br>• Traffic processed: $0.065/GB<br>• 2-AZ deployment + 10 TB/month = $576.70 + $650 = $1,226.70/month |
| 🔴 **Security Hub** | [aws-security-hub.md](modules/security_identity_compliance/aws_security_hub_CSPM/aws-security-hub.md) | Per security check | • Security checks: $0.0010 each<br>• Finding ingestion: $0.00003 per finding<br>• 100K checks/month = $100/month |
| 🟡 **Security Lake** | [aws-security-lake.md](modules/security_identity_compliance/aws_security_lake/aws-security-lake.md) | Per GB ingested + stored | • Ingestion: $0.023/GB<br>• Storage (S3): $0.023/GB-month<br>• Queries (Athena): $5.00/TB scanned<br>• 500 GB/month ingested + 1 TB stored = $11.50 + $23 = $34.50/month |
| 🟢 **Shield Standard** | [aws-shield.md](modules/security_identity_compliance/aws_shield/aws-shield.md) | Free | • DDoS protection: Free for all customers |
| 🔴 **Shield Advanced** | [aws-shield.md](modules/security_identity_compliance/aws_shield/aws-shield.md) | Subscription + data transfer | • $3,000/month subscription<br>• Data transfer: Included (no DDoS mitigation surcharges)<br>• 24/7 DDoS Response Team (DRT) access |
| 🟡 **Verified Permissions** | [aws-verified-permissions.md](modules/security_identity_compliance/aws_verified_permission/aws-verified-permissions.md) | Per authorization request | • $0.00015 per authorization request<br>• Policy store: Free<br>• 1M authorization requests/month = $150 |

## Application Integration

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **SQS** | [aws-sqs.md](modules/application_integration/aws_sqs/aws-sqs.md) | Per request | **Free Tier (Always Free):** 1M requests/month<br>• Standard: $0.40 per million requests (after free tier)<br>• FIFO: $0.50 per million requests<br>• 100M requests = $39.60 (Standard, 99M billable) or $49.50 (FIFO)<br>• Data transfer: Standard AWS rates |
| 🔴 **SNS** | [aws-sns.md](modules/application_integration/aws_sns/aws-sns.md) | Per request + delivery | **Free Tier (Always Free):** 1M publishes + 100K HTTP deliveries + 1,000 emails<br>• Publish: $0.50 per million requests (after free tier)<br>• Email: $2.00 per 100,000 notifications<br>• SMS: $0.00645 per message (US)<br>• Mobile push: $0.50 per million<br>• 10M publishes + 5M emails = $4.50 + $98 = $102.50/month |
| 🔴 **EventBridge** | [aws-eventbridge.md](modules/application_integration/aws_eventbridge/aws-eventbridge.md) · [Module](modules/application_integration/aws_eventbridge/README.md) · [Wrapper](tf-plans/aws_eventbridge/README.md) | Per event published | **Free Tier:** All AWS service events free, 3rd party SaaS events included<br>• Custom events: $1.00 per million<br>• Archive: $0.023/GB/month<br>• Replay: $0.023/GB<br>• 100M custom events + 100 GB archive = $100 + $2.30 = $102.30/month |
| 🔴 **Step Functions** | [aws-step-functions.md](modules/application_integration/aws_step_function/aws-step-functions.md) | Per state transition | **Free Tier (Always Free):** 4,000 state transitions/month<br>• Standard: $0.025 per 1,000 state transitions (after free tier)<br>• Express: $1.00 per million requests + $0.000083 per GB-second<br>• 10M transitions = $249.90/month (Standard, 9.996M billable)<br>• 100M Express (1s, 512MB) = $100 + $41.50 = $141.50/month |
| 🔴 **MQ** | [aws-mq.md](modules/application_integration/aws_mq/aws-mq.md) | Broker instance hours | • mq.t3.micro: $0.033/hour = $24.09/month<br>• mq.m5.large: $0.391/hour = $285.43/month<br>• Storage: $0.10/GB/month<br>• Active/standby pair: 2× instance cost<br>• Single m5.large + 20GB = $285.43 + $2 = $287.43/month |

## Analytics

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **Athena** | [aws-athena.md](modules/analytics/aws_athena/aws-athena.md) · [Module](modules/analytics/aws_athena/README.md) · [Wrapper](tf-plans/aws_athena/README.md) | Per TB scanned | • $5.00 per TB of data scanned<br>• 100 queries × 10 GB each = $5<br>• Partitioning/compression reduces costs by 50-90%<br>• 1 TB scanned with Parquet (90% reduction) = $0.50 vs $5.00 |
| 🔴 **EMR** | [aws-emr.md](modules/analytics/aws_mapreduce/aws-emr.md) | EC2 cost + EMR charge | • EMR charge: Additional 25% of EC2 cost<br>• Example: 5 × m5.xlarge EC2 = $0.192/hour × 5 = $0.96/hour<br>• EMR fee: $0.96 × 0.25 = $0.24/hour<br>• Total: $1.20/hour = $876/month for continuous cluster<br>• **EMR Serverless:** Per vCPU-second + per GB-memory-second; no idle cost<br>• **EMR on EKS:** Per vCPU/memory-second used by Spark pods |
| 🟡 **Glue** | [aws-glue.md](modules/analytics/aws_glue/aws-glue.md) | DPU-hour + catalog | **Free Tier (Always Free):** 1M objects stored in Data Catalog/month + 1M requests<br>• ETL Job: $0.44 per DPU-hour<br>• Data Catalog: $1.00 per 100,000 objects stored (after 1M)<br>• Crawler: $0.44 per DPU-hour<br>• 10 DPU job × 30 min daily = $0.44 × 10 × 0.5 × 30 = $66/month<br>• 2M catalog objects = $10/month (1M billable) |
| 🔴 **Kinesis Data Streams** | [aws-kinesis.md](modules/analytics/aws_kinesis/aws-kinesis.md) | Shard hour + PUT payload | • Shard: $0.015/hour = $10.95/month<br>• PUT Payload Unit (25 KB): $0.014 per million<br>• Extended retention (7 days): $0.023/shard-hour<br>• 10 shards + 100M records = $109.50 + $1.40 = $110.90/month |
| 🔴 **Kinesis Firehose** | [aws-kinesis-firehose.md](modules/analytics/aws_kinesis/aws-kinesis-firehose.md) | Per GB ingested | • Data ingestion: $0.029/GB<br>• Format conversion: $0.018/GB<br>• VPC delivery: $0.01/hour per AZ<br>• 10 TB/month = $290 (ingestion only)<br>• With Parquet conversion: $290 + $180 = $470/month |
| 🟢 **Lake Formation** | [aws-lake-formation.md](modules/storage/aws_lake_formation/aws-lake-formation.md) | Free + governed tables | • Service: Free — pay for underlying S3, Glue, and Athena usage<br>• Governed tables: $0.025/GB-month (transaction log storage)<br>• Cross-account data sharing: Free<br>• Example: 10 TB data lake — Lake Formation adds $0/month; pay S3 ($230/month) + Athena query costs separately |
| 🔴 **MSK (Kafka)** | [aws-msk.md](modules/analytics/aws-msk/aws-msk.md) | Broker + storage | • kafka.t3.small: $0.048/hour = $35.04/month<br>• kafka.m5.large: $0.210/hour = $153.30/month<br>• Storage: $0.10/GB/month<br>• 3-broker cluster (m5.large) + 1 TB = $459.90 + $100 = $559.90/month |
| 🔴 **OpenSearch Service** | [aws-opensearch.md](modules/analytics/aws_opensearch_service/aws-opensearch.md) | Instance-hour + storage | • **Provisioned:** r6g.large.search = ~$0.166/hour = $121.18/month per node<br>• **UltraWarm:** ~⅓ the cost of hot storage per GB<br>• **Serverless:** Per OCU-hour for indexing and search<br>• EBS storage: $0.10/GB/month (gp3)<br>• 3-node cluster (r6g.large) + 500 GB = $363.54 + $50 = $413.54/month |
| 🔴 **QuickSight** | [aws-quicksight.md](modules/analytics/aws_quicksight/aws-quicksight.md) | Per user/session | • Reader: $0.30/session (max $5/month)<br>• Author: $18/month (annual), $24/month (monthly)<br>• Enterprise: $18/month reader, $24/month author<br>• 10 authors + 100 readers = $240 + $500 = $740/month |
| 🔴 **Redshift** | [aws-redshift.md](modules/analytics/aws_redshift/aws-redshift.md) | Node-hour pricing | • **Provisioned:** dc2.large = $0.25/hour = $182.50/month; ra3.xlplus = $1.086/hour = $792.78/month<br>• 2-node ra3.4xlarge cluster = $4.344/hour = $3,171.12/month<br>• Managed storage (RA3): $0.024/GB/month<br>• **Serverless:** Per RPU-second used<br>• **Spectrum:** $5.00 per TB of S3 data scanned |

## Machine Learning & AI

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **Augmented AI (A2I)** | [aws-augmented-ai.md](modules/ml_and_ai/aws_augmented_ai/aws-augmented-ai.md) | Per human review | • $0.08 per human review object processed<br>• Built-in task templates for Rekognition, Textract, and custom ML<br>• 1,000 reviews/month = $80 |
| 🔴 **Bedrock** | [aws-bedrock.md](modules/ml_and_ai/aws_bedrock/aws-bedrock.md) | Per input/output token | • **Claude 3.5 Sonnet:** $0.003/1K input + $0.015/1K output tokens<br>• **Titan Text Express:** $0.0002/1K input + $0.0006/1K output<br>• **Llama 3.1 70B:** $0.00099/1K input + $0.00099/1K output<br>• **Titan Image G1:** $0.008–$0.01 per image<br>• 1M input + 500K output (Claude 3.5 Sonnet) = $3.00 + $7.50 = $10.50 |
| 🔴 **CodeGuru** | [aws-codeguru.md](modules/ml_and_ai/aws_codeGuru/aws-codeguru.md) | Per line + per hour | • **Reviewer:** $0.75 per 100 lines (first 100K lines/month); $0.375/100 lines after<br>• **Profiler:** $0.005/hour per profiled instance<br>• 50K lines reviewed + 1 instance = $375 + $3.65 = $378.65/month |
| 🔴 **Comprehend** | [aws-comprehend.md](modules/ml_and_ai/aws_comprehend/aws-comprehend.md) | Per unit (100 chars) | • Sentiment/Entities/Key phrases: $0.0001 per unit<br>• Custom classification: $3.00/model/month + $0.0005 per unit<br>• 1M documents (avg 500 chars) = 5M units = $500 |
| 🟡 **Comprehend Medical** | [aws-comprehend-medical.md](modules/ml_and_ai/aws_comprehend_medical/aws-comprehend-medical.md) | Per unit (100 chars) | • NLP inference: $0.0025 per unit<br>• PHI detection & de-identification: $0.0025 per unit<br>• 100K units/month = $250 |
| 🟡 **DeepComposer** | [aws-deepcomposer.md](modules/ml_and_ai/aws_deepComposer/aws-deepcomposer.md) | Per training job | • Training: $0.31/hour (ml.c5.4xlarge)<br>• In-browser inference: Free<br>• Physical keyboard: one-time ~$99<br>• 10 training jobs × 30 min = $1.55/month |
| 🟡 **DeepRacer** | [aws-deepracer.md](modules/ml_and_ai/aws_deepRacer/aws-deepracer.md) | Per training hour | • Virtual training: $3.50/hour<br>• Community race participation: Free<br>• Physical car: one-time ~$299<br>• 10 training hours/month = $35 |
| 🟡 **DevOps Guru** | [aws-devops-guru.md](modules/ml_and_ai/aws_devops_guru/aws-devops-guru.md) | Per resource analyzed | • $0.0028/resource-hour (first 100K hours/month)<br>• $0.0014/resource-hour (above 100K hours)<br>• 50 resources × 730 hours = $102.20/month |
| 🟡 **Forecast** | [aws-forecast.md](modules/ml_and_ai/aws_forecast/aws-forecast.md) | Per forecast + training | • Generated forecasts: $0.60 per 1,000<br>• Training: $0.24/hour<br>• Storage: $0.088/GB/month<br>• 10K forecasts + 5 training hours = $6 + $1.20 = $7.20 |
| 🔴 **Fraud Detector** | [aws-fraud-detector.md](modules/ml_and_ai/aws_fraud_detector/aws-fraud-detector.md) | Per prediction | • Online fraud: $0.0075 per prediction<br>• Account takeover: $0.0075 per prediction<br>• Model training: $0.24/hour<br>• 100K predictions/month = $750 |
| 🟡 **HealthLake** | [aws-healthlake.md](modules/ml_and_ai/aws_healthLake/aws-healthlake.md) | Storage + operations | • Storage: $0.021/GB/month<br>• FHIR operations: $0.01 per 1,000 reads; $0.05 per 1,000 writes<br>• 100 GB + 100K reads + 10K writes = $2.10 + $1 + $0.50 = $3.60/month |
| 🟡 **HealthScribe** | [aws-healthscribe.md](modules/ml_and_ai/aws_healthScribe/aws-healthscribe.md) | Per minute transcribed | • $0.024/minute of audio transcribed<br>• Includes clinical note generation<br>• 100 hours of consultations/month = $144 |
| 🔴 **Kendra** | [aws-kendra.md](modules/ml_and_ai/aws_kendra/aws-kendra.md) | Per edition + queries | • **Developer Edition:** $810/month (750 queries/day, 10K documents)<br>• **Enterprise Edition:** $1,008/month (40K queries/day, 100K documents)<br>• Extra queries: $0.25 per 1,000 (Developer); $0.10 per 1,000 (Enterprise)<br>• Additional document storage: $0.10/GB/month |
| 🔴 **Lex** | [aws-lex.md](modules/ml_and_ai/aws_lex/aws-lex.md) | Per request | • Text: $0.00075 per request<br>• Speech: $0.004 per request<br>• 100K text requests = $75/month<br>• 50K speech requests = $200/month |
| 🔴 **Lookout for Equipment** | [aws-lookout-for-equipment.md](modules/ml_and_ai/aws_lookout_for_equipment/aws-lookout-for-equipment.md) | Per model + inferences | • Model training: $1.00/hour<br>• Model hosting: $250/model/month<br>• Inferences: $0.10 per 1,000<br>• 1 model + 100K inferences/month = $250 + $10 = $260 |
| 🟡 **Lookout for Metrics** | [aws-lookout-for-metrics.md](modules/ml_and_ai/aws_lookout_for_metrics/aws-lookout-for-metrics.md) | Per detector + metrics | • Continuous detector: $0.075/hour = $54.75/month<br>• Backtest detector: $0.01/hour<br>• Per metric analyzed (over 25): $0.03/metric/hour<br>• 1 continuous detector + 25 metrics = $54.75/month |
| 🟡 **Lookout for Vision** | [aws-lookout-for-vision.md](modules/ml_and_ai/aws_lookout_for_vision/aws-lookout-for-vision.md) | Per inference + training | • Trial detection: $0.002 per image (first 500K images/month)<br>• Model training: $4.00/hour<br>• Hosted model: $2.00/hour<br>• 10K trial images + 5 training hours = $20 + $20 = $40 |
| 🟡 **Monitron** | [aws-monitron.md](modules/ml_and_ai/aws_monitron/aws-monitron.md) | Per sensor/month | • $10.00/sensor/month<br>• Gateway: one-time device purchase<br>• 10 sensors = $100/month<br>• Free tier: 2 sensors for first 12 months |
| 🟡 **Panorama** | [aws-panorama.md](modules/ml_and_ai/aws_panorama/aws-panorama.md) | Per appliance + models | • Appliance: one-time hardware purchase (~$1,000)<br>• Model inference: $0.10/hour per model deployed<br>• 2 models × 730 hours = $146/month |
| 🟢 **PartyRock** | [aws-party-rock.md](modules/ml_and_ai/aws_party_rock/aws-party-rock.md) | Free (Bedrock-backed) | • Playground: Free trial credits included<br>• Underlying model usage billed through Bedrock<br>• App building and sharing: Free |
| 🔴 **Personalize** | [aws-personalize.md](modules/ml_and_ai/aws_personalize/aws-personalize.md) | Per TPS-hour + training | • Real-time recommendations: $0.20/TPS-hour<br>• Batch recommendations: $0.067/1,000 users or items<br>• Training: $0.24/hour<br>• 1 TPS sustained + 5 training hours = $146 + $1.20 = $147.20/month |
| 🟡 **Polly** | [aws-polly.md](modules/ml_and_ai/aws_polly/aws-polly.md) | Per character synthesized | • Standard voices: $4.00 per 1M characters<br>• Neural voices: $16.00 per 1M characters<br>• Long-form (Neural): $100 per 1M characters<br>• 1M characters/month (standard) = $4 |
| 🔴 **Amazon Q** | [aws-q.md](modules/ml_and_ai/aws_Q/aws-q.md) | Per user/month | • **Q Business (Lite):** $3/user/month<br>• **Q Business (Pro):** $20/user/month<br>• **Q Developer (Pro):** $19/user/month<br>• 50 developers (Pro) = $950/month<br>• 100 business users (Pro) = $2,000/month |
| 🟡 **Rekognition** | [aws-rekognition.md](modules/ml_and_ai/aws_rekognition/aws-rekognition.md) | Per image/minute | • Image analysis: $0.001 per image (first 1M/month)<br>• Face detection: $0.001 per image<br>• Video analysis: $0.10 per minute<br>• 100K images = $100; 1,000 minutes video = $100 |
| 🟡 **SageMaker** | [aws-sagemaker.md](modules/ml_and_ai/aws_sageMaker-ai/aws-sagemaker.md) | Instance hours + storage | • **Training:** ml.m5.xlarge = $0.269/hour<br>• **Hosting:** ml.t3.medium = $0.065/hour = $47.45/month<br>• **Notebooks:** ml.t3.medium = $0.0582/hour = $42.48/month<br>• Studio storage: $0.023/GB/month<br>• 1 endpoint + 10 GB = $47.45 + $0.23 = $47.68/month |
| 🟡 **Textract** | [aws-textract.md](modules/ml_and_ai/aws_texttract/aws-textract.md) | Per page analyzed | • Text detection: $0.0015 per page<br>• Forms & tables: $0.065 per page (first 1M) → $0.020 after<br>• Signature detection: $0.065 per page<br>• 10K pages (forms): $650; 10K pages (text only): $15 |
| 🟡 **Transcribe** | [aws-transcribe.md](modules/ml_and_ai/aws_transcribe/aws-transcribe.md) | Per minute of audio | • Standard: $0.024/minute (first 250K minutes/month)<br>• Batch transcription: $0.0078/minute<br>• Medical: $0.075/minute<br>• 1,000 minutes/month (standard) = $24 |
| 🟡 **Translate** | [aws-translate.md](modules/ml_and_ai/aws_translate/aws-translate.md) | Per character translated | • Standard translation: $15.00 per 1M characters<br>• Custom terminology: Free (additional latency)<br>• Active Custom Translation: $60.00 per 1M characters<br>• 1M characters/month = $15 |

## Developer Tools

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **CodeCommit** | [aws-codecommit.md](modules/developer_tools/aws_codecommit/aws-codecommit.md) | Per active user | **Free Tier (Always Free):** 5 active users/month + 50 GB storage + 10,000 Git requests<br>• $1.00 per additional active user/month<br>• Storage: $0.06/GB/month (after 50 GB)<br>• 20 users = $15/month (15 billable users) |
| 🟡 **CodeBuild** | [aws-codebuild.md](modules/developer_tools/aws_codebuild/aws-codebuild.md) | Per build minute | **Free Tier (Always Free):** 100 build minutes/month (general1.small)<br>• general1.small: $0.005/minute<br>• general1.medium: $0.01/minute<br>• general1.large: $0.02/minute<br>• 1,000 builds × 5 min × medium = 5,000 min × $0.01 = $50/month |
| 🟢 **CodeDeploy** | [aws-codedeploy.md](modules/developer_tools/aws_codedeploy/aws-codedeploy.md) | Free for EC2/Lambda/ECS | • EC2/Lambda: Free<br>• On-premises: $0.02 per instance update |
| 🟡 **CodePipeline** | [aws-codepipeline.md](modules/developer_tools/aws_codepipeline/aws-codepipeline.md) | Per active pipeline | **Free Tier (Always Free):** 1 active pipeline/month<br>• $1.00 per active pipeline/month (after free tier)<br>• 10 pipelines = $9/month (1 free + 9 × $1) |
| 🟢 **Cloud9** | [aws-cloud9.md](modules/developer_tools/aws_cloud9/aws-cloud9.md) | No additional charge | • Free - pay for underlying EC2 instance<br>• t2.micro: $0.0116/hour = $8.47/month<br>• Auto-hibernation after 30 min saves costs |
| 🟢 **CloudShell** | [aws-cloudshell.md](modules/developer_tools/aws_cloudshell/aws-cloudshell.md) | Free | • Completely free<br>• 1 GB persistent storage per region included<br>• No charges for compute time |
| 🟡 **X-Ray** | [aws-x-ray.md](modules/developer_tools/aws_x-ray/aws-x-ray.md) | Per trace recorded/retrieved | **Free Tier (Always Free):** 100K traces recorded/month + 1M traces retrieved or scanned/month<br>• Traces recorded: $5.00 per million (after free tier)<br>• Traces retrieved/scanned: $0.50 per million<br>• 500K traces + 5M scans = $2.00 + $2.50 = $4.50/month |

## Management & Governance

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **CloudWatch** | [aws-cloudwatch.md](modules/monitoring/aws_cloudwatch/aws-cloudwatch.md) · [Module](modules/monitoring/aws_cloudwatch/README.md) | Metrics + logs + dashboards | **Free Tier (Always Free):** 10 custom metrics + 10 alarms + 5 GB logs + 3 dashboards + 1M API requests<br>• Standard metrics: Free (5-min intervals)<br>• Custom metrics: $0.30/metric/month (after 10)<br>• Logs ingestion: $0.50/GB (after 5 GB)<br>• Logs storage: $0.03/GB/month<br>• Dashboard: $3/month (after 3)<br>• 100 custom metrics + 100 GB logs = $27 + $47.50 = $74.50/month<br>• [CloudWatch Pricing](https://aws.amazon.com/cloudwatch/pricing/) |
| 🟡 **CloudTrail** | [aws-cloudtrail.md](modules/monitoring/aws_cloudtrail/aws-cloudtrail.md) · [Module](modules/monitoring/aws_cloudtrail/README.md) | Per event recorded | **Free Tier (Always Free):** First trail with management events delivered to S3<br>• Additional trail: $2.00 per 100,000 management events<br>• Data events: $0.10 per 100,000 events<br>• Insights: $0.35 per 100,000 write events analyzed<br>• CloudTrail Lake: 5-year event data store included (new accounts)<br>• [CloudTrail Pricing](https://aws.amazon.com/cloudtrail/pricing/) |
| 🟡 **Systems Manager** | [aws-systems-manager.md](modules/management_and_governance/aws_systems_manager/aws-systems-manager.md) | Feature-based | • Parameter Store: Standard free, Advanced $0.05/parameter/month<br>• Session Manager: Free<br>• Automation: $0.002 per step<br>• OpsCenter: $0.06 per OpsItem<br>• 1,000 automation steps = $2/month |
| 🟢 **CloudFormation** | [aws-cloudformation.md](modules/management_and_governance/aws_cloudFormation/aws-cloudformation.md) | Free | • No charges for CloudFormation itself<br>• Pay only for AWS resources created |
| 🔴 **Config** | [aws-config.md](modules/management_and_governance/aws_config/aws-config.md) | Per item + rules | • Configuration items: $0.003 per item recorded<br>• Rules: $0.001 per evaluation (first 100K), $0.0005 after<br>• 10,000 items + 5 rules × 20K evaluations = $30 + $100 = $130/month |
| 🟢 **Control Tower** | [aws-control-tower.md](modules/management_and_governance/aws_launch_wizard_control_tower/aws-control-tower.md) | Free | • Control Tower: Free — pay for underlying services<br>• Underlying: CloudTrail, Config, S3, SNS, CloudWatch<br>• Typical overhead: ~$10–$50/month per enrolled account |
| 🟢 **AWS Health** | [aws-health.md](modules/management_and_governance/aws_health/aws-health.md) | Free | • Personal Health Dashboard: Free for all accounts<br>• AWS Health API: Requires Business or Enterprise Support plan ($100+/month) |
| 🟢 **Launch Wizard** | [aws-launch-wizard.md](modules/management_and_governance/aws_launch_wizard_control_tower/aws-launch-wizard.md) | Free | • Launch Wizard: Free — pay for deployed AWS resources (EC2, EBS, EFS, etc.)<br>• Supports SAP, SQL Server, and Active Directory workloads |
| 🔴 **Managed Grafana** | [aws-managed-grafana.md](modules/management_and_governance/aws_managed_grafana/aws-managed-grafana.md) | Per active editor/month | • Standard workspace: $9/active editor/month<br>• Included: 5 viewer seats per editor<br>• Additional viewers: $1.50/viewer/month<br>• 10 editors + 60 viewers = $90 + $10 = $100/month |
| 🔴 **Managed Prometheus** | [aws-managed-prometheus.md](modules/management_and_governance/aws_managed_prometheus/aws-managed-prometheus.md) | Per sample ingested | • Metrics ingested: $0.90 per billion samples<br>• Metrics queried: $0.03 per billion samples<br>• Storage: $0.03/GB-month<br>• 100B samples ingested + 500 GB stored = $90 + $15 = $105/month |
| 🟢 **Organizations** | [aws-organizations.md](modules/management_and_governance/aws_organizations/aws-organizations.md) · [Module](modules/management_and_governance/aws_organizations/README.md) | Free | • No charge for AWS Organizations<br>• Consolidated billing: Free |
| 🟡 **OpsWorks** | [aws-opsworks.md](modules/management_and_governance/aws_opsWorks/aws-opsworks.md) | Per managed instance-hour | • $0.03/instance-hour for OpsWorks-managed instances<br>• 10 instances × 730 hours = $219/month<br>• Pay additionally for underlying EC2, EBS resources |
| 🟢 **Proton** | [aws-proton.md](modules/management_and_governance/aws_proton/aws-proton.md) | Free | • Proton: Free — pay for underlying AWS resources in deployed environments<br>• Templates stored in S3: Standard S3 pricing |
| 🟢 **Service Catalog** | [aws-service-catalog.md](modules/management_and_governance/aws_service_catalog_systems_manager_trusted_advisor/aws-service-catalog.md) | Free | • Service Catalog: Free<br>• Pay for AWS resources launched in products |
| 🟢 **Trusted Advisor** | [aws-trusted-advisor.md](modules/management_and_governance/aws_service_catalog_systems_manager_trusted_advisor/aws-trusted-advisor.md) | Free (basic) | • Basic/Developer checks: Free (7 core checks)<br>• Full 115+ checks: Requires Business support ($100+/month)<br>• API access: Business or Enterprise support required |
| 🟢 **User Notifications** | [aws-user-notifications.md](modules/management_and_governance/aws_user_notifications/aws-user-notifications.md) | Free | • AWS User Notifications: Free<br>• Pay for underlying notification delivery (SNS, SES, etc.) |

## Migration & Transfer

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🔴 **DMS** | [aws-database-migration.md](modules/storage/aws_database_migration/aws-database-migration.md) | Instance hours + storage | • dms.t3.medium: $0.073/hour = $53.29/month<br>• dms.c5.2xlarge: $0.6528/hour = $476.54/month<br>• Replication storage: $0.115/GB/month<br>• Single-AZ medium + 50 GB = $53.29 + $5.75 = $59.04/month |
| 🟡 **DataSync** | [aws-datasync.md](modules/storage/aws_datasync/aws-datasync.md) | Per GB transferred | • Data copied: $0.0125/GB<br>• 10 TB transfer = $128<br>• Includes network acceleration and data validation |
| 🔴 **Application Migration (MGN)** | [aws-migration.md](modules/management_and_governance/aws_migration/aws-migration.md) | Per replicated server | • Replication: $0.042/hour per replicated server<br>• Test/cutover instances: Standard EC2 pricing<br>• No charge for the service itself during replication<br>• Example: 10 servers replicated for 30 days = $0.042 × 10 × 720 = $302.40 |
| 🔴 **Snow Family** | [aws-snow-family.md](modules/storage/aws_snow_family/aws-snow-family.md) | Device rental + shipping | • **Snowball Edge Storage:** $300 first 10 days, $30/day after<br>• **Snowcone:** $200 first 5 days, $30/day after<br>• Shipping: Included (US)<br>• 30-day project: $300 + (20 × $30) = $900 |
| 🔴 **Transfer Family** | [aws-transfer-family.md](modules/storage/aws_transfer_family/aws-transfer-family.md) | Protocol-hour + GB transferred | • Protocol enabled: $0.30/hour per protocol<br>• Data uploaded: $0.04/GB; Data downloaded: $0.04/GB<br>• SFTP + FTPS server (730 hrs each) + 500 GB in + 100 GB out = $438 + $20 + $4 = $462/month<br>• Cost tip: Disable test/dev servers outside business hours |

## Additional Services

| Service | Documentation | Pricing Model | Cost Examples |
|---------|--------------|---------------|---------------|
| 🟡 **API Gateway** | [aws-api-gateway.md](modules/networking_content_delivery/aws_api_gateway/aws-api-gateway.md) | Per million requests | **Free Tier (12 months):** 1M REST API calls/month<br>• REST API: $3.50 per million requests (after free tier)<br>• HTTP API: $1.00 per million requests<br>• WebSocket: $1.00 per million messages + $0.25 per million connection minutes<br>• 10M REST calls = $31.50/month (9M billable)<br>• Caching: $0.02/hour per GB |
| 🟡 **AppSync** | [aws-appsync.md](modules/frontend_web_and_mobile_devices/aws_appSync/aws-appsync.md) | Query + real-time updates | • Query/mutation: $4.00 per million<br>• Real-time updates: $2.00 per million<br>• 5M queries + 10M updates = $20 + $20 = $40/month |
| 🔴 **Cognito** | [aws-cognito.md](modules/security_identity_compliance/aws_cognito/aws-cognito.md) | Per MAU (Monthly Active User) | **Free Tier (Always Free):** 50,000 MAUs/month<br>• 50,001-100,000: $0.0055/MAU<br>• 100,001-1,000,000: $0.0046/MAU<br>• 500K MAUs = Free (50K) + $275 + $1,840 = $2,115/month |
| 🟡 **Backup** | [aws-backup.md](modules/storage/aws_backup/aws-backup.md) · [Module](modules/storage/aws_backup/README.md) · [Wrapper](tf-plans/aws_backup/README.md) | Storage + restore | • Warm backup: $0.05/GB/month<br>• Cold backup: $0.01/GB/month<br>• Restore: $0.02/GB<br>• 1 TB warm + monthly 100 GB restore = $51.20 + $2 = $53.20/month |
| 🟡 **Secrets Manager** | [aws-secrets-manager.md](modules/security_identity_compliance/aws_secrets_manager/aws-secrets-manager.md) · [Module](modules/security_identity_compliance/aws_secrets_manager/README.md) | Per secret per month + API calls | **Free Tier:** None<br>• $0.40 per secret per month<br>• $0.05 per 10,000 API calls<br>• 10 secrets = $4/month<br>• 10 secrets + 1M API calls = $4 + $5 = $9/month<br>• Rotation enabled: uses Lambda invocations (Lambda pricing applies)<br>• Multi-region replica: $0.40 per replica per month<br>• [Secrets Manager Pricing](https://aws.amazon.com/secrets-manager/pricing/) |
| 🔴 **Shield Advanced** | [aws-shield.md](modules/security_identity_compliance/aws_shield/aws-shield.md) · [Module](modules/security_identity_compliance/aws_shield/README.md) | Subscription + data transfer | **Free Tier:** None<br>• $3,000/month subscription (billed annually = $36,000/year)<br>• Data transfer: $0.025/GB for protected resource traffic<br>• Includes 24/7 DRT access, attack forensics reports, cost protection for scaling spikes<br>• Proactive engagement: included with subscription<br>• 1-year minimum commitment; auto-renews unless disabled<br>• [Shield Pricing](https://aws.amazon.com/shield/pricing/) |
| � **GuardDuty** | [aws-guardduty.md](modules/security_identity_compliance/aws_guardDuty/aws-guardduty.md) · [Module](modules/security_identity_compliance/aws_guardDuty/README.md) · [Wrapper](tf-plans/aws_guardduty/README.md) | Per event volume (CloudTrail/VPC/DNS/S3) | **Free Tier (Always Free):** 30-day free trial per new detector<br>• CloudTrail events: $4.00/1M (first 500M/month), $2.00/1M after<br>• VPC Flow Logs: $1.00/GB (first 500 GB/month), $0.50/GB after<br>• DNS logs: $1.00/1M events (first 1B), $0.50/1M after<br>• S3 data events: $1.00/1M events (when S3_DATA_EVENTS enabled)<br>• Typical small account: $30–$80/month; large multi-service: $200+/month<br>• [GuardDuty Pricing](https://aws.amazon.com/guardduty/pricing/) |
| �🟢 **Budgets** | [aws-budget.md](modules/cloud_financial_management/aws_budget/aws-budget.md) · [Module](modules/cloud_financial_management/aws_budget/README.md) | Per budget per month | **Free Tier (Always Free):** First 2 budgets/account free<br>• $0.10 per additional budget per month<br>• $0.10 per budget action per month<br>• 10 budgets = (8 × $0.10) = $0.80/month<br>• 10 budgets + 5 actions = $0.80 + $0.50 = $1.30/month<br>• [Budgets Pricing](https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/) |
| 🟢 **Savings Plans** | [aws-savings-plan.md](modules/cloud_financial_management/aws_savings_plan/aws-savings-plan.md) | Hourly commitment (1- or 3-year) | **Free Tier:** No charge for the commitment itself — pay only the committed hourly rate<br>• **Compute SP (1yr, No Upfront):** ~40–66% savings vs On-Demand; covers EC2, Fargate, Lambda (any region/family)<br>• **EC2 Instance SP (1yr, All Upfront):** up to 72% savings; region + family locked<br>• **SageMaker SP (1yr, No Upfront):** ~35–64% savings on ML instances<br>• **3-year plans:** ~15% deeper discount than equivalent 1-year<br>• [Savings Plans Pricing](https://aws.amazon.com/savingsplans/pricing/) |

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
- **App Runner Pricing:** https://aws.amazon.com/apprunner/pricing/
- **Auto Scaling:** https://aws.amazon.com/autoscaling/pricing/
- **AWS Batch:** https://aws.amazon.com/batch/pricing/
- **ECR Pricing:** https://aws.amazon.com/ecr/pricing/
- **ECS Pricing:** https://aws.amazon.com/ecs/pricing/
- **EKS Pricing:** https://aws.amazon.com/eks/pricing/
- **Elastic Beanstalk:** https://aws.amazon.com/elasticbeanstalk/pricing/
- **ELB Pricing:** https://aws.amazon.com/elasticloadbalancing/pricing/
- **Fargate Pricing:** https://aws.amazon.com/fargate/pricing/
- **Image Builder:** https://aws.amazon.com/image-builder/pricing/
- **Lambda Pricing:** https://aws.amazon.com/lambda/pricing/
- **Lightsail Pricing:** https://aws.amazon.com/lightsail/pricing/

### Storage Service Pricing
- **S3 Pricing:** https://aws.amazon.com/s3/pricing/
- **EBS Pricing:** https://aws.amazon.com/ebs/pricing/
- **EFS Pricing:** https://aws.amazon.com/efs/pricing/
- **FSx Pricing:** https://aws.amazon.com/fsx/pricing/
- **Storage Gateway:** https://aws.amazon.com/storagegateway/pricing/

### Database Service Pricing
- **RDS Pricing:** https://aws.amazon.com/rds/pricing/
- **RDS MySQL Pricing:** https://aws.amazon.com/rds/mysql/pricing/
- **RDS PostgreSQL Pricing:** https://aws.amazon.com/rds/postgresql/pricing/
- **RDS MariaDB Pricing:** https://aws.amazon.com/rds/mariadb/pricing/
- **RDS Oracle Pricing:** https://aws.amazon.com/rds/oracle/pricing/
- **RDS SQL Server Pricing:** https://aws.amazon.com/rds/sqlserver/pricing/
- **Aurora Pricing:** https://aws.amazon.com/rds/aurora/pricing/
- **DynamoDB Pricing:** https://aws.amazon.com/dynamodb/pricing/
- **ElastiCache Pricing:** https://aws.amazon.com/elasticache/pricing/
- **DocumentDB Pricing:** https://aws.amazon.com/documentdb/pricing/
- **Redshift Pricing:** https://aws.amazon.com/redshift/pricing/

### Networking & Content Delivery Pricing
- **VPC Pricing:** https://aws.amazon.com/vpc/pricing/
- **App Mesh:** https://aws.amazon.com/app-mesh/pricing/
- **Cloud Map Pricing:** https://aws.amazon.com/cloud-map/pricing/
- **CloudFront Pricing:** https://aws.amazon.com/cloudfront/pricing/
- **Elastic Load Balancing:** https://aws.amazon.com/elasticloadbalancing/pricing/
- **Global Accelerator:** https://aws.amazon.com/global-accelerator/pricing/
- **PrivateLink Pricing:** https://aws.amazon.com/privatelink/pricing/
- **Route 53 Pricing:** https://aws.amazon.com/route53/pricing/
- **Transit Gateway:** https://aws.amazon.com/transit-gateway/pricing/
- **VPC Lattice Pricing:** https://aws.amazon.com/vpc/lattice/pricing/

### Security, Identity & Compliance Pricing
- **Artifact:** https://aws.amazon.com/artifact/ (Free)
- **Audit Manager:** https://aws.amazon.com/audit-manager/pricing/
- **Certificate Manager:** https://aws.amazon.com/certificate-manager/pricing/
- **CloudHSM Pricing:** https://aws.amazon.com/cloudhsm/pricing/
- **Detective Pricing:** https://aws.amazon.com/detective/pricing/
- **Directory Service:** https://aws.amazon.com/directoryservice/pricing/
- **Firewall Manager:** https://aws.amazon.com/firewall-manager/pricing/
- **GuardDuty Pricing:** https://aws.amazon.com/guardduty/pricing/
- **IAM:** https://aws.amazon.com/iam/ (Free)
- **Inspector Pricing:** https://aws.amazon.com/inspector/pricing/
- **KMS Pricing:** https://aws.amazon.com/kms/pricing/
- **Macie Pricing:** https://aws.amazon.com/macie/pricing/
- **Network Firewall:** https://aws.amazon.com/network-firewall/pricing/
- **RAM:** https://aws.amazon.com/ram/ (Free)
- **Secrets Manager:** https://aws.amazon.com/secrets-manager/pricing/
- **Security Hub:** https://aws.amazon.com/security-hub/pricing/
- **Security Lake:** https://aws.amazon.com/security-lake/pricing/
- **Shield Pricing:** https://aws.amazon.com/shield/pricing/
- **Verified Permissions:** https://aws.amazon.com/verified-permissions/pricing/
- **WAF Pricing:** https://aws.amazon.com/waf/pricing/

### Application Integration Pricing
- **SQS Pricing:** https://aws.amazon.com/sqs/pricing/
- **SNS Pricing:** https://aws.amazon.com/sns/pricing/
- **EventBridge Pricing:** https://aws.amazon.com/eventbridge/pricing/
- **Step Functions:** https://aws.amazon.com/step-functions/pricing/
- **Amazon MQ:** https://aws.amazon.com/amazon-mq/pricing/

### Analytics Service Pricing
- **Athena Pricing:** https://aws.amazon.com/athena/pricing/
- **EMR Pricing:** https://aws.amazon.com/emr/pricing/
- **Glue Pricing:** https://aws.amazon.com/glue/pricing/
- **Kinesis Pricing:** https://aws.amazon.com/kinesis/pricing/
- **Lake Formation Pricing:** https://aws.amazon.com/lake-formation/pricing/
- **MSK Pricing:** https://aws.amazon.com/msk/pricing/
- **OpenSearch Service Pricing:** https://aws.amazon.com/opensearch-service/pricing/
- **QuickSight Pricing:** https://aws.amazon.com/quicksight/pricing/
- **Redshift Pricing:** https://aws.amazon.com/redshift/pricing/

### Machine Learning & AI Pricing
- **Augmented AI (A2I):** https://aws.amazon.com/augmented-ai/pricing/
- **Bedrock Pricing:** https://aws.amazon.com/bedrock/pricing/
- **CodeGuru Pricing:** https://aws.amazon.com/codeguru/pricing/
- **Comprehend Pricing:** https://aws.amazon.com/comprehend/pricing/
- **Comprehend Medical:** https://aws.amazon.com/comprehend/medical/pricing/
- **DeepComposer Pricing:** https://aws.amazon.com/deepcomposer/pricing/
- **DeepRacer Pricing:** https://aws.amazon.com/deepracer/pricing/
- **DevOps Guru Pricing:** https://aws.amazon.com/devops-guru/pricing/
- **Forecast Pricing:** https://aws.amazon.com/forecast/pricing/
- **Fraud Detector Pricing:** https://aws.amazon.com/fraud-detector/pricing/
- **HealthLake Pricing:** https://aws.amazon.com/healthlake/pricing/
- **HealthScribe Pricing:** https://aws.amazon.com/healthscribe/pricing/
- **Kendra Pricing:** https://aws.amazon.com/kendra/pricing/
- **Lex Pricing:** https://aws.amazon.com/lex/pricing/
- **Lookout for Equipment:** https://aws.amazon.com/lookout-for-equipment/pricing/
- **Lookout for Metrics:** https://aws.amazon.com/lookout-for-metrics/pricing/
- **Lookout for Vision:** https://aws.amazon.com/lookout-for-vision/pricing/
- **Monitron Pricing:** https://aws.amazon.com/monitron/pricing/
- **Panorama Pricing:** https://aws.amazon.com/panorama/pricing/
- **Personalize Pricing:** https://aws.amazon.com/personalize/pricing/
- **Polly Pricing:** https://aws.amazon.com/polly/pricing/
- **Amazon Q Pricing:** https://aws.amazon.com/q/pricing/
- **Rekognition Pricing:** https://aws.amazon.com/rekognition/pricing/
- **SageMaker Pricing:** https://aws.amazon.com/sagemaker/pricing/
- **Textract Pricing:** https://aws.amazon.com/textract/pricing/
- **Transcribe Pricing:** https://aws.amazon.com/transcribe/pricing/
- **Translate Pricing:** https://aws.amazon.com/translate/pricing/

### Developer Tools Pricing
- **Cloud9 Pricing:** https://aws.amazon.com/cloud9/pricing/
- **CloudShell:** https://aws.amazon.com/cloudshell/ (Free)
- **CodeBuild Pricing:** https://aws.amazon.com/codebuild/pricing/
- **CodeCommit Pricing:** https://aws.amazon.com/codecommit/pricing/
- **CodeDeploy Pricing:** https://aws.amazon.com/codedeploy/pricing/
- **CodePipeline Pricing:** https://aws.amazon.com/codepipeline/pricing/
- **X-Ray Pricing:** https://aws.amazon.com/xray/pricing/

### Management & Governance Pricing
- **CloudFormation:** https://aws.amazon.com/cloudformation/pricing/
- **CloudTrail Pricing:** https://aws.amazon.com/cloudtrail/pricing/
- **CloudWatch Pricing:** https://aws.amazon.com/cloudwatch/pricing/
- **Config Pricing:** https://aws.amazon.com/config/pricing/
- **Control Tower:** https://aws.amazon.com/controltower/pricing/
- **AWS Health:** https://aws.amazon.com/premiumsupport/technology/personal-health-dashboard/
- **Managed Grafana:** https://aws.amazon.com/grafana/pricing/
- **Managed Prometheus:** https://aws.amazon.com/prometheus/pricing/
- **OpsWorks Pricing:** https://aws.amazon.com/opsworks/pricing/
- **Organizations:** https://aws.amazon.com/organizations/pricing/
- **Proton Pricing:** https://aws.amazon.com/proton/pricing/
- **Service Catalog:** https://aws.amazon.com/servicecatalog/pricing/
- **Systems Manager:** https://aws.amazon.com/systems-manager/pricing/
- **Trusted Advisor:** https://aws.amazon.com/premiumsupport/technology/trusted-advisor/
- **User Notifications:** https://aws.amazon.com/notifications/pricing/

### Migration & Transfer Pricing
- **Application Migration Service (MGN):** https://aws.amazon.com/application-migration-service/pricing/
- **DMS Pricing:** https://aws.amazon.com/dms/pricing/
- **DataSync Pricing:** https://aws.amazon.com/datasync/pricing/
- **Snow Family:** https://aws.amazon.com/snow/pricing/
- **Transfer Family Pricing:** https://aws.amazon.com/aws-transfer-family/pricing/

### Additional Services Pricing
- **API Gateway:** https://aws.amazon.com/api-gateway/pricing/
- **AppSync Pricing:** https://aws.amazon.com/appsync/pricing/
- **Cognito Pricing:** https://aws.amazon.com/cognito/pricing/
- **AWS Backup:** https://aws.amazon.com/backup/pricing/
- **Savings Plans Pricing:** https://aws.amazon.com/savingsplans/pricing/

### Additional Documentation
- **AWS Well-Architected Framework - Cost Optimization:** https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/
- **AWS Cost Management:** https://aws.amazon.com/aws-cost-management/
- **AWS Cost Explorer:** https://aws.amazon.com/aws-cost-management/aws-cost-explorer/
- **AWS Budgets:** https://aws.amazon.com/aws-cost-management/aws-budgets/
- **AWS Budgets Pricing:** https://aws.amazon.com/aws-cost-management/aws-budgets/pricing/
- **AWS Savings Plans:** https://aws.amazon.com/savingsplans/
- **Savings Plans FAQ:** https://aws.amazon.com/savingsplans/faq/
- **AWS Trusted Advisor:** https://aws.amazon.com/premiumsupport/technology/trusted-advisor/
- **AWS Compute Optimizer:** https://aws.amazon.com/compute-optimizer/

---

**Last Updated:** March 24, 2026  
**Pricing Region:** US East (N. Virginia) unless otherwise specified  
**Disclaimer:** All pricing is subject to change. Always verify current pricing using the official AWS sources listed above before making purchasing decisions.
