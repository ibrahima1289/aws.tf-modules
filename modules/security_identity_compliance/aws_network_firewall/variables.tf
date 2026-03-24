# Variables for AWS Network Firewall Module

# ─── Provider ────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region in which to deploy Network Firewall resources."
  type        = string
}

# ─── Global Tags ─────────────────────────────────────────────────────────────

variable "tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}

# ─── Rule Groups ─────────────────────────────────────────────────────────────
# Each rule group is identified by a unique `key`. Supported source types:
#   STATELESS_5TUPLE  – stateless packet-matching rules using 5-tuple criteria
#   SURICATA_STRING   – stateful Suricata-compatible IPS rule string
#   DOMAIN_LIST       – stateful allow/deny list based on HTTP host or TLS SNI
#   STATEFUL_5TUPLE   – stateful connection-tracking rules using 5-tuple criteria

variable "rule_groups" {
  description = "List of Network Firewall rule group definitions."
  type = list(object({
    # Unique identifier used as the for_each key; must be stable across runs.
    key  = string
    name = string
    # STATELESS produces stateless rule groups; STATEFUL produces stateful ones.
    type     = string
    capacity = number
    # Human-readable description stored in AWS metadata.
    description = optional(string, "")
    # Selects which rules_source block to populate (mutually exclusive per group).
    rules_source_type = string

    # ── STATELESS_5TUPLE ──────────────────────────────────────────────────────
    # Used when type = STATELESS. Matches individual packets without connection state.
    stateless_rules = optional(list(object({
      priority = number
      # Valid actions: aws:pass, aws:drop, aws:forward_to_sfe, aws:publish_to_sns
      actions      = list(string)
      sources      = optional(list(string), ["0.0.0.0/0"])
      destinations = optional(list(string), ["0.0.0.0/0"])
      # IANA protocol numbers: 6=TCP, 17=UDP, 1=ICMP. Empty list matches all protocols.
      protocols         = optional(list(number), [])
      source_ports      = optional(list(object({ from_port = number, to_port = number })), [])
      destination_ports = optional(list(object({ from_port = number, to_port = number })), [])
      # Optional TCP flag matching (e.g., SYN flood detection).
      tcp_flags = optional(list(object({ flags = list(string), masks = list(string) })), [])
    })))

    # ── SURICATA_STRING ──────────────────────────────────────────────────────
    # Used when type = STATEFUL. Raw Suricata-compatible IPS rules string.
    rules_string = optional(string)

    # ── DOMAIN_LIST ──────────────────────────────────────────────────────────
    # Used when type = STATEFUL. Matches HTTP_HOST or TLS_SNI against a domain list.
    domain_list = optional(object({
      # ALLOWLIST permits only matching traffic; DENYLIST blocks matching traffic.
      generated_rules_type = string
      # HTTP_HOST inspects HTTP Host header; TLS_SNI inspects TLS Server Name Indication.
      target_types = list(string)
      # Domain targets. Use leading dot (e.g., ".example.com") to match all subdomains.
      targets = list(string)
    }))

    # ── STATEFUL_5TUPLE ──────────────────────────────────────────────────────
    # Used when type = STATEFUL. Maintains connection state; supports PASS/DROP/ALERT.
    stateful_rules = optional(list(object({
      # PASS, DROP, or ALERT
      action = string
      # TCP, UDP, ICMP, HTTP, FTP, TLS, SMB, DNS, DCERPC, SMTP, SSH, TFTP, IKEV2, KRB5, NTP, DHCP, Any
      protocol         = string
      source           = string # CIDR notation or ANY
      source_port      = string # port number, range like 1024:65535, or ANY
      destination      = string # CIDR notation or ANY
      destination_port = string # port number, range, or ANY
      # FORWARD inspects traffic in one direction; ANY inspects both directions.
      direction = string
      # Suricata rule options such as sid, msg, rev. sid is required.
      rule_options = list(object({
        keyword  = string
        settings = optional(list(string), [])
      }))
    })))

    # ── Rule Variables ────────────────────────────────────────────────────────
    # Optional CIDR variable definitions referenced in rules as $VARIABLE_NAME.
    ip_sets = optional(list(object({
      key        = string
      definition = list(string)
    })), [])

    # Optional port variable definitions referenced in rules as $VARIABLE_NAME.
    port_sets = optional(list(object({
      key        = string
      definition = list(string)
    })), [])

    # Optional rule ordering (STATEFUL only): DEFAULT_ACTION_ORDER or STRICT_ORDER.
    rule_order = optional(string)

    tags = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for rg in var.rule_groups : contains(["STATELESS", "STATEFUL"], rg.type)
    ])
    error_message = "Rule group type must be STATELESS or STATEFUL."
  }

  validation {
    condition = alltrue([
      for rg in var.rule_groups : contains(
        ["STATELESS_5TUPLE", "SURICATA_STRING", "DOMAIN_LIST", "STATEFUL_5TUPLE"],
        rg.rules_source_type
      )
    ])
    error_message = "rules_source_type must be one of: STATELESS_5TUPLE, SURICATA_STRING, DOMAIN_LIST, STATEFUL_5TUPLE."
  }
}

