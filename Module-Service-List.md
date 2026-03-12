# AWS Module & Service List

Complete list of all Terraform modules and wrapper plans available in this repository, organised by AWS service category.

> Back to [README](README.md)

---

## Modules

| AWS Service Type | Module Name | Documentation Link | Resource Guide | Terraform |
|------------------|-------------|-------------------|----------------|-----------|
| **Compute** | | | | |
| Compute | ALB | [ALB Module](modules/compute/aws_elb/aws_alb/README.md) | [ELB Overview](modules/compute/aws_elb/aws-elb.md) | ✅ [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| Compute | ASG | [ASG Module](modules/compute/aws_EC2s/aws_auto_scaling_grp/README.md) | [ASG Overview](modules/compute/aws_EC2s/aws_auto_scaling_grp/aws-auto-scaling-grp.md) | ✅ [aws_autoscaling_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) |
| Compute | Batch | [Batch Module](modules/compute/aws_containers/aws_batch/README.md) | - | ✅ [aws_batch_compute_environment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/batch_compute_environment) |
| Compute | EC2 | [EC2 Module](modules/compute/aws_ec2/README.md) | [EC2 Overview](modules/compute/aws_EC2s/aws_ec2/aws-ec2.md) | ✅ [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) |
| Compute | GWLB | [GWLB Module](modules/compute/aws_elb/aws_glb/README.md) | [ELB Overview](modules/compute/aws_elb/aws-elb.md) | ✅ [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| Compute | Lambda | [Lambda Module](modules/compute/aws_lambda/README.md) | [Lambda Overview](modules/compute/aws_serverless/aws_lambda/aws-lambda.md) | ✅ [aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) |
| Compute | NLB | [NLB Module](modules/compute/aws_elb/aws_nlb/README.md) | [ELB Overview](modules/compute/aws_elb/aws-elb.md) | ✅ [aws_lb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) |
| **Networking/CDN** | | | | |
| Networking/CDN | API Gateway | [API Gateway Module](modules/networking_content_delivery/aws_api_gateway/README.md) | [API Gateway Overview](modules/networking_content_delivery/aws_api_gateway/aws-api-gateway.md) | ✅ [aws_apigatewayv2_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) |
| Networking/CDN | CloudFront | [CloudFront Module](modules/networking_content_delivery/aws_cloudFront/README.md) | [CloudFront Overview](modules/networking_content_delivery/aws_cloudFront/aws-cloudfront.md) | ✅ [aws_cloudfront_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) |
| Networking/CDN | Internet Gateway | [Internet Gateway Module](modules/networking_content_delivery/aws_internet_gateway/README.md) | [Internet Gateway Overview](modules/networking_content_delivery/aws_internet_gateway/aws-internet-gateway.md) | ✅ [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) |
| Networking/CDN | Route 53 | [Route 53 Module](modules/networking_content_delivery/aws_route_53/README.md) | [Route 53 Overview](modules/networking_content_delivery/aws_route_53/aws-route-53.md) | ✅ [aws_route53_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) |
| Networking/CDN | Route Table | [Route Table Module](modules/networking_content_delivery/aws_route_table/README.md) | [Route Table Overview](modules/networking_content_delivery/aws_route_table/aws-route-table.md) | ✅ [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) |
| Networking/CDN | VPC | [VPC Module](modules/networking_content_delivery/aws_vpc/README.md) | [VPC Overview](modules/networking_content_delivery/aws_vpc/aws-vpc.md) | ✅ [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) |
| **Application Integration** | | | | |
| Application Integration | MQ | [MQ Module](modules/application_integration/aws_mq/README.md) | [MQ Overview](modules/application_integration/aws_mq/aws-mq.md) | ✅ [aws_mq_broker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mq_broker) |
| Application Integration | SNS | [SNS Module](modules/application_integration/aws_sns/README.md) | [SNS Overview](modules/application_integration/aws_sns/aws-sns.md) | ✅ [aws_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) |
| Application Integration | SQS | [SQS Module](modules/application_integration/aws_sqs/README.md) | [SQS Overview](modules/application_integration/aws_sqs/aws-sqs.md) | ✅ [aws_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) |
| Application Integration | Step Functions | [Step Functions Module](modules/application_integration/aws_step_function/README.md) | - | ✅ [aws_sfn_state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) |
| **Analytics** | | | | |
| Analytics | Athena | - | [Athena Overview](modules/analytics/aws_athena/aws-athena.md) | ✅ [aws_athena_workgroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) |
| Analytics | EMR (MapReduce) | - | [EMR Overview](modules/analytics/aws_mapreduce/aws-emr.md) | ✅ [aws_emr_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emr_cluster) |
| Analytics | Kinesis | [Kinesis Module](modules/analytics/aws_kinesis/README.md) | [Kinesis Overview](modules/analytics/aws_kinesis/aws-kinesis.md) | ✅ [aws_kinesis_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) |
| Analytics | Lake Formation | - | [Lake Formation Overview](modules/storage/aws_lake_formation/aws-lake-formation.md) | ✅ [aws_lakeformation_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_resource) |
| Analytics | MSK | [MSK Module](modules/analytics/aws-msk/README.md) | [MSK Overview](modules/analytics/aws-msk/aws-msk.md) | ✅ [aws_msk_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster) |
| Analytics | OpenSearch Service | - | [OpenSearch Overview](modules/analytics/aws_opensearch_service/aws-opensearch.md) | ✅ [aws_opensearch_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) |
| Analytics | QuickSight | - | [QuickSight Overview](modules/analytics/aws_quicksight/aws-quicksight.md) | ✅ [aws_quicksight_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_data_source) |
| Analytics | Redshift | - | [Redshift Overview](modules/analytics/aws_redshift/aws-redshift.md) | ✅ [aws_redshift_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/redshift_cluster) |
| **Databases** | | | | |
| Databases | Aurora | [Aurora Module](modules/databases/relational/aws_aurora/README.md) | [Aurora Overview](modules/databases/relational/aws_aurora/aws-aurora.md) | ✅ [aws_rds_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) |
| Databases | DocumentDB | [DocumentDB Module](modules/databases/non-relational/aws_documentdb/README.md) | [DocumentDB Overview](modules/databases/non-relational/aws_documentdb/aws-documentdb.md) | ✅ [aws_docdb_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/docdb_cluster) |
| Databases | DynamoDB | [DynamoDB Module](modules/databases/non-relational/aws_dynamodb/README.md) | [DynamoDB Overview](modules/databases/non-relational/aws_dynamodb/aws-dynamodb.md) | ✅ [aws_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) |
| Databases | ElastiCache | [ElastiCache Module](modules/databases/non-relational/aws_elasticache/README.md) | - | ✅ [aws_elasticache_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) |
| Databases | RDS | [RDS Module](modules/databases/relational/aws_rds/README.md) | [RDS Overview](modules/databases/relational/aws_rds/aws-rds.md) | ✅ [aws_db_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) |
| **Storage** | | | | |
| Storage | Backup | - | [Backup Overview](modules/storage/aws_backup/aws-backup.md) | ✅ [aws_backup_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan) |
| Storage | S3 | [S3 Module](modules/storage/aws_s3/README.md) | [S3 Overview](modules/storage/aws_s3/aws-s3.md) | ✅ [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) |
| Storage | Snow Family | - | [Snow Family Overview](modules/storage/aws_snow_family/aws-snow-family.md) | Physical device — order via Console or CLI: `aws snowball create-job` |
| Storage | Storage Gateway | - | [Storage Gateway Overview](modules/storage/aws-storage-gateway/aws-storage-gateway.md) | ✅ [aws_storagegateway_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/storagegateway_gateway) |
| **Security** | | | | |
| Security | IAM | [IAM Module](modules/security_identity_compliance/aws_iam/README.md) | [IAM Overview](modules/security_identity_compliance/aws_iam/aws-iam.md) | ✅ [aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) |
| Security | KMS | [KMS Module](modules/security_identity_compliance/aws_kms/README.md) | [KMS Overview](modules/security_identity_compliance/aws_kms/aws-kms.md) | ✅ [aws_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) |
| Security | Security Group | [Security Group Module](modules/security_identity_compliance/aws_security_group/README.md) | [Security Groups Overview](modules/security_identity_compliance/aws_security_group/aws-security-groups.md) | ✅ [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) |
| **Migration & Transfer** | | | | |
| Migration & Transfer | DataSync | - | [DataSync Overview](modules/storage/aws_datasync/aws-datasync.md) | ✅ [aws_datasync_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/datasync_task) |
| Migration & Transfer | Database Migration (DMS) | - | [DMS Overview](modules/storage/aws_database_migration/aws-database-migration.md) | ✅ [aws_dms_replication_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dms_replication_instance) |
| Migration & Transfer | Transfer Family | - | [Transfer Family Overview](modules/storage/aws_transfer_family/aws-transfer-family.md) | ✅ [aws_transfer_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/transfer_server) |
| **Management & Governance** | | | | |
| Management & Governance | Application Migration (MGN) | - | [Migration Overview](modules/management_and_governance/aws_migration/aws-migration.md) | ✅ [aws_mgn](https://docs.aws.amazon.com/mgn/latest/ug/what-is-application-migration-service.html) |
| Management & Governance | Server Migration — 6 R's | - | [6 R's Strategy](modules/management_and_governance/aws_migration/aws-migration.md#the-6-rs-of-aws-migration-strategy) | — Architectural strategy guide |

> Each module directory contains its own README file with usage instructions, input/output variables, and examples.

---

## Wrappers (Examples)

Wrapper plans are available under `tf-plans/` to demonstrate usage with sensible defaults and example `terraform.tfvars` files.

| Wrapper | Module | Description |
|---------|--------|-------------|
| [tf-plans/aws_alb](tf-plans/aws_alb/README.md) | ALB | Application Load Balancer; multi-ALB via `albs` |
| [tf-plans/aws_api_gateway](tf-plans/aws_api_gateway/README.md) | API Gateway | HTTP/WebSocket APIs; integrations, routes, stages |
| [tf-plans/aws_asg](tf-plans/aws_asg/README.md) | ASG | Auto Scaling Groups; multi-ASG via `asgs`; hooks & policies |
| [tf-plans/aws_aurora](tf-plans/aws_aurora/README.md) | Aurora | Aurora MySQL/PostgreSQL; provisioned, Serverless v1/v2, global databases; auto-scaling |
| [tf-plans/aws_batch](tf-plans/aws_batch/README.md) | Batch | Compute environments, job queues, job definitions; EC2/SPOT/FARGATE support |
| [tf-plans/aws_cloudfront](tf-plans/aws_cloudfront/README.md) | CloudFront | CDN distributions; S3/custom origins; cache behaviors; SSL/TLS certificates |
| [tf-plans/aws_documentdb](tf-plans/aws_documentdb/README.md) | DocumentDB | MongoDB-compatible clusters; multi-node HA; I/O-Optimized storage; custom parameter groups; CloudWatch log exports |
| [tf-plans/aws_dynamodb](tf-plans/aws_dynamodb/README.md) | DynamoDB | NoSQL tables; on-demand/provisioned billing; GSI/LSI; streams, TTL, global tables |
| [tf-plans/aws_ec2](tf-plans/aws_ec2/README.md) | EC2 | Instances; AMIs, EBS, networking examples |
| [tf-plans/aws_elasticache](tf-plans/aws_elasticache/README.md) | ElastiCache | Redis/Memcached/Valkey clusters; replication groups; HA, cluster mode, encryption |
| [tf-plans/aws_glb](tf-plans/aws_glb/README.md) | GWLB | Gateway Load Balancer; multi-GLB via `glbs` |
| [tf-plans/aws_iam](tf-plans/aws_iam/README.md) | IAM | Users, groups, policies; access keys & console options |
| [tf-plans/aws_internet_gateway](tf-plans/aws_internet_gateway/README.md) | Internet Gateway | IGW attach examples; route integration |
| [tf-plans/aws_kinesis](tf-plans/aws_kinesis/README.md) | Kinesis | Data streams; shards, retention, encryption |
| [tf-plans/aws_kms](tf-plans/aws_kms/README.md) | KMS | Keys, aliases, grants; rotation options |
| [tf-plans/aws_lambda](tf-plans/aws_lambda/README.md) | Lambda | Functions; Zip/Image; VPC/IAM integrations |
| [tf-plans/aws_mq](tf-plans/aws_mq/README.md) | MQ | Message brokers; ActiveMQ/RabbitMQ |
| [tf-plans/aws_msk](tf-plans/aws_msk/README.md) | MSK | Managed Kafka clusters; configurations |
| [tf-plans/aws_nlb](tf-plans/aws_nlb/README.md) | NLB | Network Load Balancer; multi-NLB via `nlbs`; cross-zone option |
| [tf-plans/aws_rds](tf-plans/aws_rds/README.md) | RDS | Relational databases; MySQL/PostgreSQL/MariaDB/Oracle/SQL Server; Multi-AZ, read replicas, autoscaling |
| [tf-plans/aws_route_53](tf-plans/aws_route_53/README.md) | Route 53 | Zones & records; alias examples |
| [tf-plans/aws_route_table](tf-plans/aws_route_table/README.md) | Route Table | Routes, associations; VPC/Subnet wiring |
| [tf-plans/aws_s3](tf-plans/aws_s3/README.md) | S3 | Buckets; SSE-KMS/SSE-S3 options; logging examples |
| [tf-plans/aws_sec_grp](tf-plans/aws_sec_grp/README.md) | Security Group | Security rules; ingress/egress configurations |
| [tf-plans/aws_sns](tf-plans/aws_sns/README.md) | SNS | Topics; subscriptions; message publishing |
| [tf-plans/aws_sqs](tf-plans/aws_sqs/README.md) | SQS | Queues; FIFO/standard; DLQ support |
| [tf-plans/aws_step_function](tf-plans/aws_step_function/README.md) | Step Functions | State machines; STANDARD/EXPRESS types; logging, tracing, encryption |
| [tf-plans/aws_vpc](tf-plans/aws_vpc/README.md) | VPC | Virtual networks; subnets, CIDR blocks |

> All modules consistently tag resources with a `CreatedDate` sourced from a one-time timestamp via the `time_static` provider.  
> Modules that support multi-resource creation (e.g., ALB via `albs`, NLB via `nlbs`, GWLB via `glbs`, ASG via `asgs`) expose outputs as maps keyed by the resource key.
