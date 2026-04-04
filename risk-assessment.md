# AWS Terraform Modules — Risk Assessment

**Repository:** `aws.tf-modules`  
**Branch:** `main`  
**Assessment Date:** 2026-04-04  
**Scope:** 45 complete modules (modules with `main.tf` + `variables.tf` + `outputs.tf`)  
**Assessment Categories:** Security · Reliability · Compliance · CI/CD · Version Hygiene

---

## Summary

| Severity | Count |
|----------|-------|
| 🔴 Critical | 4 |
| 🟠 High | 8 |
| 🟡 Medium | 7 |
| 🔵 Low | 4 |
| **Total** | **23** |

---

## Modules Audited (45)

| Category | Modules |
|----------|---------|
| Analytics (3) | aws_athena, aws_kinesis, aws-msk |
| Application Integration (5) | aws_eventbridge, aws_mq, aws_sns, aws_sqs, aws_step_function |
| Cloud Financial Management (1) | aws_budget |
| Compute (9) | aws_batch, aws_auto_scaling_grp, aws_ec2, aws_elastic_beanstalk, aws_alb, aws_glb, aws_nlb, aws_fargate, aws_lambda |
| Databases (5) | aws_documentdb, aws_dynamodb, aws_elasticache, aws_aurora, aws_rds |
| Management & Governance (1) | aws_organizations |
| Monitoring (2) | aws_cloudtrail, aws_cloudwatch |
| Networking & Content Delivery (6) | aws_api_gateway, aws_cloudFront, aws_internet_gateway, aws_route_53, aws_route_table, aws_vpc |
| Security, Identity & Compliance (11) | aws_certificate_manager, aws_firwall_manager, aws_guardDuty, aws_iam, aws_kms, aws_nacl, aws_network_firewall, aws_secrets_manager, aws_security_group, aws_shield, aws_waf |
| Storage (3) | aws_backup, aws_ebs, aws_s3, aws-storage-gateway |

---

## Detailed Findings

### 🔴 Critical

---

#### C-01 — Invalid Terraform `required_version` in 14 Modules

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 Critical |
| **Modules** | All compute sub-modules (9) + all database modules (5): `aws_ec2`, `aws_auto_scaling_grp`, `aws_batch`, `aws_elastic_beanstalk`, `aws_alb`, `aws_glb`, `aws_nlb`, `aws_fargate`, `aws_lambda`, `aws_rds`, `aws_aurora`, `aws_documentdb`, `aws_elasticache`, `aws_dynamodb` |
| **File** | `providers.tf` |
| **Issue** | `required_version = ">= 6.0, < 7.0"` is the AWS **provider** version range, not a valid Terraform version. Terraform CLI versions are `1.x.x` — this constraint will cause `terraform init` to fail on these 14 modules. |
| **Fix** | Change to `required_version = ">= 1.14.0, < 2.0.0"` in all affected modules. |

---

#### C-02 — ElastiCache Output: Unsafe Array Access Without `try()`

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 Critical |
| **Module** | `modules/databases/non-relational/aws_elasticache` |
| **File** | `outputs.tf` line 14 |
| **Issue** | `v.cache_nodes[0].address` — if `cache_nodes` is empty, Terraform will throw an evaluation error at plan/apply time, breaking deployments. |
| **Fix** | `value = { for k, v in aws_elasticache_cluster.cluster : k => try(v.cache_nodes[0].address, null) }` |

---

#### C-03 — Route 53 `prevent_destroy = false` on Critical DNS Infrastructure

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 Critical |
| **Module** | `modules/networking_content_delivery/aws_route_53` |
| **File** | `main.tf` line 36 |
| **Issue** | The module comment says "`prevent_destroy` defaults to true to protect against accidental deletion" but the code explicitly sets `prevent_destroy = false`. An accidental `terraform destroy` will permanently delete production DNS zones. |
| **Fix** | Change `prevent_destroy = false` → `prevent_destroy = true`. |

---

#### C-04 — CI Checkov and `terraform init` Failures Silently Suppressed

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 Critical |
| **File** | `.github/workflows/terraform-modules-ci.yml` lines 57, 73 |
| **Issue** | Two CI steps use `|| true` to suppress exit codes: (1) `terraform init ... || true` — broken modules pass init silently; (2) `checkov ... || true` — security vulnerabilities are reported but never fail the build. Code with high-severity security issues merges without CI blocking. |
| **Fix** | Remove `|| true` from both steps. For checkov, use `--soft-fail` only for specific known exceptions with documented justification. |

---

### 🟠 High

---

#### H-01 — EC2 Module Missing Region Validation

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Module** | `modules/compute/aws_EC2s/aws_ec2` |
| **File** | `variables.tf` |
| **Issue** | `variable "region"` has no validation block. Invalid region values cause runtime errors. 14 other modules were updated with regex validation in a prior pass but EC2 was missed. |
| **Fix** | Add `validation { condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region)) ... }` |

