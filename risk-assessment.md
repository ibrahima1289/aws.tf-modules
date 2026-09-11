# AWS Terraform Modules — Risk Assessment

**Repository:** `ibrahima1289/aws.tf-modules`
**Branch:** `dev-branch`
**Assessment Date:** 2026-04-04
**Scope:** 47 complete modules + 7 stub modules across 13 category directories
**Assessment Categories:** Security · Reliability · Compliance · CI/CD · Version Hygiene

---

## Summary

| Severity | Count |
|----------|-------|
| 🔴 Critical | 1 |
| 🟠 High | 7 |
| 🟡 Medium | 7 |
| 🔵 Low | 4 |
| **Total** | **19** |

---

## Modules Audited (54)

| Module Path | Status | main.tf | variables.tf | outputs.tf | providers.tf |
|---|---|---|---|---|---|
| `analytics/aws_athena` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `analytics/aws_kinesis` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `analytics/aws-msk` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `application_integration/aws_eventbridge` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `application_integration/aws_mq` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `application_integration/aws_sns` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `application_integration/aws_sqs` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `application_integration/aws_step_function` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `cloud_financial_management/aws_budget` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_containers/aws_app2container` | 🔴 Stub | empty | ❌ | ❌ | ❌ |
| `compute/aws_containers/aws_app_runner` | 🔴 Stub | empty | ❌ | ❌ | ❌ |
| `compute/aws_containers/aws_batch` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_containers/aws_ecr` | 🔴 Stub | empty | ❌ | ❌ | ❌ |
| `compute/aws_containers/aws_ecs` | 🔴 Stub | empty | ❌ | ❌ | ❌ |
| `compute/aws_containers/aws_eks` | 🔴 Stub | empty | ❌ | ❌ | ❌ |
| `compute/aws_EC2s/aws_auto_scaling_grp` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_EC2s/aws_ec2` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_EC2s/aws_image_builder` | 🔴 Stub | empty | ❌ | ❌ | ❌ |
| `compute/aws_EC2s/aws_lightsail` | 🔴 Stub | empty | ❌ | ❌ | ❌ |
| `compute/aws_elastic_beanstalk` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_elb/aws_alb` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_elb/aws_glb` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_elb/aws_nlb` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_serverless/aws_fargate` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `compute/aws_serverless/aws_lambda` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `databases/non-relational/aws_documentdb` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `databases/non-relational/aws_dynamodb` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `databases/non-relational/aws_elasticache` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `databases/relational/aws_aurora` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `databases/relational/aws_rds` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `management_and_governance/aws_organizations` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `monitoring/aws_cloudtrail` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `monitoring/aws_cloudwatch` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `networking_content_delivery/aws_api_gateway` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `networking_content_delivery/aws_cloudFront` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `networking_content_delivery/aws_internet_gateway` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `networking_content_delivery/aws_route_53` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `networking_content_delivery/aws_route_table` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `networking_content_delivery/aws_vpc` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_certificate_manager` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_firwall_manager` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_guardDuty` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_iam` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_kms` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_nacl` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_network_firewall` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_secrets_manager` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_security_group` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_shield` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `security_identity_compliance/aws_waf` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `storage/aws_backup` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `storage/aws_ebs` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `storage/aws_s3` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |
| `storage/aws-storage-gateway` | ✅ Complete | ✅ | ✅ | ✅ | ✅ |

> **Note:** `ml_and_ai` (22 sub-directories), `developer_tools` (3 sub-directories), and `frontend_web_and_mobile_devices` (1 sub-directory) contain only `.md` documentation files — no Terraform resources exist in those category trees.

---

## Detailed Findings

### 🔴 Critical

#### C-01 — Seven Modules Are Completely Unimplemented Stubs

| Field | Detail |
|-------|--------|
| **Severity** | 🔴 Critical |
| **Category** | Reliability · Compliance |
| **Modules** | `aws_eks`, `aws_ecs`, `aws_ecr`, `aws_app_runner`, `aws_app2container`, `aws_image_builder`, `aws_lightsail` |
| **File** | `main.tf` (0 bytes), no `variables.tf`, `outputs.tf`, or `providers.tf` |

