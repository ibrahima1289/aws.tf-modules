# AWS Network Firewall — Example terraform.tfvars
# Replace subnet IDs, VPC IDs, and S3/CW/Firehose destinations with real values
# before running terraform plan / apply.
#
# Run sequence:
#   terraform init
#   terraform plan  -var-file=terraform.tfvars
#   terraform apply -var-file=terraform.tfvars

region = "us-east-1"

tags = {
  Environment = "prod"
  Team        = "security"
  Project     = "network-security"
}

# ─────────────────────────────────────────────────────────────────────────────
# Pattern 1 — Egress Firewall (production)
# Stateless rule forwards HTTPS; stateful domain allowlist restricts egress;
# Suricata rule alerts on SSH brute-force; logging to CloudWatch + S3.
# ─────────────────────────────────────────────────────────────────────────────
rule_groups = [
  # Stateless rule group: forward HTTPS and HTTP to the stateful engine.
  # All other traffic is dropped by the default policy action.
  {
    key               = "forward-web-stateless"
    name              = "forward-web-traffic"
    type              = "STATELESS"
    capacity          = 100
    description       = "Forward HTTP/HTTPS packets to the stateful engine for deep inspection."
    rules_source_type = "STATELESS_5TUPLE"
    stateless_rules = [
      {
        priority  = 10
        actions   = ["aws:forward_to_sfe"]
        protocols = [6] # TCP
        destination_ports = [
          {
            from_port = 443,
            to_port   = 443
          }
        ]
      },
      {
        priority  = 20
        actions   = ["aws:forward_to_sfe"]
        protocols = [6]
        destination_ports = [
          {
            from_port = 80,
            to_port   = 80
          }
        ]
      }
    ]
    tags = { RuleType = "stateless-forward" }
  },

  # Stateless rule group: drop all inbound SSH from the internet.
  # Complements the stateful SSH alert rule below (defence-in-depth).
  {
    key               = "drop-inbound-ssh-stateless"
    name              = "drop-inbound-ssh"
    type              = "STATELESS"
    capacity          = 50
    description       = "Stateless drop of inbound TCP:22 from any source."
    rules_source_type = "STATELESS_5TUPLE"
    stateless_rules = [
      {
        priority  = 5
        actions   = ["aws:drop"]
        protocols = [6]
        destination_ports = [
          {
            from_port = 22,
            to_port   = 22
          }
        ]
        sources      = ["0.0.0.0/0"]
        destinations = ["0.0.0.0/0"]
      }
    ]
    tags = { RuleType = "stateless-block" }
  },

  # Stateful domain allowlist: only permit HTTPS traffic to approved AWS and
  # corporate domains; all other TLS/HTTP egress is blocked.
  {
    key               = "egress-domain-allowlist"
    name              = "egress-domain-allowlist"
    type              = "STATEFUL"
    capacity          = 200
    description       = "Allowlist of approved egress HTTPS domains."
    rules_source_type = "DOMAIN_LIST"
    domain_list = {
      generated_rules_type = "ALLOWLIST"
      target_types = [
        "TLS_SNI",
        "HTTP_HOST"
      ]
      # Leading dot matches all subdomains; exact strings match the domain itself.
      targets = [
        ".amazonaws.com",
        ".cloudfront.net",
        ".example.com",
        "api.example.com",
        ".github.com",
        ".pypi.org",
        ".npmjs.com"
      ]
    }
    tags = { RuleType = "domain-allowlist" }
  },

  # Stateful Suricata rules: alert on SSH brute-force and known C2 port patterns.
  # Uses $HOME_NET variable defined in the ip_sets block below.
  {
    key               = "threat-detection-suricata"
    name              = "threat-detection-suricata"
    type              = "STATEFUL"
    capacity          = 500
    description       = "Suricata IPS rules for threat detection."
    rules_source_type = "SURICATA_STRING"
    # Threshold rule: alert if >5 SSH connection attempts in 60 seconds from same source.
    rules_string = <<-RULES
      alert tcp any any -> $HOME_NET 22 (msg:"SSH brute force - threshold exceeded"; threshold:type threshold,track by_src,count 5,seconds 60; sid:1000001; rev:2;)
      alert tcp any any -> $HOME_NET 3389 (msg:"RDP brute force - threshold exceeded"; threshold:type threshold,track by_src,count 5,seconds 60; sid:1000002; rev:1;)
      alert dns any any -> any any (msg:"DNS query to suspicious TLD"; dns.query; content:".tk"; nocase; sid:1000003; rev:1;)
    RULES
    ip_sets = [
      {
        key = "HOME_NET",
        definition = [
          "10.0.0.0/8",
          "172.16.0.0/12",
          "192.168.0.0/16"
        ]
      }
    ]

    tags = {
      RuleType = "suricata-ips"
    }
  },

  # Stateful 5-tuple rule group: explicitly pass internal service mesh traffic.
  {
    key               = "allow-internal-services"
    name              = "allow-internal-services"
    type              = "STATEFUL"
    capacity          = 100
    description       = "Pass internal microservice API traffic within the VPC CIDR."
    rules_source_type = "STATEFUL_5TUPLE"
    stateful_rules = [
      {
        action           = "PASS"
        protocol         = "TCP"
        source           = "10.0.0.0/8"
        source_port      = "ANY"
        destination      = "10.0.0.0/8"
        destination_port = "8080"
        direction        = "FORWARD"
        rule_options = [
          {
            keyword = "sid",
            settings = [
              "2000001"
            ]
          },
          {
            keyword = "rev",
            settings = [
              "1"
            ]
          }
        ]
      },
      {
        action           = "PASS"
        protocol         = "TCP"
        source           = "10.0.0.0/8"
        source_port      = "ANY"
        destination      = "10.0.0.0/8"
        destination_port = "8443"
        direction        = "FORWARD"
        rule_options = [
          {
            keyword = "sid",
            settings = [
              "2000002"
            ]
          },
          {
            keyword = "rev",
            settings = [
              "1"
            ]
          }
        ]
      }
    ]
    tags = { RuleType = "stateful-pass" }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Firewall Policy — binds rule groups and sets default actions.
# ─────────────────────────────────────────────────────────────────────────────
policies = [
  {
    key         = "prod-egress-policy"
    name        = "prod-egress-policy"
    description = "Production egress policy: forward web traffic to stateful engine; drop all else."

    # Packets not matching any stateless rule are forwarded to stateful engine.
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    # Stateless rule groups evaluated first, in ascending priority order.
    stateless_rule_group_references = [
      {
        key      = "drop-inbound-ssh-stateless",
        priority = 10
      },
      {
        key      = "forward-web-stateless",
        priority = 20
      }
    ]

    # Stateful rule groups evaluated after stateless forwarding.
    stateful_rule_group_references = [
      { key = "allow-internal-services" },
      { key = "egress-domain-allowlist" },
      { key = "threat-detection-suricata" }
    ]

    # Shared IP set variables accessible in stateful rule groups as $HOME_NET.
    policy_variables = {
      "HOME_NET" = [
        "10.0.0.0/8",
        "172.16.0.0/12",
        "192.168.0.0/16"
      ]
    }

    tags = { PolicyType = "production" }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Firewalls — one firewall, two AZ subnets for high availability.
# Replace vpc_id and subnet_ids with real resource IDs.
# ─────────────────────────────────────────────────────────────────────────────
firewalls = [
  {
    key         = "prod-egress"
    name        = "prod-egress-firewall"
    description = "Production egress Network Firewall — inspects all outbound VPC traffic."

    # Replace with your VPC and dedicated firewall subnet IDs (one per AZ).
    vpc_id = "vpc-0abc123456789def0"
    subnet_ids = [
      "subnet-0fw1az1example",
      "subnet-0fw2az2example"
    ]

    # Reference the policy created above.
    firewall_policy_key = "prod-egress-policy"

    # Enable protections in production after the initial deployment is validated.
    delete_protection                 = true
    subnet_change_protection          = true
    firewall_policy_change_protection = false # keep false to allow policy updates

    logging = {
      destinations = [
        # FLOW logs: record all accepted and rejected connection metadata.
        {
          log_type             = "FLOW"
          log_destination_type = "CloudWatchLogs"
          log_destination = {
            logGroup = "/aws/network-firewall/prod-egress/flow"
          }
        },
        # ALERT logs: record events matched by DROP/ALERT stateful rules.
        {
          log_type             = "ALERT"
          log_destination_type = "S3"
          log_destination = {
            bucketName = "my-firewall-logs-bucket",
            prefix     = "prod-egress/alerts/"
          }
        }
      ]
    }

    tags = { CostCenter = "security-ops", Tier = "production" }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Pattern 2 (commented out) — Dev/Staging lightweight firewall
# A minimal setup with a single AZ and permissive stateful rule.
# Uncomment and adjust to add a second firewall.
# ─────────────────────────────────────────────────────────────────────────────
# firewalls entries can be extended:
#
#   {
#     key                 = "dev-egress"
#     name                = "dev-egress-firewall"
#     vpc_id              = "vpc-0dev111111111111"
#     subnet_ids          = ["subnet-0devfw1"]
#     firewall_policy_key = "prod-egress-policy"   # reuse the same policy
#     description         = "Dev environment Network Firewall."
#     tags                = { Environment = "dev" }
#   }
