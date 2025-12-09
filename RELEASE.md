# Release Notes

## Module: compute/aws_lambda (2025-12-04)
- Initial release of AWS Lambda module.
- Supports Zip and Image package types, optional IAM role creation, environment variables, VPC config, DLQ, log retention, X-Ray tracing, ephemeral storage, permissions, event source mappings, and function URL.
- Avoids null values by using conditional blocks.
- All resources tagged with created_date; wrapper plan added in `tf-plans/aws_lambda`.

## v0.0.1 (2025-11-29)
- VPC: IPv4/IPv6, subnets, options
- Security Group: dynamic rules support
- IAM: multi-user/group/policy support
- IAM: access keys, console access

## Module: storage/aws_s3
- Initial release of AWS S3 module with comprehensive configuration.
- Added created_date tagging across resources.
- Added wrapper plan and examples.

## Module: security_identity_compliance/aws_kms
- Initial release of AWS KMS module (keys, aliases, grants).
- Supports symmetric/asymmetric keys, optional rotation, multi-region keys.
- All resources tagged with created_date; wrapper plan added.

## v0.0.0
- Project scaffolding and setup
- Initial AWS modules released