---

#### H-02 — Network Firewall: No CIDR Format Validation

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Module** | `modules/security_identity_compliance/aws_network_firewall` |
| **File** | `variables.tf` |
| **Issue** | `rule_groups[*].ip_sets[*].definition` accepts IP set CIDR strings without validation. An invalid CIDR silently passes `terraform plan` but fails during AWS API calls. |
| **Fix** | Add validation using `can(cidrhost(ip_set.definition, 0))` across all `ip_sets` entries. |

---

#### H-03 — Secrets Manager `secret_ids` and `secret_names` Not Marked Sensitive

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Module** | `modules/security_identity_compliance/aws_secrets_manager` |
| **File** | `outputs.tf` |
| **Issue** | `secret_arns` is correctly marked `sensitive = true`, but `secret_ids` and `secret_names` outputs are not. Secret names/IDs allow enumeration of secret resources and should be treated as confidential. |
| **Fix** | Add `sensitive = true` to `output "secret_ids"` and `output "secret_names"`. |

---

#### H-04 — API Gateway: No CORS `allow_origins = "*"` Validation

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Module** | `modules/networking_content_delivery/aws_api_gateway` |
| **File** | `variables.tf` |
| **Issue** | `cors_configuration.allow_origins` accepts `["*"]` without validation, which exposes the API to all web origins. This is a security anti-pattern for any API with authentication or sensitive data. |
| **Fix** | Add a validation block preventing `"*"` in `allow_origins` or requiring explicit justification. |

---

#### H-05 — RDS/Aurora: No Validation Preventing `publicly_accessible = true`

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Modules** | `modules/databases/relational/aws_rds`, `modules/databases/relational/aws_aurora` |
| **File** | `variables.tf` |
| **Issue** | `publicly_accessible` defaults to `false` (correct), but no validation prevents setting it to `true`. An operator mistake or misconfiguration can expose RDS/Aurora instances to the public internet. |
| **Fix** | Add validation block enforcing `publicly_accessible = false`, or add a prominent description warning. |

---

#### H-06 — RDS/Aurora: `storage_encrypted = false` Not Blocked

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Modules** | `modules/databases/relational/aws_rds`, `modules/databases/relational/aws_aurora` |
| **File** | `variables.tf` |
| **Issue** | `storage_encrypted` defaults to `true` (good), but a caller can explicitly set `storage_encrypted = false` to disable encryption at rest with no validation warning. |
| **Fix** | Add validation block: `condition = alltrue([for i in var.rds_instances : try(i.storage_encrypted, true) == true])` |

---

#### H-07 — DocumentDB: No KMS Key ARN Format Validation

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Module** | `modules/databases/non-relational/aws_documentdb` |
| **File** | `variables.tf` |
| **Issue** | `kms_key_id` accepts any string without validating ARN format (`arn:aws:kms:...`). An invalid ARN passes validation but fails on AWS API apply. |
| **Fix** | Add validation: `can(regex("^arn:aws:kms:", c.kms_key_id))` when `kms_key_id` is provided. |

---

#### H-08 — S3 Public Access Block Settings: No Enforcement Validation

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Module** | `modules/storage/aws_s3` |
| **File** | `variables.tf` |
| **Issue** | `bucket_defaults` public access block flags default to `true` (correct), but callers can override all four flags to `false` without any validation guardrail, removing all public access protections. |
| **Fix** | Add validation enforcing all four flags (`block_public_acls`, `block_public_policy`, `ignore_public_acls`, `restrict_public_buckets`) must remain `true`. |

---

### 🟡 Medium

---

#### M-01 — RDS/DocumentDB: `deletion_protection` Defaults to `false`

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Modules** | `modules/databases/relational/aws_rds`, `modules/databases/non-relational/aws_documentdb` |
| **File** | `variables.tf` |
| **Issue** | `deletion_protection = optional(bool, false)` allows accidental database deletion. AWS best practice for production databases is `deletion_protection = true`. |
| **Fix** | Change default from `false` to `true`: `deletion_protection = optional(bool, true)` |

---

#### M-02 — KMS: Key Rotation Defaults to `false`

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Module** | `modules/security_identity_compliance/aws_kms` |
| **File** | `locals.tf` line 25 |
| **Issue** | `enable_key_rotation = coalesce(k.enable_key_rotation, false)` — AWS best practice recommends enabling annual key rotation for symmetric keys. Defaulting to `false` means most KMS keys will not rotate unless explicitly configured. |
| **Fix** | Change default to `true`: `coalesce(k.enable_key_rotation, true)` (note: already guarded against non-symmetric keys on line 23). |