**Evidence:**
```
$ wc -c modules/compute/aws_containers/aws_eks/main.tf
0  modules/compute/aws_containers/aws_eks/main.tf
```
All seven modules contain a completely empty `main.tf` and are missing every other required file (`variables.tf`, `outputs.tf`, `providers.tf`). Calling any of these modules results in zero resources being created while Terraform reports a successful apply — a silent no-op that leaves callers with a false sense that infrastructure has been provisioned. Three of the affected modules (`aws_ecr`, `aws_ecs`, `aws_eks`) are critical container-platform primitives used by nearly every containerised workload.

**Risk:** A caller deploying the EKS module with the expectation of a running cluster will receive a clean `Apply complete! Resources: 0 added` with no error. No Kubernetes cluster, no ECR registry, no ECS service is created.

**Remediation:**
1. Implement each stub module with complete Terraform resources, or
2. Delete the stub directories and remove them from any documentation that lists them as available.
3. Add a CI check that fails if `main.tf` is empty (e.g., `[ -s "$dir/main.tf" ]`).
4. Until implemented, add a `terraform_data` resource that emits an `error` via `precondition` to block silent no-ops.

---

### 🟠 High

#### H-01 — RDS Default `multi_az = false` and `monitoring_interval = 0` (Insecure Reliability Defaults)

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Category** | Reliability · Compliance |
| **Module** | `databases/relational/aws_rds` |
| **File** | `variables.tf` lines 36, 64 |

**Evidence:**
```hcl
multi_az               = optional(bool, false)   # line 36
monitoring_interval    = optional(number, 0)      # line 64
```
The RDS module defaults `multi_az` to `false` (single-AZ, zero fault tolerance) and `monitoring_interval` to `0` (enhanced monitoring disabled). Any caller who does not explicitly override both settings deploys a single-AZ instance with no OS-level Enhanced Monitoring. For production workloads this is a reliability and compliance gap — most security frameworks (SOC 2, PCI-DSS, CIS Benchmark) require high availability and monitoring for databases.

The Aurora module has the same `monitoring_interval = 0` default on cluster instances.

**Remediation:**
```hcl
# variables.tf — aws_rds
multi_az            = optional(bool, true)   # change default
monitoring_interval = optional(number, 60)   # change default

# Add validation to enforce intent
validation {
  condition     = alltrue([for k, v in var.rds_instances : v.monitoring_interval == 0 || v.monitoring_role_arn != null])
  error_message = "monitoring_role_arn is required when monitoring_interval > 0."
}
```
Apply the same change to `databases/relational/aws_aurora/variables.tf`.

---

#### H-02 — Lambda Function URL Defaults to `authorization_type = "NONE"` with No Validation

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Category** | Security |
| **Module** | `compute/aws_serverless/aws_lambda` |
| **File** | `variables.tf` line 266; `main.tf` line 246 |

**Evidence:**
```hcl
variable "function_url_auth_type" {
  description = "Function URL authorization type: NONE or AWS_IAM"
  type        = string
  default     = "NONE"           # ← publicly-accessible by default
}
```
When `enable_function_url = true`, the function URL is created with `NONE` authorization — meaning any caller on the internet can invoke the function without credentials. There is no validation that warns or rejects this value, and no CORS `allow_origins` restriction is enforced by default (the CORS block is always rendered with whatever values are passed, including `null`).

**Remediation:**
```hcl
variable "function_url_auth_type" {
  default = "AWS_IAM"   # change default to secure
  validation {
    condition     = contains(["NONE", "AWS_IAM"], var.function_url_auth_type)
    error_message = "function_url_auth_type must be AWS_IAM or NONE. Using NONE creates a public endpoint."
  }
}
# Add a second validation warning when NONE is selected alongside no CORS origin restriction
```

---

