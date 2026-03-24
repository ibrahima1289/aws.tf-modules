# Release Notes

## Repository Updates (2026-03-23)
- New: [AWS Certificate Manager module](modules/security_identity_compliance/aws_certificate_manager/README.md) with multi-certificate support, public and imported certificate flows, optional DNS validation resources, and map-based scaling via `for_each`.
- New: [AWS Certificate Manager wrapper](tf-plans/aws_certificate_manager/README.md) with complete example files (`main.tf`, `variables.tf`, `locals.tf`, `provider.tf`, `outputs.tf`, `terraform.tfvars`) for repeatable plan/apply workflows.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md), and [modules/security_identity_compliance/aws_certificate_manager/aws-certificate-manager.md](modules/security_identity_compliance/aws_certificate_manager/aws-certificate-manager.md) with module and wrapper hyperlinks.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) to include the ACM module reference and refreshed module index coverage.

## Repository Updates (2026-03-18)
- New: [AWS NACL module](modules/security_identity_compliance/aws_nacl/README.md) with multi-NACL support, subnet associations, IPv4/IPv6 ingress and egress rules, map-based scaling via `for_each`, and consistent tagging via `created_date` + common tags.
- New: [AWS NACL wrapper](tf-plans/aws_nacl/README.md) with complete example files (`main.tf`, `variables.tf`, `locals.tf`, `provider.tf`, `outputs.tf`, `terraform.tfvars`) for safe, repeatable plan/apply workflows.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md), and [modules/security_identity_compliance/aws_nacl/aws-nacls.md](modules/security_identity_compliance/aws_nacl/aws-nacls.md) with module and wrapper hyperlinks.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) to include the NACL module reference and refreshed service index coverage.

## Repository Updates (2026-03-16)
- New: [AWS Organizations module](modules/management_and_governance/aws_organizations/README.md) — supports organization bootstrap/adoption, multi-OU hierarchy, multi-account provisioning, reusable policy creation, and policy attachments to ROOT/OU/ACCOUNT targets.
- New: [AWS Organizations wrapper](tf-plans/aws_organizations/README.md) with full `terraform.tfvars` examples for safe adoption (`create_organization = false`) and scalable landing-zone style account structures.
- Docs: Updated [aws-organizations.md](modules/management_and_governance/aws_organizations/aws-organizations.md), root [README.md](README.md), and [Module-Service-List.md](Module-Service-List.md) with module and wrapper hyperlinks.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) and service/module index entries to include Organizations module linkage and latest module count.

## Repository Updates (2026-03-15)
- New: [CloudTrail module](modules/monitoring/aws_cloudtrail/README.md) and [wrapper](tf-plans/aws_cloudtrail/README.md) — multi-trail via `trails` list variable; management events, data events (S3/Lambda/DynamoDB), standard and advanced event selectors, Insights anomaly detection, CloudWatch Logs delivery, KMS encryption, and log file validation; map outputs keyed by trail name.
- Refactor: [CloudWatch module](modules/monitoring/aws_cloudwatch/README.md) resource labels renamed from `"this"` to descriptive names in `main.tf` and `outputs.tf`; existing applied stacks require `terraform state mv` per resource to avoid destroy/recreate.
- Enhancement: CloudWatch wrapper dashboard body externalized to [`tf-plans/aws_cloudwatch/dashboards/demo-overview.json`](tf-plans/aws_cloudwatch/dashboards/demo-overview.json); loaded via `file()` in `locals.tf` with `concat()` merge pattern — no inline JSON in `terraform.tfvars`.
- Docs: [aws-cloudtrail.md](modules/monitoring/aws_cloudtrail/aws-cloudtrail.md) updated with Terraform module and wrapper header links; [aws-cloudwatch.md](modules/monitoring/aws_cloudwatch/aws-cloudwatch.md) fully rewritten with component deep-dives, security best practices table, Logs Insights query examples, and architecture diagram.

