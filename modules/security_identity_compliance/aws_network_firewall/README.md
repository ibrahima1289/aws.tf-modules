# AWS Network Firewall Terraform Module

> **Service:** [AWS Network Firewall](https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html) &nbsp;|&nbsp; **Module path:** `modules/security_identity_compliance/aws_network_firewall` &nbsp;|&nbsp; **Wrapper path:** [`tf-plans/aws_network_firewall`](../../../../tf-plans/aws_network_firewall/README.md)

This module creates **AWS Network Firewall** resources — rule groups, firewall policies, firewalls, and logging configurations — with full support for multi-firewall deployments, all four rule source types, and optional KMS encryption and log delivery.

---

## Architecture

```
                              Internet
                                  │
                    ┌─────────────▼──────────────┐
                    │      Internet Gateway       │
                    │                             │
                    │    Gateway Route Table      │
                    │  10.0.1.0/24 ──► vpce-A     │
                    │  10.0.3.0/24 ──► vpce-B     │
                    └─────────────┬──────────────┘
                                  │
          ┌───────────────────────▼──────────────────────────┐
          │                       VPC                        │
          │                                                  │
          │   ┌──────────────────────────────────────────┐   │
          │   │           AWS Network Firewall           │   │
          │   │                                          │   │
          │   │  Firewall Policy                         │   │
          │   │  ┌──────────────────────────────────────┐│   │
          │   │  │  Stateless RG  ──► aws:forward_to_sfe││   │
          │   │  │  Stateful RG   ──► PASS/DROP/ALERT   ││   │
          │   │  │  Default Action ──► aws:drop_strict  ││   │
          │   │  └──────────────────────────────────────┘│   │
          │   └──────────────────────────────────────────┘   │
          │                                                  │
          │        AZ-1                    AZ-2              │
          │  ┌──────────────┐      ┌──────────────┐          │
          │  │ FW Subnet    │      │ FW Subnet    │          │
          │  │ 10.0.2.0/24  │      │ 10.0.4.0/24  │          │
          │  │  ┌────────┐  │      │  ┌────────┐  │          │
          │  │  │vpce-A  │  │      │  │vpce-B  │  │          │
          │  │  └───┬────┘  │      │  └───┬────┘  │          │
          │  └──────┼───────┘      └──────┼───────┘          │
          │         │  FW Subnet RT       │                  │
          │         │  0.0.0.0/0 → IGW    │                  │
          │  ┌──────▼───────┐      ┌──────▼───────┐          │
          │  │ App Subnet   │      │ App Subnet   │          │
          │  │ 10.0.1.0/24  │      │ 10.0.3.0/24  │          │
          │  │  App RT:     │      │  App RT:     │          │
          │  │  0/0 →vpce-A │      │  0/0 →vpce-B │          │
          │  └──────────────┘      └──────────────┘          │
          └──────────────────────────────────────────────────┘
                                  │
                     ┌────────────▼──────────────┐
                     │        Logging            │
                     │  FLOW  ──► CloudWatch Logs│
                     │  ALERT ──► Amazon S3      │
                     │          Kinesis Firehose │
                     └───────────────────────────┘
```

> **Route table wiring** is not managed by this module. Use `firewall_endpoint_ids` output
> to retrieve `vpce-xxx` IDs and wire them into your route tables using the
> [Route Table module](../../../../modules/networking_content_delivery/aws_route_table/README.md).

---

## Terraform & Provider Requirements

| Requirement | Version |
|---|---|
| Terraform | `>= 1.3` (required for `optional()` with defaults in object types) |
| AWS Provider | `>= 5.0` |
| AWS Region | Set via `var.region` |

---

## Rule Source Types

Each rule group must declare a `rules_source_type` value that selects which traffic-matching syntax is used.

