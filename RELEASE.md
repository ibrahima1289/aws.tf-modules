# Release Notes

## Repository Updates (2026-03-11)
- Docs: Comprehensive [AWS Migration guide](modules/management_and_governance/aws_migration/aws-migration.md) written covering AWS Application Migration Service (MGN) and the deprecated AWS Server Migration Service (SMS).
- Docs: Full explanation of the **6 R's of AWS Migration Strategy** (Rehost, Replatform, Repurchase, Refactor, Retire, Retain) — each R includes use cases, recommended tooling, outcomes, benefits, and trade-offs.
- Docs: Supporting sections cover AWS Migration Hub, AWS Application Discovery Service (agentless & agent-based), and AWS Database Migration Service (DMS) with a full source-to-target matrix.
- Docs: Reference architecture diagram, migration best practices checklist, and effort/value comparison table included.
- Docs: Root README updated — repository structure tree expanded to show all module categories; Management & Governance section added to the modules table with links to the migration guide and 6 R's strategy anchor.

## Repository Updates (2026-03-07)
- Docs: Service documentation written for 7 AWS storage and migration services: [Snow Family](modules/storage/aws_snow_family/aws-snow-family.md), [Backup](modules/storage/aws_backup/aws-backup.md), [DataSync](modules/storage/aws_datasync/aws-datasync.md), [Database Migration (DMS)](modules/storage/aws_database_migration/aws-database-migration.md), [Lake Formation](modules/storage/aws_lake_formation/aws-lake-formation.md), [Transfer Family](modules/storage/aws_transfer_family/aws-transfer-family.md), and [Storage Gateway](modules/storage/aws-storage-gateway/aws-storage-gateway.md).
- Docs: Each guide covers core concepts, key components with architecture diagrams, security model, monitoring, pricing, real-world use cases, and decision guidance (when to use vs. alternatives).
- Docs: Root README updated with documentation links for all 7 services across Storage, Analytics, and Migration & Transfer sections; pricing guide paths corrected to match actual file locations and two missing services (Transfer Family, Lake Formation) added to the pricing table.

## Repository Updates (2026-03-05)
- New: [DocumentDB module](modules/databases/non-relational/aws_documentdb/README.md) and [wrapper](tf-plans/aws_documentdb/README.md) added — supports MongoDB-compatible clusters with configurable instance counts (`instance_count`) for single-node and multi-node HA deployments; includes subnet groups, optional custom parameter groups, I/O-Optimized storage (`iopt1`), KMS encryption at rest, automated backups with point-in-time recovery, snapshot restore, and CloudWatch log exports (`audit`, `profiler`).
- Docs: Comprehensive READMEs with architecture diagram, full variable tables for all cluster settings (engine, compute, networking, storage, backup, parameter group, and operational options); wrapper README documents three deployment patterns (dev single-node, production HA, snapshot restore).
- Wrapper: Simplified pass-through interface with annotated `terraform.tfvars` covering dev, HA production, and snapshot-restore scenarios; promotion tiers auto-assigned so the lowest-index instance is elected primary during failover.
- Consistency: Module follows established patterns (multi-resource `for_each` maps, `coalesce`-based safe defaults, derived `parameter_group_family` from `engine_version`, `CreatedDate`/`ManagedBy`/`Module` tagging, `create_before_destroy` on parameter groups); root README and pricing guide updated with DocumentDB links and expanded cost examples.

## Repository Updates (2026-03-01)
- New: [DynamoDB module](modules/databases/non-relational/aws_dynamodb/README.md) and [wrapper](tf-plans/aws_dynamodb/README.md) added—supports serverless NoSQL tables with on-demand and provisioned billing modes; includes Global Secondary Indexes (GSI), Local Secondary Indexes (LSI), DynamoDB Streams, Time to Live (TTL), point-in-time recovery, and global tables with multi-region replication.
- Docs: Comprehensive READMEs with detailed variable tables for table configuration, billing modes (on-demand vs provisioned), auto-scaling, encryption (AWS-owned or customer-managed KMS keys), and index types; includes table classes (Standard/IA), deletion protection, and import from S3 capabilities.
- Wrapper: Simplified interface with example `terraform.tfvars` demonstrating 5 deployment scenarios (simple on-demand table with GSI, composite primary key with LSI/GSI, provisioned capacity with auto-scaling, global table with multi-region replication, and analytics table with projected attributes).
- Consistency: Module follows established patterns (multi-resource maps, dynamic blocks with safe defaults, `CreatedDate` tagging) and supports all DynamoDB features including streams for event-driven architectures, TTL for automatic item expiration, PITR for backups, and global tables for active-active multi-region deployments.