# ─── Firewall Policies ───────────────────────────────────────────────────────
# A policy binds stateless and stateful rule groups together and defines
# default actions for traffic that does not match any explicit rule.

variable "policies" {
  description = "List of Network Firewall policy definitions."
  type = list(object({
    key         = string
    name        = string
    description = optional(string, "")

    # Default actions applied to packets that do not match any stateless rule.
    # Common values: aws:pass, aws:drop, aws:forward_to_sfe.
    stateless_default_actions = optional(list(string), ["aws:forward_to_sfe"])
    # Default actions for fragmented packets not matched by stateless rules.
    stateless_fragment_default_actions = optional(list(string), ["aws:forward_to_sfe"])

    # Ordered list of stateless rule groups. Lower priority number = evaluated first.
    stateless_rule_group_references = optional(list(object({
      # key references a rule group defined in var.rule_groups (created in this module).
      key = optional(string)
      # resource_arn references an externally-managed rule group ARN.
      resource_arn = optional(string)
      priority     = number
    })), [])

    # List of stateful rule groups evaluated after stateless processing.
    stateful_rule_group_references = optional(list(object({
      key          = optional(string)
      resource_arn = optional(string)
      # priority is required when stateful_engine_options.rule_order = STRICT_ORDER.
      priority = optional(number)
      # override_action: DROP_TO_ALERT overrides PASS rules when using STRICT_ORDER.
      override_action = optional(string)
    })), [])

    # Stateful engine ordering: DEFAULT_ACTION_ORDER (default) or STRICT_ORDER.
    stateful_engine_options = optional(object({
      rule_order = string
    }))

    # Default actions for stateful rules; only valid with STRICT_ORDER.
    # Valid values: aws:drop_strict, aws:drop_established, aws:alert_strict, aws:alert_established.
    stateful_default_actions = optional(list(string), [])

    # Reusable IP variable definitions referenced in rules as $KEY (e.g., $HOME_NET).
    # Format: { "HOME_NET" = ["10.0.0.0/8", "192.168.0.0/16"] }
    policy_variables = optional(map(list(string)))

    # ARN of an optional TLS inspection configuration for decrypting TLS traffic.
    tls_inspection_configuration_arn = optional(string)

    tags = optional(map(string), {})
  }))
  default = []
}

# ─── Firewalls ───────────────────────────────────────────────────────────────
# Each firewall entry deploys one AWS Network Firewall in a VPC.
# subnet_ids should contain one firewall subnet per Availability Zone for HA.

variable "firewalls" {
  description = "List of Network Firewall definitions. Provide one entry per firewall."
  type = list(object({
    # Unique identifier used as the for_each key.
    key    = string
    name   = string
    vpc_id = string
    # One subnet_id per AZ that will host a firewall endpoint.
    # Traffic is routed through these endpoints via VPC route tables.
    subnet_ids = list(string)

    # Reference an existing (externally managed) firewall policy by ARN.
    firewall_policy_arn = optional(string)
    # Reference a policy defined in var.policies (created by this module) by key.
    firewall_policy_key = optional(string)

    # Protection flags prevent accidental modification during plan/apply.
    # Set to true in production after initial deployment is validated.
    delete_protection                 = optional(bool, false)
    subnet_change_protection          = optional(bool, false)
    firewall_policy_change_protection = optional(bool, false)

    description = optional(string, "")

    # Optional customer-managed KMS encryption.
    # type = AWS_OWNED_KMS_KEY (default) or CUSTOMER_KMS.
    encryption_configuration = optional(object({
      type   = string
      key_id = optional(string)
    }))

    # Optional logging configuration. Send FLOW or ALERT logs to one or more destinations.
    # log_destination keys per destination type:
    #   CloudWatchLogs      → { logGroup = "/aws/network-firewall/flow" }
    #   S3                  → { bucketName = "my-bucket", prefix = "fw/" }
    #   KinesisDataFirehose → { deliveryStream = "my-delivery-stream" }
    logging = optional(object({
      destinations = list(object({
        log_type             = string # FLOW or ALERT
        log_destination_type = string # CloudWatchLogs | S3 | KinesisDataFirehose
        log_destination      = map(string)
      }))
    }))

    tags = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for f in var.firewalls :
      (f.firewall_policy_arn != null || f.firewall_policy_key != null)
    ])
    error_message = "Each firewall must specify either firewall_policy_arn or firewall_policy_key."
  }
}
