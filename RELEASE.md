# Release Notes

## Repository Updates (2026-03-25) — AWS Elastic Block Store (EBS)
- New: [AWS EBS module](modules/storage/aws_ebs/README.md) — six volume types, encryption, multi-attach, snapshot restore, and attachments via `for_each`.
- New: [AWS EBS wrapper](tf-plans/aws_ebs/README.md) — gp3 web-app, io2 database, st1 big-data volumes; two attachments; one compliance snapshot.
- Docs: Updated [Module-Service-List.md](Module-Service-List.md) (count 41→42) and [aws-ebs.md](modules/storage/aws_ebs/aws-ebs.md) with module and wrapper links.
- Docs: Updated [README.md](README.md) and [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) with EBS module and wrapper links.

## Repository Updates (2026-03-24) — AWS Athena
- New: [AWS Athena module](modules/analytics/aws_athena/README.md) — workgroups, Glue-backed databases, named queries, and federated catalogs via `for_each`.
- New: [AWS Athena wrapper](tf-plans/aws_athena/README.md) — 2 workgroups, 1 database, 2 SQL templates, 1 GLUE catalog.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 40→41), and [aws-athena.md](modules/analytics/aws_athena/aws-athena.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) Athena row with module and wrapper links.

## Repository Updates (2026-03-24) — AWS Fargate
- New: [AWS Fargate module](modules/compute/aws_serverless/aws_fargate/README.md) — ECS clusters, task definitions, and services with FARGATE + FARGATE_SPOT via `for_each`.
- New: [AWS Fargate wrapper](tf-plans/aws_fargate/README.md) — API service (ALB, 2 tasks) and SPOT worker (3 tasks) patterns with JSON templates.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 39→40), and [aws-fargate.md](modules/compute/aws_serverless/aws_fargate/aws-fargate.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) Fargate row with module and wrapper links.

## Repository Updates (2026-03-24) — AWS Elastic Beanstalk
- New: [AWS Elastic Beanstalk module](modules/compute/aws_elastic_beanstalk/README.md) — multiple apps and environments; WebServer/Worker tiers; `custom_settings` escape-hatch via `for_each`.
- New: [AWS Elastic Beanstalk wrapper](tf-plans/aws_elastic_beanstalk/README.md) — Node.js staging, Node.js production ALB, and Python Worker patterns.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 38→39), and [aws-elastic-beanstalk.md](modules/compute/aws_elastic_beanstalk/aws-elastic-beanstalk.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) Elastic Beanstalk row with module and wrapper links.

## Repository Updates (2026-03-24) — AWS EventBridge
- New: [AWS EventBridge module](modules/application_integration/aws_eventbridge/README.md) — custom buses, scheduled and pattern rules, multi-target routing, DLQs, and archives via `for_each`.
- New: [AWS EventBridge wrapper](tf-plans/aws_eventbridge/README.md) — 4 rule patterns: Lambda trigger, EC2 state-change, Step Functions, and disabled S3-upload rule.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 37→38), and [aws-eventbridge.md](modules/application_integration/aws_eventbridge/aws-eventbridge.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) EventBridge row with module and wrapper links.

## Repository Updates (2026-03-24) — AWS Savings Plans
- Docs: New [AWS Savings Plans resource guide](modules/cloud_financial_management/aws_savings_plan/aws-savings-plan.md) — Compute, EC2 Instance, and SageMaker plan types with examples.
- Docs: Updated [Module-Service-List.md](Module-Service-List.md) (Total Services 132→133, Resource Guides 130→131; Savings Plans row added).
- Docs: Updated [README.md](README.md) and [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) with Savings Plans pricing and links.

## Repository Updates (2026-03-24) — AWS Budgets
- New: [AWS Budget module](modules/cloud_financial_management/aws_budget/README.md) — multi-budget, all cost types, multi-threshold notifications, and automated IAM/SCP/SSM actions.
- New: [AWS Budget wrapper](tf-plans/aws_budget/README.md) — 5 patterns: account-wide, EC2-scoped, historical, RI utilization, and auto-remediation.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 36→37), and [aws-budget.md](modules/cloud_financial_management/aws_budget/aws-budget.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) with Budgets pricing row and links.

## Repository Updates (2026-03-23) — AWS WAF v2
- New: [AWS WAF v2 module](modules/security_identity_compliance/aws_waf/README.md) — multi-ACL (REGIONAL/CLOUDFRONT), IP sets, managed rules, rate-based, and geo-match via `for_each`.
- New: [AWS WAF wrapper](tf-plans/aws_waf/README.md) — 2 Web ACLs, 2 IP sets, 1 regex set, rate limiting, geo-blocking, and Firehose logging.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 35→36), and [aws-waf.md](modules/security_identity_compliance/aws_waf/aws-waf.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) WAF row with module and wrapper links.