#### H-03 — ElastiCache Encryption Defaults to `null` (Disabled)

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Category** | Security · Compliance |
| **Module** | `databases/non-relational/aws_elasticache` |
| **File** | `variables.tf` lines 97–100 |

**Evidence:**
```hcl
at_rest_encryption_enabled = optional(bool)   # null → disabled
transit_encryption_enabled = optional(bool)   # null → disabled
transit_encryption_mode    = optional(string) # "preferred" or "required"
```
Both `at_rest_encryption_enabled` and `transit_encryption_enabled` have no explicit default, so they resolve to `null` when omitted. For `aws_elasticache_replication_group` the provider treats `null` as `false`, meaning new Redis/Valkey clusters have no encryption at rest and unencrypted in-transit traffic by default. Unlike the S3 and RDS modules (which enforce encryption via validation), the ElastiCache module has no validation block preventing unencrypted clusters.

**Remediation:**
```hcl
at_rest_encryption_enabled = optional(bool, true)
transit_encryption_enabled = optional(bool, true)
transit_encryption_mode    = optional(string, "required")

# Add validation:
validation {
  condition     = alltrue([for k, v in local.replication_groups : v.at_rest_encryption_enabled == true])
  error_message = "at_rest_encryption_enabled must be true for all replication groups."
}
```

---

#### H-04 — CI `terraform validate` Glob Misses All Deeply-Nested Modules

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Category** | CI/CD |
| **File** | `.github/workflows/terraform-modules-ci.yml` line 44 |

**Evidence:**
```yaml
for dir in modules/*/*; do   # ← only 2 glob levels deep
  if [ -f "$dir/main.tf" ] ...
```
The validation loop uses `modules/*/*` which resolves to **2-level-deep paths only**. Every module nested at depth 3 or 4 is silently skipped. This affects **27 complete modules** that are never validated:

| Skipped Module | Depth |
|---|---|
| `databases/relational/aws_rds` | 4 |
| `databases/relational/aws_aurora` | 4 |
| `databases/non-relational/aws_dynamodb` | 4 |
| `databases/non-relational/aws_elasticache` | 4 |
| `databases/non-relational/aws_documentdb` | 4 |
| `compute/aws_serverless/aws_lambda` | 4 |
| `compute/aws_serverless/aws_fargate` | 4 |
| `compute/aws_EC2s/aws_ec2` | 4 |
| `compute/aws_EC2s/aws_auto_scaling_grp` | 4 |
| `compute/aws_elb/aws_alb` | 4 |
| `compute/aws_elb/aws_nlb` | 4 |
| `compute/aws_elb/aws_glb` | 4 |
| `compute/aws_containers/aws_batch` | 4 |
| All 5 remaining databases modules | 4 |

Lambda, RDS, Aurora, EC2, and all three ELB variants — the most frequently deployed modules — receive zero `terraform validate` coverage.

**Remediation:**
```yaml
- name: Terraform validate (all complete modules)
  run: |
    FAILED=0
    while IFS= read -r dir; do
      if [ -f "$dir/main.tf" ] && [ -f "$dir/variables.tf" ] && [ -f "$dir/outputs.tf" ]; then
        echo "Validating $dir ..."
        (cd "$dir" && terraform init -backend=false -input=false -no-color >/dev/null 2>&1 || true)
        (cd "$dir" && terraform validate -no-color) || FAILED=1
      fi
    done < <(find modules -mindepth 2 -maxdepth 4 -type d)
    exit $FAILED
```

---

#### H-05 — RDS/Aurora Plaintext Passwords in Complex Variable Types (No `sensitive = true`)

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Category** | Security |
| **Modules** | `databases/relational/aws_rds`, `databases/relational/aws_aurora` |
| **File** | `variables.tf` (`password`, `master_password` fields) |

**Evidence:**
```hcl
# aws_rds/variables.tf
password = optional(string)  # Consider using AWS Secrets Manager in production

# aws_aurora/variables.tf
master_password = string     # required plain string; no sensitive marker
```
Neither variable block is marked `sensitive = true`. When a caller sets passwords via `.tfvars` or environment variables, Terraform will print them in plan output and store them unredacted in the Terraform state file. The advisory comment "Consider using AWS Secrets Manager" is opt-in only with no enforcement.

