# Example configuration for the GWLB plan
region = "us-east-1"

tags = {
  Environment = "dev"
  Team        = "platform"
}

vpc_id     = "vpc-0123456789abcdef0"
subnet_ids = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]

# Optional multi-GLB configuration.
glbs = [
  {
    name          = "gwlb-1"
    subnets       = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    internal      = true
    access_logs   = { enabled = false }
    target_groups = [{ name = "tg-1", port = 6081, protocol = "GENEVE" }]
    listeners     = [{ port = 6081, protocol = "GENEVE", default_forward_target_group = "tg-1" }]
  },
  {
    name          = "gwlb-2"
    subnets       = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    internal      = true
    access_logs   = { enabled = true, bucket = "my-logs-bucket", prefix = "gwlb-2" }
    target_groups = [{ name = "tg-2", port = 6081, protocol = "GENEVE" }]
    listeners     = [{ port = 6081, protocol = "GENEVE", default_forward_target_group = "tg-2" }]
  }
]
