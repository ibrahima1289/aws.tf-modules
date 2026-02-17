# Release Notes

## Module: [SNS Module](modules/application_integration/aws_sns/README.md) (2026-02-17)
- New SNS module and `tf-plans/aws_sns` wrapper for standard/FIFO topics, optional subscriptions, and DLQ support via subscription redrive policies.
- Multi-topic support via `topics` map; per-topic options and subscriptions normalized in locals to avoid nulls and support safe for_each scaling.
- Consistent `CreatedDate` tagging and tag merging (global + per-topic) aligned with other modules.
- Root README updated with SNS module/wrapper links and SNS overview doc.

## Module: [SQS Module](modules/application_integration/aws_sqs/README.md) (2026-02-16)
- New SQS module and `tf-plans/aws_sqs` wrapper for standard/FIFO queues, DLQs, encryption, and policies.
- Multi-queue support via `queues` map; per-queue options with safe defaults and guarded optional blocks to avoid nulls.
- Consistent `CreatedDate` tagging and tagging merge (global + per-queue) aligned with other modules.
- Root README updated with SQS module/wrapper links and SQS overview doc.

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