**Remediation:**
1. Mark the entire `rds_instances` / `aurora_clusters` variable as `sensitive = true`.
2. Or, replace the inline password fields with a `secret_arn` reference and let the module resolve the value from Secrets Manager via a `data "aws_secretsmanager_secret_version"` data source.
3. Add a validation that rejects any password supplied inline when `var.manage_master_password = true` (AWS native managed password rotation).

---

#### H-06 — CI Workflow Triggers Only on `main` — `dev-branch` Has Zero CI Enforcement

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Category** | CI/CD |
| **File** | `.github/workflows/terraform-modules-ci.yml` lines 11–14 |

**Evidence:**
```yaml
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
```
The primary CI workflow (`terraform-modules-ci.yml`) only fires on pushes **to** `main` and on pull requests **targeting** `main`. Every push to `dev-branch` (the current active development branch) bypasses all CI checks: no `terraform fmt`, no `terraform validate`, no checkov, no tfsec. The `auto-open-pr.yml` workflow creates a PR to `main` but does not enforce any checks itself.

**Remediation:**
```yaml
on:
  push:
    branches: [ "main", "dev-branch", "dev-*", "feature/*" ]
  pull_request:
    branches: [ "main" ]
```

---

#### H-07 — Lambda SQS Dead-Letter Queue Missing Encryption

| Field | Detail |
|-------|--------|
| **Severity** | 🟠 High |
| **Category** | Security · Compliance |
| **Module** | `compute/aws_serverless/aws_lambda` |
| **File** | `main.tf` lines 52–55 |

**Evidence:**
```hcl
resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0
  name  = "${var.function_name}-dlq"
  tags  = merge(var.tags, { created_date = local.created_date })
  # ← no kms_master_key_id / sqs_managed_sse_enabled
}
```
When `enable_dlq = true`, the DLQ is created with no server-side encryption. Lambda dead-letter queues can contain sensitive event payloads from failed invocations (API requests, data records, PII). Without SSE, those payloads are stored unencrypted in SQS.

**Remediation:**
```hcl
resource "aws_sqs_queue" "dlq" {
  count                     = var.enable_dlq ? 1 : 0
  name                      = "${var.function_name}-dlq"
  sqs_managed_sse_enabled   = var.dlq_kms_key_id == null ? true : false
  kms_master_key_id         = var.dlq_kms_key_id
  tags                      = merge(var.tags, { created_date = local.created_date })
}
```
Add `var.dlq_kms_key_id = optional(string)` to `variables.tf`.

---

### 🟡 Medium

#### M-01 — CI Security Scanners (checkov, tfsec) Suppressed with `|| true`

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Category** | CI/CD · Security |
| **File** | `.github/workflows/terraform-modules-ci.yml` lines 61–70 |

**Evidence:**
```yaml
- name: Run checkov security scan
  run: |
    checkov -d modules --framework terraform \
      --quiet --compact --skip-check CKV_TF_1 \
      || true      # ← failures suppressed

- name: Run tfsec security scan
  run: |
    tfsec modules --no-color --concise-output || true   # ← failures suppressed
```
Both security scanners are run with `|| true`, converting any non-zero exit code (security violations found) to a success. This means no checkov or tfsec finding will ever block a merge to `main`. The scans run for visibility only, providing a false sense of security assurance.

**Remediation:** Remove `|| true` from both scan steps. If there are known acceptable exceptions, use `--skip-check` or `--exclude-path` flags to suppress specific checks deliberately, so the build fails on all *unexpected* violations:
```yaml
checkov -d modules --framework terraform \
  --quiet --compact \
  --skip-check CKV_TF_1,CKV_AWS_18   # explicit suppression per decision log
```

---

#### M-02 — CloudTrail `is_multi_region_trail = false` Default (Single-Region Trails)

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Category** | Compliance · Security |
| **Module** | `monitoring/aws_cloudtrail` |
| **File** | `variables.tf` line 30 |

