# AWS Network Firewall Terraform Module
#
# Resources created:
#   aws_networkfirewall_rule_group            – stateless and stateful rule groups
#   aws_networkfirewall_firewall_policy       – policies binding rule groups + default actions
#   aws_networkfirewall_firewall              – the firewall endpoints deployed into VPC subnets
#   aws_networkfirewall_logging_configuration – optional log delivery to CloudWatch/S3/Firehose
#
# Multi-instance pattern: all four resource types use `for_each` over a stable map
# keyed by the user-supplied `key` field, enabling safe add/remove operations.

# ─── Rule Groups ─────────────────────────────────────────────────────────────
# Rule groups contain the actual traffic-matching rules. A single policy can
# reference many rule groups of both types (stateless and stateful).

resource "aws_networkfirewall_rule_group" "rule_group" {
  for_each = local.rule_groups_map

  name        = each.value.name
  description = each.value.description
  # STATELESS: evaluated first on every packet; no connection state.
  # STATEFUL:  evaluated after stateless forwarding; tracks connection context.
  type     = each.value.type
  capacity = each.value.capacity

  rule_group {
    # ── Optional Rule Variables ───────────────────────────────────────────────
    # Define named CIDR sets (HOME_NET, EXTERNAL_NET, etc.) referenced in rules
    # as $VARIABLE_NAME. Helps avoid hard-coded CIDRs inside Suricata strings.
    dynamic "rule_variables" {
      for_each = (
        length(each.value.ip_sets) > 0 || length(each.value.port_sets) > 0
      ) ? [1] : []
      content {
        dynamic "ip_sets" {
          for_each = each.value.ip_sets
          content {
            key = ip_sets.value.key
            ip_set { definition = ip_sets.value.definition }
          }
        }
        dynamic "port_sets" {
          for_each = each.value.port_sets
          content {
            key = port_sets.value.key
            port_set { definition = port_sets.value.definition }
          }
        }
      }
    }

    # ── Optional Stateful Rule Options ────────────────────────────────────────
    # STRICT_ORDER evaluates rule groups in ascending priority order and stops
    # at the first match. DEFAULT_ACTION_ORDER evaluates all groups.
    dynamic "stateful_rule_options" {
      for_each = each.value.rule_order != null ? [each.value.rule_order] : []
      content {
        rule_order = stateful_rule_options.value
      }
    }

    rules_source {
      # ── Source Type 1: Stateless 5-Tuple Rules ──────────────────────────────
      # Packet-level matching on protocol, source/destination IP, and port.
      # Only one source type block is rendered per rule group (others are skipped).
      dynamic "stateless_rules_and_custom_actions" {
        for_each = each.value.rules_source_type == "STATELESS_5TUPLE" ? [1] : []
        content {
          dynamic "stateless_rule" {
            for_each = coalesce(each.value.stateless_rules, [])
            content {
              # Lower priority number = evaluated first (1 is highest priority).
              priority = stateless_rule.value.priority
              rule_definition {
                actions = stateless_rule.value.actions
                match_attributes {
                  dynamic "source" {
                    for_each = stateless_rule.value.sources
                    content { address_definition = source.value }
                  }
                  dynamic "destination" {
                    for_each = stateless_rule.value.destinations
                    content { address_definition = destination.value }
                  }
                  # IANA protocol numbers: 6=TCP, 17=UDP, 1=ICMP, empty=all.
                  protocols = stateless_rule.value.protocols
                  dynamic "source_port" {
                    for_each = stateless_rule.value.source_ports
                    content {
                      from_port = source_port.value.from_port
                      to_port   = source_port.value.to_port
                    }
                  }
                  dynamic "destination_port" {
                    for_each = stateless_rule.value.destination_ports
                    content {
                      from_port = destination_port.value.from_port
                      to_port   = destination_port.value.to_port
                    }
                  }
                  # Optional TCP flag matching (e.g., detect SYN-only packets).
                  dynamic "tcp_flag" {
                    for_each = coalesce(stateless_rule.value.tcp_flags, [])
                    content {
                      flags = tcp_flag.value.flags
                      masks = tcp_flag.value.masks
                    }
                  }
                }
              }
            }
          }
        }
      }

      # ── Source Type 2: Suricata-Compatible Rule String ───────────────────────
      # Full Suricata IPS syntax enabling advanced signatures, TLS SNI matching,
      # HTTP header inspection, and custom alert metadata.
      # Set to null for all other source types so the attribute is omitted.
      rules_string = each.value.rules_source_type == "SURICATA_STRING" ? each.value.rules_string : null

      # ── Source Type 3: Domain Allow/Deny List ────────────────────────────────
      # Matches outbound traffic by HTTP Host header or TLS SNI field.
      # Ideal for controlling egress to known-good or known-bad domains.
      dynamic "rules_source_list" {
        for_each = each.value.rules_source_type == "DOMAIN_LIST" ? [each.value.domain_list] : []
        content {
          # ALLOWLIST: only traffic matching targets is permitted.
          # DENYLIST:  traffic matching targets is blocked.
          generated_rules_type = rules_source_list.value.generated_rules_type
          # HTTP_HOST inspects Host header; TLS_SNI inspects the SNI extension.
          target_types = rules_source_list.value.target_types
          targets      = rules_source_list.value.targets
        }
      }

      # ── Source Type 4: Stateful 5-Tuple Rules ────────────────────────────────
      # Connection-aware rules with PASS/DROP/ALERT actions. Each rule must
      # include at least a `sid` rule_option for Suricata compatibility.
      dynamic "stateful_rule" {
        for_each = each.value.rules_source_type == "STATEFUL_5TUPLE" ? coalesce(each.value.stateful_rules, []) : []
        content {
          action = stateful_rule.value.action
          header {
            protocol         = stateful_rule.value.protocol
            source           = stateful_rule.value.source
            source_port      = stateful_rule.value.source_port
            destination      = stateful_rule.value.destination
            destination_port = stateful_rule.value.destination_port
            direction        = stateful_rule.value.direction
          }
          dynamic "rule_option" {
            for_each = stateful_rule.value.rule_options
            content {
              keyword  = rule_option.value.keyword
              settings = rule_option.value.settings
            }
          }
        }
      }
    }
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })
}

