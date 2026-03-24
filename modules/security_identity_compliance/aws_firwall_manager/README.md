# Terraform AWS Firewall Manager Module

> Back to [Module-Service-List](../../../../Module-Service-List.md) · [AWS Firewall Manager Overview](aws-firewall-manager.md) · [Wrapper Plan](../../../../tf-plans/aws_firewall_manager/README.md)

This module creates and manages [AWS Firewall Manager](https://aws.amazon.com/firewall-manager/) resources, including optional FMS administrator-account registration and one or more security policies. It uses `for_each`-based scaling so any number of policies can be independently added, updated, or removed without affecting the rest.

> ⚠️ **Cost Warning:** Each active Firewall Manager policy costs **$100/month per region**. The `enable_admin_account` flag defaults to `false` as a safety gate — only set it to `true` from the AWS Organizations management account or a delegated administrator account.

---

## Architecture

```
                        AWS Organizations
                               │
              ┌────────────────┴────────────────┐
              │      Management / Delegated     │
              │        Admin Account            │
              │   aws_fms_admin_account (opt.)  │
              └────────────────┬────────────────┘
                               │
              ┌────────────────▼────────────────┐
              │     Firewall Manager Service    │
              │                                 │
              │  ┌────────────┐ ┌─────────────┐ │
              │  │  Policy A  │ │  Policy B   │ │
              │  │ (WAFV2)    │ │(SHIELD_ADV) │ │
              │  └─────┬──────┘ └──────┬──────┘ │
              └────────┼───────────────┼────────┘
                       │  auto-applied │
          ┌────────────┼───────────────┼─────────────┐
          │       Member Accounts (OU or explicit)   │
          │                                          │
          │  ┌──────────────┐   ┌─────────────────┐  │
          │  │  ALB (WAF    │   │ ALB / CF / EIP  │  │
          │  │  ACL auto-   │   │ (Shield Advanced│  │
          │  │  attached)   │   │  protection)    │  │
          │  └──────────────┘   └─────────────────┘  │
          └──────────────────────────────────────────┘
```

**Flow:**
1. (Optional) `aws_fms_admin_account` designates this account as the FMS administrator.
2. Each `aws_fms_policy` is created and scoped to accounts/OUs via `include_map` / `exclude_map`.
3. FMS automatically applies and enforces the policy across all in-scope member accounts.
4. Non-compliant resources are flagged — or auto-remediated when `remediation_enabled = true`.

---

## Supported Policy Types

| Type | Resources | Use Case |
|------|-----------|----------|
| `WAFV2` | ALB, API Gateway, CloudFront | Attach managed/custom WAF rules org-wide |
| `SHIELD_ADVANCED` | ALB, CloudFront, EIP, Route 53 | DDoS protection with auto-response |
| `SECURITY_GROUPS_COMMON` | EC2, ENI | Enforce required SG rules |
| `SECURITY_GROUPS_AUDIT` | EC2, ENI | Audit/alert on overly-permissive SGs |
| `NETWORK_FIREWALL` | VPC | Deploy Network Firewall endpoints per VPC |
| `DNS_FIREWALL` | VPC | DNS query filtering via Route 53 Resolver |
| `NETWORK_ACL_COMMON` | Subnet | Enforce NACL rules across subnets |
| `THIRD_PARTY_FIREWALL` | VPC | Centrally managed partner firewall (e.g. Palo Alto) |

---

## Usage

```hcl
module "firewall_manager" {
  source = "../modules/security_identity_compliance/aws_firwall_manager"

  region               = "us-east-1"
  enable_admin_account = false   # set true only from management/delegated admin account
  admin_account_id     = null    # null = current account

  policies = [
    {
      name                               = "wafv2-alb-prod"
      description                        = "WAFv2 Common Rule Set on all prod ALBs."
      remediation_enabled                = true
      delete_unused_fm_managed_resources = true
      resource_type_list                 = ["AWS::ElasticLoadBalancingV2::LoadBalancer"]
      security_service_type              = "WAFV2"
      managed_service_data               = "{\"type\":\"WAFV2\",\"preProcessRuleGroups\":[{\"ruleGroupArn\":null,\"overrideAction\":{\"type\":\"NONE\"},\"managedRuleGroupIdentifier\":{\"vendorName\":\"AWS\",\"managedRuleGroupName\":\"AWSManagedRulesCommonRuleSet\"},\"ruleGroupType\":\"ManagedRuleGroup\",\"excludeRules\":[]}],\"postProcessRuleGroups\":[],\"defaultAction\":{\"type\":\"ALLOW\"},\"overrideCustomerWebACLAssociation\":false}"
      include_map_accounts               = ["123456789012"]
    },
    {
      name                  = "shield-advanced-global"
      description           = "Shield Advanced for ALBs and EIPs org-wide."
      remediation_enabled   = true
      resource_type_list    = ["AWS::ElasticLoadBalancingV2::LoadBalancer", "AWS::EC2::EIP"]
      security_service_type = "SHIELD_ADVANCED"
      managed_service_data  = "{\"type\":\"SHIELD_ADVANCED\",\"automaticResponseConfiguration\":{\"automaticResponseStatus\":\"ENABLED\",\"automaticResponseAction\":\"COUNT\"},\"overrideCustomerWebaclClassic\":false}"
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

---

## Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `region` | `string` | AWS region where FMS resources are managed. |
| `policies[*].name` | `string` | Display name of the FMS policy. |
| `policies[*].security_service_type` | `string` | Policy type (WAF, WAFV2, SHIELD_ADVANCED, etc.). |

---

## Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_admin_account` | `bool` | `false` | Register this account as the FMS administrator. |
| `admin_account_id` | `string` | `null` | Account ID to register; null uses the current account. |
| `policies` | `list(object)` | `[]` | List of FMS policy objects (see below). |
| `tags` | `map(string)` | `{}` | Common tags applied to all resources. |
| `policies[*].description` | `string` | `""` | Human-readable policy description. |
| `policies[*].exclude_resource_tags` | `bool` | `false` | Exclude resources matching `resource_tags` when true. |
| `policies[*].remediation_enabled` | `bool` | `false` | Auto-remediate non-compliant resources. |
| `policies[*].delete_unused_fm_managed_resources` | `bool` | `false` | Delete managed resources when policy is deleted. |
| `policies[*].resource_type` | `string` | `null` | Single AWS resource type (mutually exclusive with `resource_type_list`). |
| `policies[*].resource_type_list` | `list(string)` | `null` | List of AWS resource types. |
| `policies[*].resource_tags` | `map(string)` | `null` | Tags used to scope resources in/out of policy. |
| `policies[*].managed_service_data` | `string` | `null` | JSON string with service-specific policy configuration. |
| `policies[*].include_map_accounts` | `list(string)` | `null` | Account IDs to include in policy scope. |
| `policies[*].include_map_orgunits` | `list(string)` | `null` | OU IDs to include in policy scope. |
| `policies[*].exclude_map_accounts` | `list(string)` | `null` | Account IDs to exclude from policy scope. |
| `policies[*].exclude_map_orgunits` | `list(string)` | `null` | OU IDs to exclude from policy scope. |
| `policies[*].tags` | `map(string)` | `null` | Per-policy tags merged on top of `common_tags`. |

---

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `admin_account_id` | `string` | FMS administrator account ID (when `enable_admin_account = true`). |
| `policy_ids` | `map(string)` | Map of policy name → FMS policy ID. |
| `policy_arns` | `map(string)` | Map of policy name → FMS policy ARN. |
| `policy_names` | `list(string)` | List of all created policy names. |

---

## Notes

- **AWS Organizations** must be enabled and this module must run from the management account or a delegated FMS administrator account.
- The `managed_service_data` JSON format differs by policy type — refer to the [AWS FMS API documentation](https://docs.aws.amazon.com/fms/2018-01-01/APIReference/API_SecurityServicePolicyData.html) for the exact schema per type.
- Omitting both `include_map` and `exclude_map` applies the policy to the **entire organization**.
- `resource_type` and `resource_type_list` are mutually exclusive; supply only one per policy.
- See the [AWS Firewall Manager pricing page](https://aws.amazon.com/firewall-manager/pricing/) for current per-policy costs.

---

## Resources Created

| Resource | Terraform Resource |
|----------|--------------------|
| FMS administrator account | [`aws_fms_admin_account`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fms_admin_account) |
| FMS security policy | [`aws_fms_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fms_policy) |