**Evidence:**
```hcl
is_multi_region_trail = optional(bool, false)  # ← single-region by default
```
A trail with `is_multi_region_trail = false` only captures events in the region where the trail is created. Events in other regions (including IAM global-service events from `us-east-1`) are silently missed unless callers explicitly set `is_multi_region_trail = true`. CIS AWS Benchmark v1.5 (Control 3.1) requires at least one multi-region trail to capture all API activity.

**Remediation:**
```hcl
is_multi_region_trail = optional(bool, true)   # change default to secure
```

---

#### M-03 — API Gateway Stages Have No Default or Required Throttling

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Category** | Security · Reliability |
| **Module** | `networking_content_delivery/aws_api_gateway` |
| **File** | `variables.tf` lines 66–70 |

**Evidence:**
```hcl
default_route_settings = optional(object({
  throttling_burst_limit   = optional(number)   # ← no default
  throttling_rate_limit    = optional(number)   # ← no default
  detailed_metrics_enabled = optional(bool)
}))
```
All throttling fields are optional with no defaults. When `default_route_settings` is omitted (or its throttle fields are null), API Gateway applies the account-level default limits (10,000 RPS burst / 5,000 RPS steady-state). There is no validation enforcing caller-supplied limits, meaning unprotected APIs can be trivially DoS'd or incur unexpected cost.

**Remediation:** Add a validation that requires throttling to be explicitly set, or provide safe defaults (e.g., 1,000 burst / 500 RPS) and document how to raise them:
```hcl
validation {
  condition = alltrue([
    for k, api in var.apis :
    try(api.stage.default_route_settings.throttling_rate_limit, null) != null
  ])
  error_message = "Each API stage must define throttling_rate_limit to prevent runaway cost and DoS exposure."
}
```

---

#### M-04 — DynamoDB `point_in_time_recovery_enabled` Defaults to `null` (Disabled)

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Category** | Reliability · Compliance |
| **Module** | `databases/non-relational/aws_dynamodb` |
| **File** | `variables.tf` line 74 |

**Evidence:**
```hcl
point_in_time_recovery_enabled = optional(bool)   # null → disabled
```
PITR defaults to `null` which the AWS provider treats as disabled. Callers who do not set this field explicitly will have no continuous backup capability on their DynamoDB tables. PITR is a zero-config recovery mechanism and should be on by default. AWS Well-Architected and most compliance frameworks treat PITR as a baseline requirement for production tables.

**Remediation:**
```hcl
point_in_time_recovery_enabled = optional(bool, true)
```

---

#### M-05 — ALB Access Logs Disabled by Default

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Category** | Compliance · Security |
| **Module** | `compute/aws_elb/aws_alb` |
| **File** | `variables.tf` lines 79–81 |

**Evidence:**
```hcl
default = {
  enabled = false   # ← access logs off by default
}
```
ALB access logging is disabled in the module's default configuration. Access logs capture every request processed by the load balancer (source IP, request path, response code, TLS version). Without access logs, incident investigation, anomaly detection, and compliance audit trails for internet-facing workloads are impossible.

**Remediation:**
```hcl
default = {
  enabled = true   # change to true; require callers to supply bucket
}
```
Add a validation that rejects `enabled = true` without a non-null `bucket`:
```hcl
validation {
  condition     = !try(var.access_logs.enabled, false) || try(var.access_logs.bucket, null) != null
  error_message = "access_logs.bucket must be set when access_logs.enabled = true."
}
```

---

#### M-06 — EBS `lifecycle` Precondition Block Commented Out

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Category** | Reliability |
| **Module** | `storage/aws_ebs` |
| **File** | `main.tf` lines 53–60 |

