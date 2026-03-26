variable "region" {
  description = "AWS region where EBS resources are deployed."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Common tags applied to all taggable EBS resources."
  type        = map(string)
  default     = {}
}

# ── Volumes ────────────────────────────────────────────────────────────────────

variable "volumes" {
  description = "List of EBS volumes to create.  See module variables.tf for full field reference."
  type = list(object({
    key                  = string
    name                 = string
    availability_zone    = string
    type                 = optional(string, "gp3")
    size                 = optional(number, 20)
    iops                 = optional(number, null)
    throughput           = optional(number, null)
    encrypted            = optional(bool, true)
    kms_key_id           = optional(string, null)
    multi_attach_enabled = optional(bool, false)
    snapshot_id          = optional(string, null)
    final_snapshot       = optional(bool, false)
    tags                 = optional(map(string), {})
  }))
  default = []
}

# ── Volume Attachments ─────────────────────────────────────────────────────────

variable "attachments" {
  description = "List of volume-to-EC2 attachments.  See module variables.tf for full field reference."
  type = list(object({
    key                            = string
    volume_key                     = string
    instance_id                    = string
    device_name                    = string
    force_detach                   = optional(bool, false)
    skip_destroy                   = optional(bool, false)
    stop_instance_before_detaching = optional(bool, false)
  }))
  default = []
}

# ── Snapshots ──────────────────────────────────────────────────────────────────

variable "snapshots" {
  description = "List of EBS snapshots to create.  See module variables.tf for full field reference."
  type = list(object({
    key         = string
    volume_key  = string
    name        = string
    description = optional(string, "")
    tags        = optional(map(string), {})
  }))
  default = []
}
