# Release Notes

## Module: [ALB Module](modules/compute/aws_elb/aws_alb/README.md) (2026-02-01)
- New ALB module + wrapper with safe defaults.
- Multi-ALB via `albs`: per-ALB target groups, listeners, rules.
- Outputs: map outputs keyed by ALB name; single-ALB outputs preserved.
- Robustness: null-iteration guards, `created_date` tags; Terraform >= 1.3, AWS Provider >= 5.0.

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