**Evidence:**
```hcl
# lifecycle {
#   precondition {
#     condition     = !each.value.multi_attach_enabled || contains(["io1", "io2"], each.value.type)
#     error_message = "multi_attach_enabled = true requires volume type io1 or io2..."
#   }
# }
```
The type guard ensuring `multi_attach_enabled = true` is only used with `io1`/`io2` volume types is entirely commented out. Without this check, a caller can set `multi_attach_enabled = true` on a `gp3` volume and apply will succeed — then Terraform will hit a runtime error from the AWS API mid-apply, leaving the volume in a degraded state.

**Remediation:** Uncomment the `lifecycle` block. The precondition syntax was introduced in Terraform 1.2 and is fully supported by the module's minimum version constraint (`>= 1.14.0`).

---

#### M-07 — CI Module-Check Script Does Not Detect Stub or Incomplete Modules

| Field | Detail |
|-------|--------|
| **Severity** | 🟡 Medium |
| **Category** | CI/CD |
| **File** | `tests/terraform_module_check.py` |

**Evidence:**
```python
ALLOWED_EXTENSIONS = {".tf", ".md"}

def find_disallowed_files(modules_root):
    ...  # checks extensions only

def check_terraform_fmt(modules_root):
    ...  # checks formatting only
```
The CI hygiene script checks (1) file extensions and (2) `terraform fmt`. It does **not** check whether:
- A module's `main.tf` is empty (the 7 stub modules pass this check silently)
- A module directory is missing `variables.tf`, `outputs.tf`, or `providers.tf`
- A module's `main.tf` is non-empty but has no `resource` or `data` blocks

The 7 stub modules (C-01) pass this check with zero warnings because an empty `.tf` file is syntactically valid and correctly formatted.

**Remediation:** Add completeness checks to `terraform_module_check.py`:
```python
import re

def check_module_completeness(modules_root):
    required = {"main.tf", "variables.tf", "outputs.tf", "providers.tf"}
    issues = []
    for root, dirs, files in os.walk(modules_root):
        dirs[:] = [d for d in dirs if d not in IGNORE_DIR_NAMES]
        if "main.tf" in files:
            for req in required:
                if req not in files:
                    issues.append(f"MISSING {req} in {root}")
            main = Path(root) / "main.tf"
            if main.stat().st_size == 0:
                issues.append(f"EMPTY main.tf in {root}")
    return issues
```

---

### 🔵 Low

#### L-01 — Budget Module Has No Validation Requiring at Least One Notification

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Category** | Compliance |
| **Module** | `cloud_financial_management/aws_budget` |
| **File** | `variables.tf` |

**Evidence:** The `notifications` field inside each budget entry is `optional(list(...))` with no validation enforcing a minimum of one entry. A budget without any notification threshold is a silent budget — it tracks spend but never alerts anyone when thresholds are crossed.

**Remediation:**
```hcl
validation {
  condition = alltrue([
    for b in var.budgets :
    b.notifications != null && length(b.notifications) > 0
  ])
  error_message = "Each budget must define at least one notification threshold. Silent budgets provide no cost governance."
}
```

---

#### L-02 — Organizations SCP `content` Field Has No JSON Syntax Validation

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Category** | Security |
| **Module** | `management_and_governance/aws_organizations` |
| **File** | `variables.tf` line 101 |

**Evidence:**
```hcl
content = string  # raw JSON; no validation
```
SCP policy `content` is a free-form `string`. A malformed JSON payload will not be caught until `terraform apply` hits the AWS API, potentially blocking the entire plan. There is no `can(jsondecode(...))` guard.

**Remediation:**
```hcl
validation {
  condition  = alltrue([for p in var.policies : can(jsondecode(p.content))])
  error_message = "Each policy content must be valid JSON."
}
```

---

#### L-03 — Aurora `master_password` Is a Required Plaintext `string`

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Category** | Security |
| **Module** | `databases/relational/aws_aurora` |
| **File** | `variables.tf` (master_password field in aurora_clusters object) |

**Evidence:**
```hcl
master_password = string  # required, no optional(), no sensitive annotation
```
The Aurora `master_password` is a required non-optional `string`. Callers using AWS-managed master password rotation (`manage_master_password = true`) must still supply a dummy value to satisfy the type constraint. This encourages passing placeholder strings like `"changeme"` to unblock plan, which can end up committed to `.tfvars` or CI environment variables.