## Repository Updates (2026-02-23)
- New: [Aurora module](modules/databases/relational/aws_aurora/README.md) and [wrapper](tf-plans/aws_aurora/README.md) added—supports Aurora MySQL and Aurora PostgreSQL with provisioned clusters, Serverless v1, Serverless v2, and global databases; includes cluster-based architecture with configurable read replicas, auto-scaling, backtrack (MySQL only), I/O-Optimized storage, and Data API support.
- Docs: Comprehensive READMEs with detailed comparison tables (Aurora vs RDS), engine modes (provisioned/serverless/parallelquery/global), and variable tables for cluster/instance configurations; includes DB subnet groups, cluster parameter groups, instance parameter groups, and global cluster setup.
- Wrapper: Simplified interface with auto-configuration for Serverless v1/v2 scaling, parameter group family detection, and multi-instance deployment; example `terraform.tfvars` demonstrates 5 deployment scenarios (provisioned PostgreSQL, MySQL with backtrack, Serverless v2, Serverless v1 with Data API, and I/O-Optimized storage).
- Consistency: Module follows established patterns (multi-resource maps, dynamic blocks with safe defaults, `CreatedDate` tagging) and supports all Aurora features including global databases, custom endpoints, Performance Insights, IAM authentication, and CloudWatch log exports; pricing guide updated with Aurora-specific costs (ACU pricing, I/O costs, storage costs).

## Repository Updates (2026-02-22)
- New: [RDS module](modules/databases/relational/aws_rds/README.md) and [wrapper](tf-plans/aws_rds/README.md) added—supports all RDS database engines (MySQL, PostgreSQL, MariaDB, Oracle, SQL Server) with multi-instance deployment, storage autoscaling, high availability (Multi-AZ), encryption, automated backups, Performance Insights, and read replicas.
- Docs: Comprehensive READMEs with detailed variable tables for all engine types; includes DB subnet groups, parameter groups, option groups, and point-in-time recovery configurations.
- Wrapper: Simplified interface with smart defaults; auto-detects parameter group family; supports instance scaling via `instance_count`; example `terraform.tfvars` demonstrates PostgreSQL, MySQL, Oracle, and SQL Server configurations.
- Consistency: Module follows established patterns (multi-resource maps, dynamic blocks with safe defaults, `CreatedDate` tagging) and supports all RDS features including blue/green deployments, IAM authentication, and CloudWatch log exports.

## Repository Updates (2026-02-22)
- New: [ElastiCache module](modules/databases/non-relational/aws_elasticache/README.md) and [wrapper](tf-plans/aws_elasticache/README.md) added—supports Redis, Memcached, and Valkey engines with standalone clusters and replication groups.
- Docs: Comprehensive variable tables for clusters and replication groups; includes encryption, snapshots, log delivery, cluster mode, and authentication options.
- Wrapper: Example `terraform.tfvars` demonstrates Memcached caching (active) with commented examples for standalone Redis, Redis HA with failover, Redis cluster mode (sharded), and Valkey replication.
- Consistency: Module follows established patterns (multi-resource maps, dynamic blocks with safe defaults, `CreatedDate` tagging) and supports both cluster mode disabled and enabled configurations.