# ─── Firewall Policies ───────────────────────────────────────────────────────
# A policy defines the ordered set of rule groups and the default actions
# for traffic that does not match any rule. One policy can be shared across
# multiple firewalls, or each firewall can have its own dedicated policy.

resource "aws_networkfirewall_firewall_policy" "policy" {
  for_each = local.policies_map

  name        = each.value.name
  description = each.value.description

  firewall_policy {
    # Packets not matched by any stateless rule receive this default action.
    stateless_default_actions = each.value.stateless_default_actions
    # Fragmented packets not matched by stateless rules receive this action.
    stateless_fragment_default_actions = each.value.stateless_fragment_default_actions

    # ── Stateless Rule Group References ───────────────────────────────────────
    # Evaluated in ascending priority order for every packet before stateful rules.
    dynamic "stateless_rule_group_reference" {
      for_each = each.value.stateless_rule_group_references
      content {
        # Prefer an explicit ARN (external group); fall back to module-managed group.
        resource_arn = (
          stateless_rule_group_reference.value.resource_arn != null
          ? stateless_rule_group_reference.value.resource_arn
          : aws_networkfirewall_rule_group.rule_group[stateless_rule_group_reference.value.key].arn
        )
        priority = stateless_rule_group_reference.value.priority
      }
    }

    # ── Stateful Rule Group References ────────────────────────────────────────
    # Evaluated on packets forwarded from stateless rules via aws:forward_to_sfe.
    dynamic "stateful_rule_group_reference" {
      for_each = each.value.stateful_rule_group_references
      content {
        resource_arn = (
          stateful_rule_group_reference.value.resource_arn != null
          ? stateful_rule_group_reference.value.resource_arn
          : aws_networkfirewall_rule_group.rule_group[stateful_rule_group_reference.value.key].arn
        )
        # priority is required when rule_order = STRICT_ORDER; omit for DEFAULT_ACTION_ORDER.
        priority = stateful_rule_group_reference.value.priority
        # Optional override: DROP_TO_ALERT converts PASS actions into alerts.
        dynamic "override" {
          for_each = stateful_rule_group_reference.value.override_action != null ? [stateful_rule_group_reference.value.override_action] : []
          content {
            action = override.value
          }
        }
      }
    }

    # ── Stateful Engine Options ────────────────────────────────────────────────
    # DEFAULT_ACTION_ORDER: all stateful groups evaluated; no guaranteed order.
    # STRICT_ORDER: groups evaluated by ascending priority; first match wins.
    dynamic "stateful_engine_options" {
      for_each = each.value.stateful_engine_options != null ? [each.value.stateful_engine_options] : []
      content {
        rule_order = stateful_engine_options.value.rule_order
      }
    }

    # ── Stateful Default Actions ───────────────────────────────────────────────
    # Applied only when stateful_engine_options.rule_order = STRICT_ORDER.
    # Valid values: aws:drop_strict, aws:drop_established, aws:alert_strict, aws:alert_established.
    # Omit this attribute when using DEFAULT_ACTION_ORDER.
    # Using a dynamic trick: wrap in a list to iterate only when non-empty.

    # ── Policy Variables ──────────────────────────────────────────────────────
    # Named IP set definitions (e.g., HOME_NET) reusable across rule groups
    # in Suricata rules as $VARIABLE_NAME.
    dynamic "policy_variables" {
      for_each = each.value.policy_variables != null ? [each.value.policy_variables] : []
      content {
        dynamic "rule_variables" {
          for_each = policy_variables.value
          content {
            key = rule_variables.key
            ip_set { definition = rule_variables.value }
          }
        }
      }
    }

    # ── TLS Inspection Configuration (optional) ───────────────────────────────
    # Enables decryption and deep inspection of TLS-encrypted traffic.
    tls_inspection_configuration_arn = each.value.tls_inspection_configuration_arn
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })

  depends_on = [aws_networkfirewall_rule_group.rule_group]
}