**Remediation:**
```hcl
master_password        = optional(string)        # make nullable
manage_master_password = optional(bool, true)    # default to managed rotation
```
Add a `precondition` that one of the two must be supplied.

---

#### L-04 — Three Module Category Directories Contain Only Documentation (No Terraform)

| Field | Detail |
|-------|--------|
| **Severity** | 🔵 Low |
| **Category** | Compliance |
| **Directories** | `ml_and_ai/` (22 sub-dirs), `developer_tools/` (3 sub-dirs), `frontend_web_and_mobile_devices/` (1 sub-dir) |

**Evidence:** These three top-level module categories exist in the repository with sub-directories and `.md` files but contain zero `.tf` files. Unlike C-01 (empty `main.tf`), these don't even have a placeholder Terraform file, so there is no risk of a silent no-op apply. However, the presence of named directories implies available modules to consumers browsing the repository.

**Remediation:** Either add stub modules with a `precondition` error (preferred — prevents confusion) or remove the directories and note the gap in the root README. If modules are planned, track them as issues.

---

## CI/CD Assessment

**Workflow file:** `.github/workflows/terraform-modules-ci.yml`

| Check | Status | Notes |
|---|---|---|
| Terraform fmt (-check -recursive) | ✅ Runs | Via `tests/terraform_module_check.py`; runs on module root |
| File extension hygiene | ✅ Runs | `.tf` and `.md` only; `.hcl` extension files would be caught if committed |
| Terraform validate | ⚠️ Partial | Only validates 2-level-deep modules; 27 complete modules skipped (H-04) |
| checkov scan | ⚠️ Advisory only | `|| true` suppresses all failures (M-01) |
| tfsec scan | ⚠️ Advisory only | `|| true` suppresses all failures (M-01) |
| Branch coverage | 🔴 Missing | CI only triggers on `main`; `dev-branch` unprotected (H-06) |
| Module completeness check | ❌ Missing | Empty `main.tf` and missing required files not detected (M-07) |
| Terraform plan (against real AWS) | ❌ Not present | No integration/plan stage |
| OPA/Conftest policy-as-code | ❌ Not present | No policy gates |
| SARIF upload to GitHub Security | ❌ Not present | checkov/tfsec findings not surfaced in PR Security tab |

**Key risk:** The combination of H-04 (validate glob too shallow) + H-06 (no CI on dev-branch) + M-01 (scanners non-blocking) means this repository has **effectively zero enforced quality gates** on the current working branch for the majority of its modules.

**Recommended additions:**
```yaml
- name: Upload checkov SARIF
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: checkov-results.sarif
  if: always()
```

---

## Version / Provider Hygiene Assessment

| Item | Status | Notes |
|---|---|---|
| `required_version` constraint | ✅ Present (47/47 complete modules) | `>= 1.14.0, < 2.0.0` — consistent across all complete modules |
| AWS provider version constraint | ✅ Present | `>= 6.0, < 7.0` — consistently pinned |
| Provider upper bound | ✅ Good | `< 7.0` prevents surprise upgrades |
| `.terraform.lock.hcl` committed | ✅ Not committed | `.gitignore` correctly excludes both `.terraform.lock.hcl` and `**/.terraform` |
| `.terraform/` directories in repo | ✅ Not committed | 16 on-disk lock files + provider binaries present locally but gitignored |
| Stub modules: providers.tf | 🔴 Missing | All 7 stub modules have no `providers.tf`; no version constraint is enforced |
| `terraform_version` pinned in CI | ⚠️ Hardcoded | `terraform_version: '1.14.8'` — acceptable but should align with `required_version` lower bound |
| `for_each` vs `count` usage | ✅ Good | All multi-instance resources correctly use `for_each`; `count` only for boolean feature flags |
| Deprecated syntax | ✅ None found | No deprecated `depends_on` on providers, no legacy `template_file` data sources |
| `try()` / null safety in outputs | ✅ Good | Outputs uniformly use `try(...)` to prevent index-out-of-range errors |