## Repository Updates (2026-02-21)
- New: [CloudFront module](modules/networking_content_delivery/aws_cloudFront/README.md) and [wrapper](tf-plans/aws_cloudfront/README.md) added—supports CDN distributions with S3/custom origins, cache behaviors, SSL certificates, and origin failover.
- Docs: Comprehensive READMEs with detailed variable tables for origins, cache behaviors, viewer certificates; includes common patterns (SPA support, multi-origin failover, path-based routing).
- Wrapper: Example `terraform.tfvars` demonstrates S3 static website (active) with commented examples for API distributions, multi-origin failover, and geographic restrictions; includes managed cache policy IDs.
- Consistency: Module follows established patterns (multi-resource maps, dynamic blocks with safe defaults, `CreatedDate` tagging) and supports modern cache policies and legacy forwarded values.

## Repository Updates (2026-02-19)
- New: [Batch module](modules/compute/aws_containers/aws_batch/README.md) and [wrapper](tf-plans/aws_batch/README.md) added—supports compute environments (EC2/SPOT/FARGATE), job queues, and job definitions.
- Docs: Comprehensive README files with variable tables, usage examples, and IAM role requirements; wrapper includes EC2/SPOT/FARGATE configuration patterns.
- Wrapper: Example `terraform.tfvars` demonstrates EC2 compute environment (active) with commented SPOT/FARGATE alternatives; job queues and definitions with JSON container properties.
- Consistency: Module follows established patterns (multi-resource maps, safe defaults with `try()`, `CreatedDate` tagging, dynamic blocks) and aligns with other modules.

## Repository Updates (2026-02-19)
- New: [Step Functions module](modules/application_integration/aws_step_function/README.md) and [wrapper](tf-plans/aws_step_function/README.md) added—supports STANDARD/EXPRESS state machines with optional logging, tracing, and KMS encryption.
- Docs: Root README updated with Step Functions links; module README includes comprehensive variable tables and usage examples.
- Wrapper: Example `terraform.tfvars` demonstrates multiple state machines (simple, EXPRESS, encrypted) with ASL JSON definitions.
- Consistency: Module follows established patterns (multi-resource maps, safe defaults, `CreatedDate` tagging) and aligns with other modules.
  
## Repository Updates (2026-02-09)
- New: API Gateway v2 module and wrapper added (HTTP/WebSocket APIs) — integrates routes, integrations, stages, and `CreatedDate` tagging.
- Docs: Root README updated with links to API Gateway module and wrapper; module README includes usage and variable tables.
- CI/Consistency: Module aligns with wrapper patterns (maps, guarded optional blocks) to avoid nulls and enable multi-resource creation.
- Tests/No-op: No schema changes to existing modules; formatting-only hygiene remains.
  
## Fixes: ASG Module (2026-02-08)
- CloudWatch alarms: Replaced unsupported `dimensions {}` nested block with `dimensions` map on `aws_cloudwatch_metric_alarm`.
- Target tracking: Replaced nested `dimensions` with `metric_dimension` blocks inside `customized_metric_specification`.
- Predictive scaling: Corrected attribute names (`predefined_load_metric_type`, `predefined_scaling_metric_type`).
  
## Repository Updates (2026-02-07)
- README: Added "Sources and References" section (Copilot, Gemini, ChatGPT, AWS docs, Terraform provider).
- README: Resource Guide links populated for ASG/EC2/Lambda/VPC/Route 53/IAM/KMS/Security Group/S3; wrappers list converted to a table and sorted to match modules.
- Tests: New `tests/terraform_module_check.py` to enforce `.tf`/`.md` only (ignoring `examples`), run `terraform fmt -check -recursive`, and `terraform validate` per module.
- CI: Added GitHub Actions workflow [terraform-modules-ci.yml](.github/workflows/terraform-modules-ci.yml) to run the test on push/PR to `main` (Python + Terraform setup).
  
## Module: [ASG Module](modules/compute/aws_EC2s/aws_auto_scaling_grp/README.md) (2026-02-07)
- Lifecycle hooks: Optional `aws_autoscaling_lifecycle_hook` per ASG, with per-entry configuration and outputs.
- Scaling policies: Added Simple, Step (with optional CloudWatch alarms), Target Tracking, and Predictive policies; ARNs exposed in outputs.
- Single-mode synthesis: Support passing single-ASG inputs without `asgs` by synthesizing an entry in locals.
- Wrapper updates: Added `lifecycle_hooks` and `scaling_policies` inputs; README and `terraform.tfvars` examples annotated.
  