## Repository Updates (2026-03-14)
- New: [CloudWatch module](modules/monitoring/aws_cloudwatch/README.md) and [wrapper](tf-plans/aws_cloudwatch/README.md) — log groups, metric alarms (standard + expression-based), composite alarms, dashboards, log metric filters, and log subscription filters; multi-resource via list variables with map outputs.
- New: [CloudWatch service guide](modules/monitoring/aws_cloudwatch/aws-cloudwatch.md) and [CloudTrail service guide](modules/monitoring/aws_cloudtrail/aws-cloudtrail.md) — architecture, key components, security best practices, and real-life use cases.
- Docs: [Module-Service-List.md](Module-Service-List.md) updated with new Monitoring section (CloudWatch module + wrapper rows).
- Docs: Root [README.md](README.md), [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) updated with monitoring tree entry and corrected CloudWatch/CloudTrail documentation links.

## Repository Updates (2026-03-12)
- Docs: Added service guides for 5 Analytics services: [EMR](modules/analytics/aws_mapreduce/aws-emr.md), [Redshift](modules/analytics/aws_redshift/aws-redshift.md), [Athena](modules/analytics/aws_athena/aws-athena.md), [QuickSight](modules/analytics/aws_quicksight/aws-quicksight.md), and [OpenSearch Service](modules/analytics/aws_opensearch_service/aws-opensearch.md).
- Docs: Each guide covers architecture, key features, security, pricing, use cases, and Terraform resource references.
- Docs: Module-Service-List.md Analytics section updated with all 5 new rows; README structure tree updated.

## Repository Updates (2026-03-11)
- Docs: Added [AWS Migration guide](modules/management_and_governance/aws_migration/aws-migration.md) covering MGN, deprecated SMS, and the 6 R's migration strategy (Rehost, Replatform, Repurchase, Refactor, Retire, Retain).
- Docs: Includes Migration Hub, Application Discovery Service, and DMS source-to-target matrix.
- Docs: Module-Service-List.md and README updated with Management & Governance section.

## Repository Updates (2026-03-07)
- Docs: Added service guides for 7 Storage & Migration services: [Snow Family](modules/storage/aws_snow_family/aws-snow-family.md), [Backup](modules/storage/aws_backup/aws-backup.md), [DataSync](modules/storage/aws_datasync/aws-datasync.md), [DMS](modules/storage/aws_database_migration/aws-database-migration.md), [Lake Formation](modules/storage/aws_lake_formation/aws-lake-formation.md), [Transfer Family](modules/storage/aws_transfer_family/aws-transfer-family.md), and [Storage Gateway](modules/storage/aws-storage-gateway/aws-storage-gateway.md).
- Docs: Root README updated with links for all 7 services; pricing guide paths corrected.

## Repository Updates (2026-03-05)
- New: [DocumentDB module](modules/databases/non-relational/aws_documentdb/README.md) and [wrapper](tf-plans/aws_documentdb/README.md) — MongoDB-compatible clusters; single-node and multi-node HA; I/O-Optimized storage; KMS encryption; PITR; CloudWatch log exports.
- Docs: Module README with architecture diagram and full variable tables; wrapper covers dev, HA, and snapshot-restore patterns.

## Repository Updates (2026-03-01)
- New: [DynamoDB module](modules/databases/non-relational/aws_dynamodb/README.md) and [wrapper](tf-plans/aws_dynamodb/README.md) — on-demand and provisioned billing; GSI/LSI; Streams; TTL; PITR; global tables.
- Docs: Module README with variable tables; wrapper covers 5 deployment scenarios.

## Repository Updates (2026-02-23)
- New: [Aurora module](modules/databases/relational/aws_aurora/README.md) and [wrapper](tf-plans/aws_aurora/README.md) — MySQL/PostgreSQL; provisioned, Serverless v1/v2, global databases; read replicas; auto-scaling.
- Docs: Module README with Aurora vs RDS comparison and variable tables; wrapper covers 5 deployment scenarios.