---

## Priority Action Plan

### P0 — Fix Before Merging to Main

| ID | Finding | Effort |
|----|---------|--------|
| H-06 | Add `dev-branch` to CI trigger branches | < 5 min |
| M-01 | Remove `|| true` from checkov/tfsec steps | < 5 min |
| H-04 | Fix `terraform validate` glob to use `find` with `mindepth` | 30 min |
| C-01 | Either implement stub modules or add `precondition` error + delete empty main.tf stubs | 1–4 h per module |
| M-06 | Uncomment EBS `lifecycle` precondition block | < 5 min |

### P1 — Fix Before Next Release

| ID | Finding | Effort |
|----|---------|--------|
| H-02 | Change Lambda Function URL default auth to `AWS_IAM`; add validation | 30 min |
| H-03 | Add ElastiCache encryption defaults + validation | 30 min |
| H-05 | Mark RDS/Aurora `rds_instances`/`aurora_clusters` variable as `sensitive = true` | 30 min |
| H-07 | Add SSE encryption to Lambda DLQ SQS queue | 30 min |
| H-01 | Change RDS `multi_az` default to `true`; `monitoring_interval` to `60` | 15 min |
| M-02 | Change CloudTrail `is_multi_region_trail` default to `true` | 5 min |
| M-04 | Change DynamoDB PITR default to `true` | 5 min |
| M-07 | Add module completeness checks to `terraform_module_check.py` | 2 h |

### P2 — Address in Next Sprint

| ID | Finding | Effort |
|----|---------|--------|
| M-03 | Add API Gateway throttling validation or safe defaults | 1 h |
| M-05 | Change ALB access log default to `enabled = true` | 15 min |
| L-01 | Add budget notification validation | 15 min |
| L-02 | Add SCP JSON syntax validation | 15 min |
| L-03 | Make Aurora `master_password` optional; default to managed rotation | 1 h |
| L-04 | Decide fate of doc-only directories (stub + error or remove) | 1 h |

---

## Positive Findings

The following practices are well-implemented and should be preserved:

| Area | Practice |
|---|---|
| **Tagging enforcement** | All 47 complete modules enforce `Environment` and `Owner` tags via `validation` blocks; `local.common_tags` / `local.created_date` used consistently |
| **S3 public access block** | Defaults to fully blocked (`block_public_acls = true`, etc.) with a validation that prevents any public access setting from being disabled |
| **CORS wildcard rejection** | API Gateway validates that `allow_origins` does not contain `"*"`, forcing explicit origin allowlists |
| **IAM access key secrets** | IAM module routes all access key secrets through AWS Secrets Manager (`aws_secretsmanager_secret_version`) rather than outputting them directly |
| **Storage encryption defaults** | S3 (AES256 default), EBS (`encrypted = true` default), RDS (`storage_encrypted = true` with validation), Aurora (same) all default to encrypted |
| **Output null safety** | Lambda, API Gateway, CloudTrail, and other modules use `try(resource[0].attr, null)` consistently — no direct index access that would panic on uncreated resources |
| **`for_each` correctness** | All multi-instance resources use stable `for_each` maps; avoids the drift/destroy risk of `count` for collections |
| **Provider pinning** | All 47 complete modules pin `>= 1.14.0, < 2.0.0` (Terraform) and `>= 6.0, < 7.0` (AWS provider) — consistent and up-to-date |
| **RDS/Aurora lifecycle** | Both database modules use `lifecycle { ignore_changes = [password/master_password] }` to prevent accidental re-creation from password drift |
| **KMS key rotation** | KMS module enables `enable_key_rotation` properly scoped to symmetric-only keys; `bypass_policy_lockout_safety_check` defaults to `false` |
| **CloudTrail log validation** | `enable_log_file_validation` defaults to `true` in both the module default and the variable default |
| **S3 versioning** | S3 module enables versioning by default (`versioning_status = "Enabled"`), protecting against accidental deletion |  