---

#### M-03 — API Gateway: Route `authorization_type` Defaults to `"NONE"`

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Module** | `modules/networking_content_delivery/aws_api_gateway` |
| **File** | `main.tf` line 57 |
| **Issue** | `authorization_type = try(each.value.authorization_type, "NONE")` — routes default to unauthenticated access. A forgotten `authorization_type` in configuration creates an open API endpoint. |
| **Fix** | Remove the default so `authorization_type` is required per route, or add validation requiring an explicit value. |

---

#### M-04 — RDS: `ignore_changes = [password]` Without Documented Rotation Strategy

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Module** | `modules/databases/relational/aws_rds` |
| **File** | `main.tf` (lifecycle block) |
| **Issue** | Password changes are ignored in lifecycle, preventing Terraform drift detection. If Secrets Manager rotation updates the password, Terraform will not reconcile the state. |
| **Fix** | Add explicit comment in code and README explaining the rotation strategy (e.g., "Password managed by Secrets Manager rotation — see `aws_secretsmanager_secret_rotation` resource"). |

---

#### M-05 — Network Firewall: Nested `sync_states` Access May Fail Silently

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Module** | `modules/security_identity_compliance/aws_network_firewall` |
| **File** | `outputs.tf` lines 55–70 |
| **Issue** | Firewall endpoint outputs use `try(tolist(...), [])` and `try(ss.attachment[0], null)`. The nested structure assumes AWS returns a specific response format. If the API shape changes, outputs silently return `null` with no visibility. |
| **Fix** | Add output descriptions explaining expected structure and add logging/documentation for when outputs are empty. |

---

#### M-06 — Tags Variable: No Minimum Tag Enforcement

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Modules** | All 45 complete modules |
| **File** | `variables.tf` (`variable "tags"`) |
| **Issue** | All modules define `variable "tags" { default = {} }`. If callers omit tags, resources are created with no organizational or billing tags. This breaks cost allocation and governance policies. |
| **Fix** | Add validation requiring at minimum `Environment` and `Owner` tags: `condition = contains(keys(var.tags), "Environment") && contains(keys(var.tags), "Owner")` |

---

#### M-07 — DocumentDB: Default Engine Version May Become Unsupported

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Module** | `modules/databases/non-relational/aws_documentdb` |
| **File** | `variables.tf` |
| **Issue** | `engine_version` defaults to `"5.0"`. As AWS deprecates older DocumentDB versions, this default may produce clusters on unsupported versions without any warning. |
| **Fix** | Add validation enforcing `engine_version >= "4.0"`, and update the default to the current supported version. |

---

### 🔵 Low

---

#### L-01 — Internet Gateway: `count`-Based Pattern Limits Scalability

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Module** | `modules/networking_content_delivery/aws_internet_gateway` |
| **File** | `main.tf`, `variables.tf` |
| **Issue** | Uses `count` to optionally create a single IGW. The `count` pattern is less reusable than `for_each` when managing multiple IGWs or when the conditional changes. Outputs correctly use `try()` for the `[0]` access — no immediate risk. |
| **Fix** | Refactor to `for_each` pattern for scalability, or document the single-IGW-per-call design limitation clearly in README. |

---

#### L-02 — `tags` Variable Default Empty — No Warning in Description

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Modules** | All 45 complete modules |
| **File** | `variables.tf` |
| **Issue** | `variable "tags" { default = {} }` provides no warning that omitting tags affects billing and governance visibility. |
| **Fix** | Update all `tags` variable descriptions to include a warning: `"WARNING: Omitting tags will affect cost allocation and compliance visibility."` |

---

#### L-03 — S3 Replication: `destination_bucket_arn` Not Validated as ARN Format

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Module** | `modules/storage/aws_s3` |
| **File** | `variables.tf` |
| **Issue** | `destination_bucket_arn` in replication rule configuration accepts any string. An invalid S3 ARN format passes `terraform validate` but fails during `terraform apply` with an AWS API error. |
| **Fix** | Add validation: `can(regex("^arn:aws:s3:::[a-z0-9][a-z0-9.-]*$", rule.destination_bucket_arn))` |

---

#### L-04 — No Per-Module CHANGELOG or Version Tracking

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Modules** | All 45 complete modules |
| **File** | No `CHANGELOG.md` per module |
| **Issue** | Modules lack individual change history. Consumers cannot easily identify breaking changes when upgrading to a newer version of a specific module. |
| **Fix** | Create per-module `CHANGELOG.md` files documenting breaking changes, deprecations, and upgrade paths. |

---

## CI/CD Assessment

**File:** `.github/workflows/terraform-modules-ci.yml`