## Repository Updates (2026-02-22)
- New: [RDS module](modules/databases/relational/aws_rds/README.md) and [wrapper](tf-plans/aws_rds/README.md) — MySQL, PostgreSQL, MariaDB, Oracle, SQL Server; Multi-AZ; PITR; Performance Insights; read replicas.
- New: [ElastiCache module](modules/databases/non-relational/aws_elasticache/README.md) and [wrapper](tf-plans/aws_elasticache/README.md) — Redis, Memcached, Valkey; replication groups; cluster mode; encryption.

## Repository Updates (2026-02-21)
- New: [CloudFront module](modules/networking_content_delivery/aws_cloudFront/README.md) and [wrapper](tf-plans/aws_cloudfront/README.md) — CDN distributions; S3/custom origins; cache behaviors; SSL/TLS; origin failover.

## Repository Updates (2026-02-19)
- New: [Batch module](modules/compute/aws_containers/aws_batch/README.md) and [wrapper](tf-plans/aws_batch/README.md) — compute environments (EC2/SPOT/FARGATE); job queues and definitions.
- New: [Step Functions module](modules/application_integration/aws_step_function/README.md) and [wrapper](tf-plans/aws_step_function/README.md) — STANDARD/EXPRESS state machines; logging, tracing, KMS encryption.

## Repository Updates (2026-02-09)
- New: [API Gateway v2 module](modules/networking_content_delivery/aws_api_gateway/README.md) and [wrapper](tf-plans/aws_api_gateway/README.md) — HTTP/WebSocket APIs; routes, integrations, stages.

## Fixes: ASG Module (2026-02-08)
- Fixed unsupported `dimensions {}` block on `aws_cloudwatch_metric_alarm`; corrected `metric_dimension` blocks and predictive scaling attribute names.

## Repository Updates (2026-02-07)
- Docs: Added "Sources and References" section to README; populated Resource Guide links for all existing modules.
- Tests: Added `terraform_module_check.py` enforcing `.tf`/`.md` file types, `terraform fmt`, and `terraform validate`.
- CI: Added [terraform-modules-ci.yml](.github/workflows/terraform-modules-ci.yml) GitHub Actions workflow.

## Module: [ASG Module](modules/compute/aws_EC2s/aws_auto_scaling_grp/README.md) (2026-02-07)
- Added lifecycle hooks, Simple/Step/Target Tracking/Predictive scaling policies, and single-ASG synthesis mode.

## Docs: Resource Guides Linked (2026-02-05)
- Added "Resource Guide" column to README modules table; linked ALB/NLB/GWLB to consolidated [ELB overview](modules/compute/aws_elb/aws-elb.md).

## Module: [ASG Module](modules/compute/aws_EC2s/aws_auto_scaling_grp/README.md) (2026-02-03)
- New ASG module and wrapper — multi-ASG via `asgs`; launch template and mixed instances policy support.

## Repository Updates (2026-02-01)
- New: [ALB module](modules/compute/aws_elb/aws_alb/README.md), [NLB module](modules/compute/aws_elb/aws_nlb/README.md), and [GWLB module](modules/compute/aws_elb/aws_glb/README.md) — multi-resource via `albs`/`nlbs`/`glbs`; map outputs keyed by resource name.

## Module: [Route 53 Module](modules/networking_content_delivery/aws_route_53/README.md) (2026-01-26)
- New Route 53 module — public/private zones; standard and alias records; weighted, latency, failover, geolocation, and multivalue routing.

## Module: [Lambda Module](modules/compute/aws_lambda/README.md) (2025-12-04)
- New Lambda module — Zip/Image package types; VPC config; DLQ; X-Ray tracing; event source mappings; function URL.

## v0.0.1 (2025-11-29)
- New: VPC, Security Group, IAM modules — subnets, dynamic rules, multi-user/group/policy, access keys, console access.

## v0.0.0
- New: S3 and KMS modules; project scaffolding and initial setup.