## Docs: Resource Guides Linked (2026-02-05)
- README modules table now includes a new "Resource Guide" column.
- Added links for ALB/NLB/GWLB to consolidated ELB overview: modules/compute/aws_elb/aws-elb.md.
- Other modules will gain resource guides over time; placeholders present.
  
## Module: [ASG Module](modules/compute/aws_EC2s/aws_auto_scaling_grp/README.md) (2026-02-03)
- New Auto Scaling Group module + `tf-plans/aws_asg` wrapper.
- Multi-ASG via `asgs`: per-ASG launch template or mixed instances policy.
- Outputs: map outputs keyed by ASG key; safe lifecycle ignoring desired capacity.
- Robustness: null-iteration guards, `created_date` tags; health checks, capacity rebalance.
  
## Module: [ALB Module](modules/compute/aws_elb/aws_alb/README.md) (2026-02-01)
- New ALB module + wrapper with safe defaults.
- Multi-ALB via `albs`: per-ALB target groups, listeners, rules.
- Outputs: map outputs keyed by ALB name; single-ALB outputs preserved.
- Robustness: null-iteration guards, `created_date` tags; Terraform >= 1.3, AWS Provider >= 5.0.
  
## Module: [NLB Module](modules/compute/aws_elb/aws_nlb/README.md) (2026-02-01)
- New NLB module + wrapper with safe defaults.
- Multi-NLB via `nlbs`: per-NLB target groups and listeners.
- Outputs: map outputs keyed by NLB name; Route53 alias support via zone IDs.
- Robustness: guards to avoid nulls; `created_date` tags; Terraform >= 1.3, AWS Provider >= 5.0.
  
## Module: [GWLB Module](modules/compute/aws_elb/aws_glb/README.md) (2026-02-01)
- New GWLB module + wrapper for gateway traffic (GENEVE).
- Multi-GLB via `glbs`: per-GLB target groups (GENEVE) and listeners.
- Outputs: map outputs keyed by GWLB name; zone IDs for Route53 aliases.
- Robustness: guarded iterations, TCP health checks, `created_date` tags.
  
## Module: [Route 53 Module](modules/networking_content_delivery/aws_route_53/README.md) (2026-01-26)
   - Zones & safety: Public/private zones with VPCs; `prevent_destroy = true`.
   - Records & routing: Standard and alias records; weighted, latency, failover, geolocation, CIDR, multivalue.
   - Logging & tags: Optional query logging; immutable `CreatedDate` via `time_static`.
   - Wrapper & fixes: Wrapper `for_each` scaling; provider via caller; `is_private` output and CIDR schema (`collection_id`, `location_name`) updates.
  
## Module: [Lambda Module](modules/compute/aws_lambda/README.md) (2025-12-04)
- Initial release of AWS Lambda module.
- Supports Zip and Image package types, optional IAM role creation, environment variables, VPC config, DLQ, log retention, X-Ray tracing, ephemeral storage, permissions, event source mappings, and function URL.
- Avoids null values by using conditional blocks.
- All resources tagged with created_date; wrapper plan added in `tf-plans/aws_lambda`.
  
## v0.0.1 (2025-11-29)
- VPC: IPv4/IPv6, subnets, options
- Security Group: dynamic rules support
- IAM: multi-user/group/policy support
- IAM: access keys, console access
  
## Module: [S3 Module](modules/storage/aws_s3/README.md)
- Initial release of AWS S3 module with comprehensive configuration.
- Added created_date tagging across resources.
- Added wrapper plan and examples.
  
## Module: [KMS Module](modules/security_identity_compliance/aws_kms/README.md)
- Initial release of AWS KMS module (keys, aliases, grants).
- Supports symmetric/asymmetric keys, optional rotation, multi-region keys.
- All resources tagged with created_date; wrapper plan added.
  
## v0.0.0
- Project scaffolding and setup
- Initial AWS modules released