| Check | Status | Notes |
|-------|--------|-------|
| Trigger on push/PR | ✅ | Both `push` and `pull_request` trigger CI |
| Terraform version | ✅ `1.14.8` | Current latest stable within constraint |
| `terraform init \|\| true` | 🔴 Critical | Init failures are suppressed — broken modules pass silently |
| `terraform validate` | ✅ | Running per module |
| `checkov \|\| true` | 🔴 Critical | Security scan failures are ignored — no blocking |
| `tfsec` | ✅ | `\|\| true` removed in prior fix — failures now block CI |
| Timeout | ✅ `20min` | Reasonable for full module scan |
| Integration tests | ❌ Missing | No Terratest or tftest coverage |

---

## Version / Provider Hygiene Assessment

| Module Group | `required_version` | AWS Provider `version` | Status |
|---|---|---|---|
| Storage (aws_s3, aws_ebs, aws_backup, aws-storage-gateway) | `>= 1.14.0, < 2.0.0` | `>= 6.0, < 7.0` | ✅ Correct |
| Analytics, App Integration, Monitoring, Networking, Security, Mgmt | `>= 1.14.0, < 2.0.0` | `>= 6.0, < 7.0` | ✅ Correct |
| **Compute (9 sub-modules)** | `>= 6.0, < 7.0` ❌ | `>= 6.0, < 7.0` | 🔴 Invalid Terraform version |
| **Databases (5 modules)** | `>= 6.0, < 7.0` ❌ | `>= 6.0, < 7.0` | 🔴 Invalid Terraform version |

---

## Priority Action Plan

### P0 — Fix Before Merging to Main

| # | Finding | File(s) | Action |
|---|---------|---------|--------|
| 1 | C-01: Invalid Terraform version in 14 modules | `modules/compute/*/providers.tf`, `modules/databases/*/providers.tf` | Change `required_version` to `>= 1.14.0, < 2.0.0` |
| 2 | C-02: ElastiCache unsafe `cache_nodes[0]` access | `aws_elasticache/outputs.tf` | Wrap with `try(v.cache_nodes[0].address, null)` |
| 3 | C-03: Route 53 `prevent_destroy = false` | `aws_route_53/main.tf` | Change to `prevent_destroy = true` |
| 4 | C-04: CI `|| true` on checkov and terraform init | `.github/workflows/terraform-modules-ci.yml` | Remove `|| true` from both steps |

### P1 — Fix Before Next Release

| # | Finding | Action |
|---|---------|--------|
| 5 | H-01: EC2 missing region validation | Add regex validation to `aws_ec2/variables.tf` |
| 6 | H-03: Secrets Manager `secret_ids`/`secret_names` not sensitive | Add `sensitive = true` |
| 7 | H-05/H-06: RDS/Aurora `publicly_accessible` and `storage_encrypted` no validation | Add validation blocks |
| 8 | M-01: `deletion_protection` defaults to `false` | Change default to `true` for RDS and DocumentDB |
| 9 | M-02: KMS rotation defaults to `false` | Change default to `true` |
| 10 | H-02: Network Firewall CIDR validation | Add `cidrhost()` validation |

### P2 — Address in Next Sprint

| # | Finding | Action |
|---|---------|--------|
| 11 | H-04: API Gateway CORS wildcard | Add `allow_origins` validation |
| 12 | H-07: DocumentDB KMS ARN validation | Add ARN format validation |
| 13 | H-08: S3 public access block enforcement | Add variable validation |
| 14 | M-03: API Gateway auth defaults to `"NONE"` | Require explicit authorization_type |
| 15 | M-06: Tags not enforced | Add minimum tag validation (Environment, Owner) |

---

## Positive Findings

| Area | Status |
|------|--------|
| README.md coverage | ✅ All 45 complete modules have README.md |
| Tag merging pattern | ✅ All modules use `locals.tf` → `common_tags = merge(var.tags, ...)` |
| S3 encryption defaults | ✅ SSE enabled by default, bucket key enabled |
| S3 versioning defaults | ✅ Versioning enabled by default |
| S3 public access block | ✅ All four flags default to `true` |
| DocumentDB `sensitive` output | ✅ `clusters` output marked `sensitive = true` |
| Network Firewall `update_token` | ✅ Marked `sensitive = true` |
| MQ `publicly_accessible` | ✅ Defaults to `false` |
| tfsec CI enforcement | ✅ `|| true` removed — tfsec failures block CI |
| Database backup defaults | ✅ RDS 7-day retention, DocumentDB 35-day retention |
| Lambda/IGW try() wrapping | ✅ `count`-based resources safely wrapped with `try()` |
| AWS provider version | ✅ All complete modules pinned to `>= 6.0, < 7.0` |

---

*Assessment generated on 2026-04-04 against branch `main` of `aws.tf-modules`.*