## Repository Updates (2026-03-23) — AWS Network Firewall
- New: [AWS Network Firewall module](modules/security_identity_compliance/aws_network_firewall/README.md) — multi-firewall, four rule types, KMS encryption, and multi-destination logging via `for_each`.
- New: [AWS Network Firewall wrapper](tf-plans/aws_network_firewall/README.md) — two-AZ HA egress firewall with domain allowlist, Suricata IPS rules, and dual logging.
- Docs: Updated [Module-Service-List.md](Module-Service-List.md) (count 34→35) and [aws-network-firewall.md](modules/security_identity_compliance/aws_network_firewall/aws-network-firewall.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) and [README.md](README.md) with Network Firewall module and wrapper links.
## Repository Updates (2026-03-24) — AWS Shield Advanced
- New: [AWS Shield Advanced module](modules/security_identity_compliance/aws_shield/README.md) — subscription (cost-gated), multi-resource protections, protection groups, DRT access, and proactive engagement.
- New: [AWS Shield Advanced wrapper](tf-plans/aws_shield/README.md) — ALB, CloudFront, and EIP protections; ALL and ARBITRARY groups; DRT and proactive engagement.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 34→35), and [aws-shield.md](modules/security_identity_compliance/aws_shield/aws-shield.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) with Shield Advanced pricing row ($3,000/month, no free tier).

## Repository Updates (2026-03-23) — AWS Firewall Manager
- New: [AWS Firewall Manager module](modules/security_identity_compliance/aws_firwall_manager/README.md) — multi-policy, FMS admin designation, dynamic scoping, all six policy types via `for_each`.
- New: [AWS Firewall Manager wrapper](tf-plans/aws_firewall_manager/README.md) — Shield Advanced org-wide, WAFv2 prod-scoped, and Network Firewall OU patterns.
- Docs: Updated [Module-Service-List.md](Module-Service-List.md) (count 34→35), [aws-firewall-manager.md](modules/security_identity_compliance/aws_firwall_manager/aws-firewall-manager.md), and [README.md](README.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) Firewall Manager row with module and wrapper links.

## Repository Updates (2026-03-23) — AWS Secrets Manager
- New: [AWS Secrets Manager module](modules/security_identity_compliance/aws_secrets_manager/README.md) — multi-secret, Lambda rotation, resource policies, and multi-region replication via `for_each`.
- New: [AWS Secrets Manager wrapper](tf-plans/aws_secrets_manager/README.md) — 4 patterns: rotated DB credentials, static API key, JSON config, and multi-region JWT key.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md) (count 33→34), and [aws-secrets-manager.md](modules/security_identity_compliance/aws_secrets_manager/aws-secrets-manager.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) with Secrets Manager pricing row and links.

## Repository Updates (2026-03-18) — AWS NACL
- New: [AWS NACL module](modules/security_identity_compliance/aws_nacl/README.md) — multi-NACL, subnet associations, IPv4/IPv6 ingress/egress rules via `for_each`.
- New: [AWS NACL wrapper](tf-plans/aws_nacl/README.md) — full example files for safe, repeatable plan/apply workflows.
- Docs: Updated [README.md](README.md), [Module-Service-List.md](Module-Service-List.md), and [aws-nacls.md](modules/security_identity_compliance/aws_nacl/aws-nacls.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) with NACL module reference and service index.

## Repository Updates (2026-03-16) — AWS Organizations
- New: [AWS Organizations module](modules/management_and_governance/aws_organizations/README.md) — org bootstrap/adoption, multi-OU hierarchy, multi-account provisioning, and policy attachments.
- New: [AWS Organizations wrapper](tf-plans/aws_organizations/README.md) — safe adoption (`create_organization = false`) and landing-zone account structures.
- Docs: Updated [aws-organizations.md](modules/management_and_governance/aws_organizations/aws-organizations.md), [README.md](README.md), and [Module-Service-List.md](Module-Service-List.md) with module and wrapper links.
- Docs: Updated [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) with Organizations module link and latest module count.

## Repository Updates (2026-03-15) — CloudTrail & CloudWatch
- New: [CloudTrail module](modules/monitoring/aws_cloudtrail/README.md) and [wrapper](tf-plans/aws_cloudtrail/README.md) — multi-trail, management/data events, Insights, KMS, and CloudWatch Logs delivery.
- Refactor: [CloudWatch module](modules/monitoring/aws_cloudwatch/README.md) resource labels renamed; existing stacks require `terraform state mv` to avoid destroy/recreate.
- Enhancement: CloudWatch wrapper dashboard externalized to [`demo-overview.json`](tf-plans/aws_cloudwatch/dashboards/demo-overview.json) and loaded via `file()` in `locals.tf`.
- Docs: Updated [aws-cloudtrail.md](modules/monitoring/aws_cloudtrail/aws-cloudtrail.md) and [aws-cloudwatch.md](modules/monitoring/aws_cloudwatch/aws-cloudwatch.md) with module, wrapper, and architecture links.