| `rules_source_type` | Rule Group `type` | Description |
|---|---|---|
| `STATELESS_5TUPLE` | `STATELESS` | Packet-level matching on protocol, source/destination IP, and port. No connection tracking. |
| `SURICATA_STRING` | `STATEFUL` | Raw [Suricata](https://suricata.io/)-compatible IPS rule string. Supports advanced signatures, TLS SNI, HTTP headers. |
| `DOMAIN_LIST` | `STATEFUL` | Allow or deny traffic to HTTP/HTTPS hostnames using HTTP Host header or TLS SNI field. |
| `STATEFUL_5TUPLE` | `STATEFUL` | Connection-aware 5-tuple rules with PASS, DROP, or ALERT actions. |

---

## Input Variables

### Top-level variables

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `region` | `string` | ✅ Yes | n/a | AWS region to deploy resources |
| `tags` | `map(string)` | No | `{}` | Common tags merged onto all resources |
| `rule_groups` | `list(object)` | No | `[]` | List of rule group definitions |
| `policies` | `list(object)` | No | `[]` | List of firewall policy definitions |
| `firewalls` | `list(object)` | ✅ Yes | n/a | List of firewall definitions |

---

### `rule_groups` object fields

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `key` | `string` | ✅ Yes | n/a | Unique stable identifier for `for_each` |
| `name` | `string` | ✅ Yes | n/a | AWS resource name |
| `type` | `string` | ✅ Yes | n/a | `STATELESS` or `STATEFUL` |
| `capacity` | `number` | ✅ Yes | n/a | Processing capacity units (1–30,000). Cannot be changed after creation. |
| `description` | `string` | No | `""` | Human-readable description |
| `rules_source_type` | `string` | ✅ Yes | n/a | `STATELESS_5TUPLE` \| `SURICATA_STRING` \| `DOMAIN_LIST` \| `STATEFUL_5TUPLE` |
| `stateless_rules` | `list(object)` | Conditional | `null` | Required when `rules_source_type = STATELESS_5TUPLE` |
| `rules_string` | `string` | Conditional | `null` | Required when `rules_source_type = SURICATA_STRING` |
| `domain_list` | `object` | Conditional | `null` | Required when `rules_source_type = DOMAIN_LIST` |
| `stateful_rules` | `list(object)` | Conditional | `null` | Required when `rules_source_type = STATEFUL_5TUPLE` |
| `ip_sets` | `list(object)` | No | `[]` | CIDR variable definitions (e.g., `HOME_NET`) |
| `port_sets` | `list(object)` | No | `[]` | Port variable definitions (e.g., `HTTP_PORTS`) |
| `rule_order` | `string` | No | `null` | `DEFAULT_ACTION_ORDER` or `STRICT_ORDER` (STATEFUL only) |
| `tags` | `map(string)` | No | `{}` | Resource-level tags |

#### `stateless_rules` item fields

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `priority` | `number` | ✅ Yes | n/a | Processing order — lower number evaluated first |
| `actions` | `list(string)` | ✅ Yes | n/a | `aws:pass`, `aws:drop`, `aws:forward_to_sfe`, `aws:publish_to_sns` |
| `sources` | `list(string)` | No | `["0.0.0.0/0"]` | Source CIDR blocks |
| `destinations` | `list(string)` | No | `["0.0.0.0/0"]` | Destination CIDR blocks |
| `protocols` | `list(number)` | No | `[]` | IANA protocol numbers (6=TCP, 17=UDP, 1=ICMP; empty=all) |
| `source_ports` | `list({from_port, to_port})` | No | `[]` | Source port ranges |
| `destination_ports` | `list({from_port, to_port})` | No | `[]` | Destination port ranges |
| `tcp_flags` | `list({flags, masks})` | No | `[]` | TCP flag matching (e.g., SYN-only detection) |

#### `domain_list` object fields

| Field | Type | Required | Description |
|---|---|---|---|
| `generated_rules_type` | `string` | ✅ Yes | `ALLOWLIST` (permit only) or `DENYLIST` (block matching) |
| `target_types` | `list(string)` | ✅ Yes | `HTTP_HOST` and/or `TLS_SNI` |
| `targets` | `list(string)` | ✅ Yes | Domains. Prefix with `.` to include all subdomains (e.g., `.example.com`) |

#### `stateful_rules` item fields

| Field | Type | Required | Description |
|---|---|---|---|
| `action` | `string` | ✅ Yes | `PASS`, `DROP`, or `ALERT` |
| `protocol` | `string` | ✅ Yes | `TCP`, `UDP`, `ICMP`, `HTTP`, `TLS`, `DNS`, `Any`, etc. |
| `source` | `string` | ✅ Yes | CIDR or `ANY` |
| `source_port` | `string` | ✅ Yes | Port, range (e.g., `1024:65535`), or `ANY` |
| `destination` | `string` | ✅ Yes | CIDR or `ANY` |
| `destination_port` | `string` | ✅ Yes | Port, range, or `ANY` |
| `direction` | `string` | ✅ Yes | `FORWARD` or `ANY` |
| `rule_options` | `list({keyword, settings})` | ✅ Yes | Suricata rule options — `sid` keyword is required |

---

### `policies` object fields

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `key` | `string` | ✅ Yes | n/a | Unique stable identifier |
| `name` | `string` | ✅ Yes | n/a | AWS resource name |
| `description` | `string` | No | `""` | Human-readable description |
| `stateless_default_actions` | `list(string)` | No | `["aws:forward_to_sfe"]` | Default action for unmatched packets |
| `stateless_fragment_default_actions` | `list(string)` | No | `["aws:forward_to_sfe"]` | Default action for fragmented packets |
| `stateless_rule_group_references` | `list(object)` | No | `[]` | Ordered stateless rule group bindings |
| `stateful_rule_group_references` | `list(object)` | No | `[]` | Stateful rule group bindings |
| `stateful_engine_options` | `object` | No | `null` | `{ rule_order = "STRICT_ORDER" \| "DEFAULT_ACTION_ORDER" }` |
| `stateful_default_actions` | `list(string)` | No | `[]` | Stateful defaults (STRICT_ORDER only): `aws:drop_strict`, `aws:alert_strict`, etc. |
| `policy_variables` | `map(list(string))` | No | `null` | Named IP sets for Suricata rules: `{ "HOME_NET" = ["10.0.0.0/8"] }` |
| `tls_inspection_configuration_arn` | `string` | No | `null` | ARN of TLS inspection configuration |
| `tags` | `map(string)` | No | `{}` | Resource-level tags |

#### `stateless_rule_group_references` / `stateful_rule_group_references` item fields

| Field | Type | Required | Description |
|---|---|---|---|
| `key` | `string` | Conditional | Key from `var.rule_groups` (module-managed group) |
| `resource_arn` | `string` | Conditional | ARN of an external rule group |
| `priority` | `number` | ✅ Yes (stateless) | Evaluation order — lower = first |
| `override_action` | `string` | No | `DROP_TO_ALERT` — converts PASS rules to ALERTs (stateful STRICT_ORDER only) |

---

### `firewalls` object fields

| Field | Type | Required | Default | Description |
|---|---|---|---|---|
| `key` | `string` | ✅ Yes | n/a | Unique stable identifier |
| `name` | `string` | ✅ Yes | n/a | AWS resource name |
| `vpc_id` | `string` | ✅ Yes | n/a | VPC to deploy the firewall into |
| `subnet_ids` | `list(string)` | ✅ Yes | n/a | One firewall subnet ID per AZ (for HA) |
| `firewall_policy_arn` | `string` | Conditional | `null` | ARN of an external policy |
| `firewall_policy_key` | `string` | Conditional | `null` | Key from `var.policies` |
| `delete_protection` | `bool` | No | `false` | Prevent deletion via Terraform |
| `subnet_change_protection` | `bool` | No | `false` | Prevent subnet-mapping changes |
| `firewall_policy_change_protection` | `bool` | No | `false` | Prevent policy ARN changes |
| `description` | `string` | No | `""` | Human-readable description |
| `encryption_configuration` | `object` | No | `null` | KMS encryption: `{ type = "CUSTOMER_KMS", key_id = "arn:..." }` |
| `logging` | `object` | No | `null` | Logging destinations (see below) |
| `tags` | `map(string)` | No | `{}` | Resource-level tags |

#### `logging.destinations` item fields

| Field | Type | Required | Description |
|---|---|---|---|
| `log_type` | `string` | ✅ Yes | `FLOW` (all connections) or `ALERT` (rule-match events) |
| `log_destination_type` | `string` | ✅ Yes | `CloudWatchLogs` \| `S3` \| `KinesisDataFirehose` |
| `log_destination` | `map(string)` | ✅ Yes | Destination-specific map (see examples below) |

**`log_destination` map examples:**

| Destination Type | Required Keys | Example |
|---|---|---|
| `CloudWatchLogs` | `logGroup` | `{ logGroup = "/aws/network-firewall/flow" }` |
| `S3` | `bucketName`, optional `prefix` | `{ bucketName = "my-logs", prefix = "fw/" }` |
| `KinesisDataFirehose` | `deliveryStream` | `{ deliveryStream = "my-delivery-stream" }` |

---

## Outputs

| Name | Type | Description |
|---|---|---|
| `rule_group_arns` | `map(string)` | Map of rule group key → ARN |
| `rule_group_ids` | `map(string)` | Map of rule group key → resource ID |
| `policy_arns` | `map(string)` | Map of policy key → ARN |
| `policy_ids` | `map(string)` | Map of policy key → resource ID |
| `firewall_arns` | `map(string)` | Map of firewall key → ARN |
| `firewall_ids` | `map(string)` | Map of firewall key → resource ID |
| `firewall_update_tokens` | `map(string)` | Map of firewall key → update token |
| `firewall_endpoint_ids` | `map(map(string))` | Map of firewall key → AZ → `vpce-xxx` endpoint ID |
| `firewall_statuses` | `map(string)` | Map of firewall key → sync state (`READY` / `IN_SYNC`) |

> **`firewall_endpoint_ids`** is the most important output: supply these `vpce-xxx` values as the route targets in your VPC route tables to steer traffic through the firewall.

---

## Tags

All resources receive the following tags (in addition to caller-supplied `tags`):

| Tag | Source | Example |
|---|---|---|
| `created_date` | `locals.created_date` | `2026-03-23` |
| `Name` | resource `name` field | `prod-egress-firewall` |
| any custom tags | `var.tags` + per-resource `tags` | `Environment = "prod"` |

---

## Usage Example

```hcl
module "network_firewall" {
  source = "../../modules/security_identity_compliance/aws_network_firewall"

  region = "us-east-1"
  tags   = { Environment = "prod", Team = "security" }

  # ── Rule Groups ─────────────────────────────────────────────────────────
  rule_groups = [
    # Stateless: forward all TCP:443 traffic to the stateful engine
    {
      key              = "allow-https-stateless"
      name             = "allow-https-stateless"
      type             = "STATELESS"
      capacity         = 100
      rules_source_type = "STATELESS_5TUPLE"
      stateless_rules  = [
        {
          priority          = 10
          actions           = ["aws:forward_to_sfe"]
          protocols         = [6]
          destination_ports = [{ from_port = 443, to_port = 443 }]
        }
      ]
    },
    # Stateful: domain allowlist for HTTPS egress
    {
      key              = "egress-domain-allowlist"
      name             = "egress-domain-allowlist"
      type             = "STATEFUL"
      capacity         = 100
      rules_source_type = "DOMAIN_LIST"
      domain_list = {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets              = [".amazonaws.com", ".example.com"]
      }
    },
    # Stateful: Suricata rule to alert on SSH brute-force attempts
    {
      key              = "ssh-brute-force-alert"
      name             = "ssh-brute-force-alert"
      type             = "STATEFUL"
      capacity         = 200
      rules_source_type = "SURICATA_STRING"
      rules_string     = <<-RULES
        alert tcp any any -> $HOME_NET 22 (msg:"SSH brute force attempt"; threshold:type threshold,track by_src,count 5,seconds 60; sid:1000001; rev:1;)
      RULES
      ip_sets = [
        { key = "HOME_NET", definition = ["10.0.0.0/8"] }
      ]
    }
  ]

  # ── Firewall Policy ──────────────────────────────────────────────────────
  policies = [
    {
      key                                = "prod-egress-policy"
      name                               = "prod-egress-policy"
      stateless_default_actions          = ["aws:forward_to_sfe"]
      stateless_fragment_default_actions = ["aws:forward_to_sfe"]
      stateless_rule_group_references = [
        { key = "allow-https-stateless", priority = 10 }
      ]
      stateful_rule_group_references = [
        { key = "egress-domain-allowlist" },
        { key = "ssh-brute-force-alert" }
      ]
    }
  ]

  # ── Firewalls ─────────────────────────────────────────────────────────────
  firewalls = [
    {
      key                 = "prod-egress"
      name                = "prod-egress-firewall"
      vpc_id              = "vpc-0abc12345"
      subnet_ids          = ["subnet-fw-az1", "subnet-fw-az2"]  # one per AZ
      firewall_policy_key = "prod-egress-policy"
      delete_protection   = true
      description         = "Production egress Network Firewall"
      logging = {
        destinations = [
          {
            log_type             = "FLOW"
            log_destination_type = "CloudWatchLogs"
            log_destination      = { logGroup = "/aws/network-firewall/flow" }
          },
          {
            log_type             = "ALERT"
            log_destination_type = "S3"
            log_destination      = { bucketName = "my-firewall-logs", prefix = "alerts/" }
          }
        ]
      }
      tags = { CostCenter = "security-ops" }
    }
  ]
}

# Reference the endpoint IDs to create route table entries
output "fw_endpoints" {
  value = module.network_firewall.firewall_endpoint_ids
  # Returns: { "prod-egress" = { "us-east-1a" = "vpce-xxx", "us-east-1b" = "vpce-yyy" } }
}
```

---

## Route Table Wiring

After applying the module, configure route tables to route traffic through the firewall endpoints:

| Route Table | Destination | Target |
|---|---|---|
| **Application subnet RT** (each AZ) | `0.0.0.0/0` | `vpce-xxx` (same AZ endpoint) |
| **Firewall subnet RT** | `0.0.0.0/0` | Internet Gateway |
| **IGW Gateway RT** | App subnet CIDR (per AZ) | `vpce-xxx` (same AZ endpoint) |

> Only route traffic through the **same-AZ endpoint** — cross-AZ firewall routing is not supported and incurs additional latency.

---

## Capacity Planning

Rule group capacity is fixed at creation and cannot be changed without destroying and recreating the group.

| Rule Source Type | Capacity per Rule | Recommendation |
|---|---|---|
| `STATELESS_5TUPLE` | 1 per rule | Start with 100–500 for typical policies |
| `SURICATA_STRING` | 1–7 per Suricata rule (varies by complexity) | Start with 1,000+ for IPS signatures |
| `DOMAIN_LIST` | 5 per target domain | Start with 100+ for 20+ domains |
| `STATEFUL_5TUPLE` | 1 per rule | Start with 100–500 |

---

## Security Best Practices

1. **Enable delete protection** (`delete_protection = true`) in production after initial deployment is validated.
2. **Use per-AZ subnets** — provide one dedicated firewall subnet per AZ to ensure HA.
3. **Prefer STRICT_ORDER** for stateful rules in production — it provides predictable, first-match semantics and enables stateful default actions.
4. **Log both FLOW and ALERT** — FLOW logs enable traffic analysis; ALERT logs capture rule-match events for security investigations.
5. **Use policy variables** (`$HOME_NET`) in Suricata rules instead of hard-coding CIDRs — simplifies policy updates.
6. **Encrypt with a CMK** when compliance requires audit trails for firewall configuration changes.

---

## Related Resources

- [aws-network-firewall.md](aws-network-firewall.md) — Service overview, core concepts, and use cases
- [tf-plans/aws_network_firewall](../../../../tf-plans/aws_network_firewall/README.md) — Wrapper plan with example `terraform.tfvars`
- [AWS Network Firewall Developer Guide](https://docs.aws.amazon.com/network-firewall/latest/developerguide/)
- [Terraform: aws_networkfirewall_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall)
- [Terraform: aws_networkfirewall_firewall_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy)
- [Terraform: aws_networkfirewall_rule_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group)
- [Terraform: aws_networkfirewall_logging_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration)