# ─── Firewalls ────────────────────────────────────────────────────────────────
# The main firewall resource. AWS deploys a highly-available firewall endpoint
# into each subnet listed in subnet_ids. Route tables must direct traffic
# through these endpoints (output: firewall_endpoint_ids).

resource "aws_networkfirewall_firewall" "firewall" {
  for_each = local.firewalls_map

  name        = each.value.name
  description = each.value.description
  vpc_id      = each.value.vpc_id

  # Protection flags guard against accidental changes post-deployment.
  # Enable in production after initial validation.
  delete_protection                 = each.value.delete_protection
  subnet_change_protection          = each.value.subnet_change_protection
  firewall_policy_change_protection = each.value.firewall_policy_change_protection

  # Resolve the policy ARN: prefer an explicit external ARN, then look up
  # the policy created by this module using firewall_policy_key.
  firewall_policy_arn = (
    each.value.firewall_policy_arn != null
    ? each.value.firewall_policy_arn
    : aws_networkfirewall_firewall_policy.policy[each.value.firewall_policy_key].arn
  )

  # Deploy one firewall endpoint per AZ for high availability.
  # Traffic is routed in/out of each endpoint via AZ-specific route tables.
  dynamic "subnet_mapping" {
    for_each = each.value.subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  # Optional KMS encryption for firewall configuration storage.
  # type = AWS_OWNED_KMS_KEY (default, no additional cost) or CUSTOMER_KMS.
  dynamic "encryption_configuration" {
    for_each = each.value.encryption_configuration != null ? [each.value.encryption_configuration] : []
    content {
      type   = encryption_configuration.value.type
      key_id = encryption_configuration.value.key_id
    }
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = each.value.name
  })

  depends_on = [aws_networkfirewall_firewall_policy.policy]
}

# ─── Logging Configuration ────────────────────────────────────────────────────
# Attach log delivery to firewalls that declare a logging block.
# Supports FLOW logs (connection-level) and ALERT logs (rule match events).
# Destinations: CloudWatch Logs, Amazon S3, or Kinesis Data Firehose.

resource "aws_networkfirewall_logging_configuration" "logging" {
  for_each = local.firewalls_with_logging_map

  # Bind the logging config to the corresponding firewall ARN.
  firewall_arn = aws_networkfirewall_firewall.firewall[each.key].arn

  logging_configuration {
    dynamic "log_destination_config" {
      for_each = each.value.logging.destinations
      content {
        # FLOW: all accepted and rejected connection records.
        # ALERT: events triggered by stateful DROP or ALERT rules.
        log_type = log_destination_config.value.log_type
        # CloudWatchLogs | S3 | KinesisDataFirehose
        log_destination_type = log_destination_config.value.log_destination_type
        # Key-value map describing the destination resource (see variable doc).
        log_destination = log_destination_config.value.log_destination
      }
    }
  }

  depends_on = [aws_networkfirewall_firewall.firewall]
}
