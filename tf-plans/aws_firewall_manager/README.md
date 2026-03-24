# AWS Firewall Manager Wrapper Plan

> Back to [Module README](../../modules/security_identity_compliance/aws_firwall_manager/README.md) · [Module-Service-List](../../Module-Service-List.md)

This wrapper demonstrates end-to-end usage of the [AWS Firewall Manager module](../../modules/security_identity_compliance/aws_firwall_manager/README.md) with three representative policy configurations covering **WAFv2**, **Shield Advanced**, and **Network Firewall**.

> ⚠️ **Prerequisites:**
> 1. [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) must be enabled.
> 2. This plan must be applied from the **management account** or a [delegated administrator account](https://docs.aws.amazon.com/firewall-manager/latest/devguide/fms-administrators.html).
> 3. Review all `include_map_accounts` / `include_map_orgunits` values before applying — each active policy costs **$100/month per region**.

---

## Architecture

```
                        AWS Organizations
                               │
              ┌────────────────┴─────────────────┐
              │    Management / Delegated Admin  │
              │     tf-plans/aws_firewall_manager│
              └────────────────┬─────────────────┘
                               │ calls module
              ┌────────────────▼─────────────────┐
              │   aws_firwall_manager module     │
              │                                  │
              │  aws_fms_admin_account (opt.)    │
              │                                  │
              │  ┌───────────┐ ┌─────────────┐   │
              │  │ Policy A  │ │  Policy B   │   │
              │  │(WAFV2)    │ │(SHIELD_ADV) │   │
              │  └─────┬─────┘ └──────┬──────┘   │
              └────────┼──────────────┼──────────┘
                       │  auto-applied│
          ┌────────────┼──────────────┼─────────────┐
          │  Member Accounts (OU-scoped or explicit)│
          │                                         │
          │  ┌─────────────┐  ┌─────────────────┐   │
          │  │ ALB + WAF   │  │ ALB / CF / EIP  │   │
          │  │ ACL applied │  │ Shield Advanced │   │
          │  └─────────────┘  └─────────────────┘   │
          └─────────────────────────────────────────┘
```

---

## Files in This Wrapper

| File | Purpose |
|------|---------|
| [`main.tf`](main.tf) | Calls the root module; passes all variables through. |
| [`variables.tf`](variables.tf) | Declares all input variables (mirrors the root module). |
| [`locals.tf`](locals.tf) | Computes `created_date` for automatic tagging. |
| [`provider.tf`](provider.tf) | Provider version constraints and region wiring. |
| [`outputs.tf`](outputs.tf) | Exposes module outputs (admin account ID, policy IDs, ARNs). |
| [`terraform.tfvars`](terraform.tfvars) | Example values for three policy patterns. |

---

## Usage

```sh
cd tf-plans/aws_firewall_manager
terraform init
terraform plan
terraform apply
```

---

## Example Patterns in `terraform.tfvars`

### Policy 1 — Shield Advanced (entire organization)

Protects ALBs, CloudFront distributions, and Elastic IPs across **every member account** with Shield Advanced automatic DDoS-response in COUNT mode.

```hcl
{
  name                  = "shield-advanced-global"
  resource_type_list    = [
    "AWS::ElasticLoadBalancingV2::LoadBalancer",
    "AWS::CloudFront::Distribution",
    "AWS::EC2::EIP"
  ]
  security_service_type = "SHIELD_ADVANCED"
  remediation_enabled   = true
  managed_service_data  = "{\"type\":\"SHIELD_ADVANCED\",\"automaticResponseConfiguration\":{\"automaticResponseStatus\":\"ENABLED\",\"automaticResponseAction\":\"COUNT\"},\"overrideCustomerWebaclClassic\":false}"
  # No include/exclude maps → applies to entire org
}
```

### Policy 2 — WAFv2 (scoped to production accounts)

Attaches the **AWS Managed Rules Common Rule Set** WAFv2 Web ACL to all ALBs in the listed production account IDs only.

```hcl
{
  name                  = "wafv2-alb-managed-rules"
  resource_type_list    = ["AWS::ElasticLoadBalancingV2::LoadBalancer"]
  security_service_type = "WAFV2"
  remediation_enabled   = true
  include_map_accounts  = ["123456789012", "234567890123"]
  managed_service_data  = "{\"type\":\"WAFV2\",\"preProcessRuleGroups\":[...],\"defaultAction\":{\"type\":\"ALLOW\"}}"
}
```

### Policy 3 — Network Firewall (scoped to production OU)

Deploys AWS Network Firewall endpoints into all VPCs in the given organizational unit and enforces a stateful rule group blocking known malware domains.

```hcl
{
  name                  = "network-firewall-prod-ou"
  resource_type         = "AWS::EC2::VPC"
  security_service_type = "NETWORK_FIREWALL"
  remediation_enabled   = true
  include_map_orgunits  = ["ou-xxxx-yyyyyyyy"]
  managed_service_data  = "{\"type\":\"NETWORK_FIREWALL\", ...}"
}
```

---

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region for all FMS resources. |
| `policies[*].name` | `string` | Unique display name per policy. |
| `policies[*].security_service_type` | `string` | Policy type (WAFV2, SHIELD_ADVANCED, etc.). |

---

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_admin_account` | `bool` | `false` | Designate this account as the FMS administrator. |
| `admin_account_id` | `string` | `null` | Account to register; null = current account. |
| `policies` | `list(object)` | `[]` | List of FMS policy definitions. |
| `tags` | `map(string)` | `{}` | Common tags for all resources. |
| `policies[*].description` | `string` | `""` | Policy description. |
| `policies[*].remediation_enabled` | `bool` | `false` | Auto-remediate non-compliant resources. |
| `policies[*].exclude_resource_tags` | `bool` | `false` | Exclude tagged resources from scope. |
| `policies[*].delete_unused_fm_managed_resources` | `bool` | `false` | Delete FMS-managed resources on policy deletion. |
| `policies[*].resource_type` | `string` | `null` | Single resource type (e.g., `AWS::EC2::VPC`). |
| `policies[*].resource_type_list` | `list(string)` | `null` | Multiple resource types. |
| `policies[*].resource_tags` | `map(string)` | `null` | Tag-based resource scoping. |
| `policies[*].managed_service_data` | `string` | `null` | JSON policy configuration string. |
| `policies[*].include_map_accounts` | `list(string)` | `null` | Account IDs to include. |
| `policies[*].include_map_orgunits` | `list(string)` | `null` | OU IDs to include. |
| `policies[*].exclude_map_accounts` | `list(string)` | `null` | Account IDs to exclude. |
| `policies[*].exclude_map_orgunits` | `list(string)` | `null` | OU IDs to exclude. |
| `policies[*].tags` | `map(string)` | `null` | Per-policy override tags. |

---

## Outputs

| Output | Description |
|--------|-------------|
| `admin_account_id` | Registered FMS administrator account ID. |
| `policy_ids` | Map of policy name → FMS policy ID. |
| `policy_arns` | Map of policy name → FMS policy ARN. |
| `policy_names` | List of all policy names. |

---

## References

- [AWS Firewall Manager Documentation](https://docs.aws.amazon.com/firewall-manager/latest/devguide/what-is-aws-fms.html)
- [Terraform `aws_fms_admin_account`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fms_admin_account)
- [Terraform `aws_fms_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fms_policy)
- [FMS SecurityServicePolicyData schema](https://docs.aws.amazon.com/fms/2018-01-01/APIReference/API_SecurityServicePolicyData.html)
- [AWS Firewall Manager Pricing](https://aws.amazon.com/firewall-manager/pricing/)
