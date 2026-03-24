# AWS Network Firewall — Wrapper Plan

> **Module:** [`modules/security_identity_compliance/aws_network_firewall`](../../modules/security_identity_compliance/aws_network_firewall/README.md) &nbsp;|&nbsp; **Wrapper path:** `tf-plans/aws_network_firewall`

This wrapper plan demonstrates production-ready usage of the AWS Network Firewall module. It deploys a full egress inspection stack: stateless forwarding rules, a stateful domain allowlist, Suricata IPS rules, and dual-destination logging.

---

## Wrapper Files

| File | Purpose |
|---|---|
| `main.tf` | Invokes the root module; passes all variables through |
| `variables.tf` | Declares wrapper input variables (mirror of root module) |
| `provider.tf` | AWS provider configuration |
| `outputs.tf` | Exposes module outputs including `firewall_endpoint_ids` |
| `terraform.tfvars` | Example values covering two deployment patterns |

---

## Quick Start

```bash
# 1. Initialise providers and download modules
terraform init

# 2. Preview the execution plan (no changes applied)
terraform plan -var-file=terraform.tfvars

# 3. Apply the configuration
terraform apply -var-file=terraform.tfvars

# 4. Retrieve endpoint IDs for route table wiring
terraform output firewall_endpoint_ids
```

---

## Architecture Overview

```
  Internet
      │
  ┌───▼──────────────────────────────────┐
  │         Internet Gateway             │
  │   Gateway RT:                        │
  │   10.0.1.0/24 → vpce-A (AZ-1)        │
  │   10.0.3.0/24 → vpce-B (AZ-2)        │
  └───┬──────────────────────────────────┘
      │
  ┌───▼────────────── VPC ───────────────────────────────────┐
  │                                                          │
  │   ┌──────────────────────────────────────────────────┐   │
  │   │            AWS Network Firewall                  │   │
  │   │                                                  │   │
  │   │  Policy: prod-egress-policy                      │   │
  │   │  ┌────────────────────────────────────────────┐  │   │
  │   │  │ Stateless (evaluated first)                │  │   │
  │   │  │  P10: drop-inbound-ssh       → aws:drop    │  │   │
  │   │  │  P20: forward-web-stateless  → aws:fwd_sfe │  │   │
  │   │  │  Default                     → aws:fwd_sfe │  │   │
  │   │  │                                            │  │   │
  │   │  │ Stateful (evaluated after forwarding)      │  │   │
  │   │  │  allow-internal-services  (5-tuple PASS)   │  │   │
  │   │  │  egress-domain-allowlist  (ALLOWLIST)      │  │   │
  │   │  │  threat-detection-suricata (IPS ALERT)     │  │   │
  │   │  └────────────────────────────────────────────┘  │   │
  │   └──────────────────────────────────────────────────┘   │
  │                                                          │
  │    AZ-1 (us-east-1a)          AZ-2 (us-east-1b)          │
  │  ┌────────────────────┐   ┌────────────────────┐         │
  │  │  FW Subnet         │   │  FW Subnet         │         │
  │  │  [vpce-A endpoint] │   │  [vpce-B endpoint] │         │
  │  │  RT: 0/0 → IGW     │   │  RT: 0/0 → IGW     │         │
  │  └─────────┬──────────┘   └─────────┬──────────┘         │
  │            │                        │                     
  │  ┌─────────▼──────────┐   ┌─────────▼──────────┐         │
  │  │  App Subnet        │   │  App Subnet        │         │
  │  │  10.0.1.0/24       │   │  10.0.3.0/24       │         │
  │  │  RT: 0/0 → vpce-A  │   │  RT: 0/0 → vpce-B  │         │
  │  └────────────────────┘   └────────────────────┘         │
  └──────────────────────────────────────────────────────────┘
                           │
               ┌───────────▼─────────────┐
               │        Logging          │
               │  FLOW  → CloudWatch Logs│
               │  ALERT → S3 Bucket      │
               └─────────────────────────┘
```

---

## Deployment Patterns in terraform.tfvars

### Pattern 1 — Production Egress Firewall (active)

A two-AZ HA deployment with:
- **Stateless rule groups** — drop inbound SSH; forward HTTP/HTTPS to stateful engine
- **Domain allowlist** — permit egress only to approved AWS and corporate domains
- **Suricata IPS rules** — alert on SSH/RDP brute-force and suspicious DNS queries
- **5-tuple pass rules** — explicitly pass internal service-mesh traffic
- **Dual logging** — FLOW logs to CloudWatch Logs; ALERT logs to S3

### Pattern 2 — Dev/Staging Minimal Firewall (commented out)

Single-AZ, single-subnet deployment. Reuses the production policy. Uncomment the second entry in `firewalls` in `terraform.tfvars`.

---

## Route Table Wiring (post-apply)

After `terraform apply`, wire the endpoint IDs into VPC route tables:

```bash
# Get endpoint IDs
terraform output firewall_endpoint_ids
# Returns:
# {
#   "prod-egress" = {
#     "us-east-1a" = "vpce-0abc111111111111"
#     "us-east-1b" = "vpce-0abc222222222222"
#   }
# }
```

Then update route tables:

| Route Table | Destination | Target |
|---|---|---|
| App Subnet RT (AZ-1) | `0.0.0.0/0` | `vpce-0abc111111111111` |
| App Subnet RT (AZ-2) | `0.0.0.0/0` | `vpce-0abc222222222222` |
| FW Subnet RT (all AZs) | `0.0.0.0/0` | Internet Gateway ID |
| IGW Gateway RT | `10.0.1.0/24` | `vpce-0abc111111111111` |
| IGW Gateway RT | `10.0.3.0/24` | `vpce-0abc222222222222` |

---

## Adding More Firewalls or Rule Groups

To add a second firewall (e.g., dev environment), append a new entry to the `firewalls` list in `terraform.tfvars`. The `for_each` pattern in the module ensures existing firewalls are not affected.

To add a new rule group:
1. Add a new entry to `rule_groups` with a unique `key`.
2. Reference the new `key` in the appropriate `policies[*].stateful_rule_group_references` or `policies[*].stateless_rule_group_references`.

---

## Input Variables

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `region` | `string` | ✅ Yes | n/a | AWS region |
| `tags` | `map(string)` | No | `{}` | Common resource tags |
| `rule_groups` | `list(object)` | No | `[]` | Rule group definitions |
| `policies` | `list(object)` | No | `[]` | Firewall policy definitions |
| `firewalls` | `list(object)` | ✅ Yes | n/a | Firewall definitions |

See the [root module README](../../modules/security_identity_compliance/aws_network_firewall/README.md) for full field documentation.

---

## Outputs

| Name | Description |
|---|---|
| `firewall_arns` | Map of firewall key → ARN |
| `firewall_endpoint_ids` | Map of firewall key → AZ → `vpce-xxx` (use in route tables) |
| `policy_arns` | Map of policy key → ARN |
| `rule_group_arns` | Map of rule group key → ARN |
| `firewall_statuses` | Map of firewall key → configuration sync state |
| `firewall_update_tokens` | Map of firewall key → update token |

---

## Related Links

- [Root Module README](../../modules/security_identity_compliance/aws_network_firewall/README.md)
- [AWS Network Firewall service guide](../../modules/security_identity_compliance/aws_network_firewall/aws-network-firewall.md)
- [AWS Network Firewall Developer Guide](https://docs.aws.amazon.com/network-firewall/latest/developerguide/)
- [AWS Network Firewall Pricing](https://aws.amazon.com/network-firewall/pricing/)
- [Terraform: aws_networkfirewall_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall)
