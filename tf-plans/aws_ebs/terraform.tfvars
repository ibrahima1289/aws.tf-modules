region = "us-east-1"

tags = {
  environment = "production"
  team        = "platform"
  project     = "storage-infra"
  managed_by  = "terraform"
}

# ── Volumes ────────────────────────────────────────────────────────────────────
# Pattern 1: gp3 general-purpose volume for a web/app server.
#            Balanced cost and performance; 3,000 IOPS / 125 MiB/s baseline.
# Pattern 2: io2 high-IOPS volume for a production relational database.
#            Customer-managed KMS key; no multi-attach (single-instance DB).
# Pattern 3: st1 throughput-optimized volume for a Hadoop/Spark data node.
#            HDD storage — cheapest option for large sequential reads/writes.
volumes = [
  {
    # Web application data volume — general-purpose SSD.
    key               = "webapp"
    name              = "webapp-data-vol"
    availability_zone = "us-east-1a"
    type              = "gp3"
    size              = 100   # GiB
    iops              = 3000  # gp3 baseline
    throughput        = 250   # MiB/s; above the 125 baseline
    encrypted         = true  # AWS-managed EBS key (kms_key_id omitted)
    final_snapshot    = false # safety snapshot on destroy - set to true for critical data volumes
    tags              = { role = "webapp", tier = "application" }
  }
  # ,
  # {
  #   # Production database volume — Provisioned IOPS SSD with customer KMS key.
  #   key               = "database"
  #   name              = "prod-db-vol"
  #   availability_zone = "us-east-1a"
  #   type              = "io2"
  #   size              = 500   # GiB
  #   iops              = 10000 # guaranteed IOPS for OLTP workload
  #   encrypted         = true
  #   kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123def456ghi789"
  #   final_snapshot    = true
  #   tags              = { role = "database", tier = "data", compliance = "pci-dss" }
  # },
  # {
  #   # Big-data / log-processing volume — Throughput Optimized HDD.
  #   # Cannot be a boot volume; low cost for large sequential workloads.
  #   key               = "bigdata"
  #   name              = "bigdata-log-vol"
  #   availability_zone = "us-east-1b"
  #   type              = "st1"
  #   size              = 2000 # GiB — 2 TB for Spark/Hadoop data
  #   encrypted         = true
  #   final_snapshot    = false
  #   tags              = { role = "bigdata", tier = "analytics" }
  # }
  # ,
  # {
  #   # Shared cluster volume — io2 with Multi-Attach for active/active cluster nodes.
  #   # Requires a cluster-aware file system (e.g. GFS2, OCFS2) on every attached instance.
  #   # Multi-Attach is only supported for io1/io2 (enforced by a module precondition).
  #   key                  = "cluster-shared"
  #   name                 = "cluster-shared-vol"
  #   availability_zone    = "us-east-1a"
  #   type                 = "io2"           # required for Multi-Attach
  #   size                 = 200             # GiB
  #   iops                 = 5000            # required for io2; minimum 100
  #   encrypted            = true
  #   multi_attach_enabled = true            # allows up to 16 Nitro-based instances
  #   final_snapshot       = true
  #   tags                 = { role = "cluster", cluster = "app-cluster" }
  # }
]

# ── Volume Attachments ─────────────────────────────────────────────────────────
# Attach the webapp and database volumes to their respective EC2 instances.
# Replace instance IDs with actual running instance IDs before applying.

# attachments = [
#   {
#     # Attach the web app volume to the application server.
#     key          = "webapp-attach"
#     volume_key   = "webapp"
#     instance_id  = "i-0abc123def4567890" # replace with actual instance ID
#     device_name  = "/dev/xvdf"
#     force_detach = false
#     skip_destroy = false
#   },
#   {
#     # Attach the database volume to the DB server.
#     # stop_instance_before_detaching ensures clean detach on Windows/root volumes.
#     key                            = "db-attach"
#     volume_key                     = "database"
#     instance_id                    = "i-0def456abc7890123" # replace with actual instance ID
#     device_name                    = "/dev/xvdg"
#     force_detach                   = false
#     skip_destroy                   = false
#     stop_instance_before_detaching = true
#   },
#   {
#     # Multi-Attach node 1 — cluster-shared io2 volume attached to the first cluster node.
#     key          = "cluster-node1-attach"
#     volume_key   = "cluster-shared"
#     instance_id  = "i-0aaa111bbb222ccc1" # replace with actual instance ID
#     device_name  = "/dev/xvdf"
#     skip_destroy = true  # recommended for multi-attach: avoids concurrent-detach races
#   },
#   {
#     # Multi-Attach node 2 — same volume_key as node 1 maps to the same physical EBS volume.
#     key          = "cluster-node2-attach"
#     volume_key   = "cluster-shared"
#     instance_id  = "i-0ddd333eee444fff2" # replace with actual instance ID
#     device_name  = "/dev/xvdf"
#     skip_destroy = true
#   }
# ]

# ── Snapshots ──────────────────────────────────────────────────────────────────
# Create an on-demand snapshot of the database volume for compliance purposes.
# For automated recurring snapshots, use AWS Data Lifecycle Manager (DLM).

# snapshots = [
#   {
#     key         = "db-snap"
#     volume_key  = "database"
#     name        = "prod-db-manual-snapshot"
#     description = "Manual compliance snapshot of the production database volume."
#     tags        = { 
#       snapshot_type = "manual", 
#       compliance = "pci-dss" 
#     }
#   }
# ]