## Repository Updates (2026-03-14) — CloudWatch & CloudTrail
- New: [CloudWatch module](modules/monitoring/aws_cloudwatch/README.md) and [wrapper](tf-plans/aws_cloudwatch/README.md) — log groups, metric alarms, composite alarms, dashboards, and log filters.
- New: [CloudWatch guide](modules/monitoring/aws_cloudwatch/aws-cloudwatch.md) and [CloudTrail guide](modules/monitoring/aws_cloudtrail/aws-cloudtrail.md) — architecture, best practices, and use cases.
- Docs: [Module-Service-List.md](Module-Service-List.md) updated with new Monitoring section rows.
- Docs: [README.md](README.md) and [AWS-Services-Pricing-Guide.md](AWS-Services-Pricing-Guide.md) updated with monitoring tree and corrected links.

## Repository Updates (2026-03-12) — Analytics Service Guides
- Docs: New guides for [EMR](modules/analytics/aws_mapreduce/aws-emr.md), [Redshift](modules/analytics/aws_redshift/aws-redshift.md), [Athena](modules/analytics/aws_athena/aws-athena.md), [QuickSight](modules/analytics/aws_quicksight/aws-quicksight.md), and [OpenSearch](modules/analytics/aws_opensearch_service/aws-opensearch.md).
- Docs: Each guide covers architecture, key features, security, pricing, and Terraform resource references.
- Docs: [Module-Service-List.md](Module-Service-List.md) Analytics section updated with all 5 new rows.

## Repository Updates (2026-03-11) — Migration
- Docs: New [AWS Migration guide](modules/management_and_governance/aws_migration/aws-migration.md) — MGN, deprecated SMS, and the 6 R's strategy.
- Docs: Includes Migration Hub, Application Discovery Service, and DMS source-to-target matrix.
- Docs: [Module-Service-List.md](Module-Service-List.md) and [README.md](README.md) updated with Management & Governance section.

## Repository Updates (2026-03-07) — Storage & Migration Guides
- Docs: New guides for [Snow Family](modules/storage/aws_snow_family/aws-snow-family.md), [Backup](modules/storage/aws_backup/aws-backup.md), [DataSync](modules/storage/aws_datasync/aws-datasync.md), [DMS](modules/storage/aws_database_migration/aws-database-migration.md), [Lake Formation](modules/storage/aws_lake_formation/aws-lake-formation.md), [Transfer Family](modules/storage/aws_transfer_family/aws-transfer-family.md), and [Storage Gateway](modules/storage/aws-storage-gateway/aws-storage-gateway.md).
- Docs: [README.md](README.md) updated with links for all 7 new service guides.

## Repository Updates (2026-03-05) — DocumentDB
- New: [DocumentDB module](modules/databases/non-relational/aws_documentdb/README.md) and [wrapper](tf-plans/aws_documentdb/README.md) — MongoDB-compatible clusters, HA, I/O-Optimized storage, KMS, and CloudWatch logs.
- Docs: Module README with architecture diagram; wrapper covers dev, HA, and snapshot-restore patterns.

## Repository Updates (2026-03-01) — DynamoDB
- New: [DynamoDB module](modules/databases/non-relational/aws_dynamodb/README.md) and [wrapper](tf-plans/aws_dynamodb/README.md) — on-demand/provisioned billing, GSI/LSI, Streams, TTL, PITR, global tables.
- Docs: Module README with variable tables; wrapper covers 5 deployment scenarios.

## Repository Updates (2026-02-23) — Aurora
- New: [Aurora module](modules/databases/relational/aws_aurora/README.md) and [wrapper](tf-plans/aws_aurora/README.md) — MySQL/PostgreSQL, Serverless v1/v2, global databases, read replicas, auto-scaling.
- Docs: Module README with Aurora vs RDS comparison; wrapper covers 5 deployment scenarios.

## Repository Updates (2026-02-22) — RDS & ElastiCache
- New: [RDS module](modules/databases/relational/aws_rds/README.md) and [wrapper](tf-plans/aws_rds/README.md) — MySQL, PostgreSQL, MariaDB, Oracle, SQL Server; Multi-AZ, PITR, read replicas.
- New: [ElastiCache module](modules/databases/non-relational/aws_elasticache/README.md) and [wrapper](tf-plans/aws_elasticache/README.md) — Redis, Memcached, Valkey; replication groups and cluster mode.

## Repository Updates (2026-02-21) — CloudFront
- New: [CloudFront module](modules/networking_content_delivery/aws_cloudFront/README.md) and [wrapper](tf-plans/aws_cloudfront/README.md) — CDN distributions; S3/custom origins; cache behaviors; SSL/TLS; origin failover.

## Repository Updates (2026-02-19) — Batch & Step Functions
- New: [Batch module](modules/compute/aws_containers/aws_batch/README.md) and [wrapper](tf-plans/aws_batch/README.md) — compute environments (EC2/SPOT/FARGATE), job queues, and definitions.
- New: [Step Functions module](modules/application_integration/aws_step_function/README.md) and [wrapper](tf-plans/aws_step_function/README.md) — STANDARD/EXPRESS state machines; logging, tracing, KMS.

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
