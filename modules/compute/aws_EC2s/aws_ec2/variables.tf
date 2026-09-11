############################################
# Variables
############################################

# Required
variable "region" {
  description = "AWS region to deploy EC2 instances in."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instances (required)."
  type        = string
}

# Optional
variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch instances into (optional)."
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs to attach (optional)."
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Key pair name for SSH/RDP (optional)."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Associate a public IP with the primary network interface (optional)."
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "Enable detailed monitoring (optional)."
  type        = bool
  default     = false
}

variable "name" {
  description = "Name prefix used for the Name tag (optional)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to all instances (optional)."
  type        = map(string)
  default     = {}
}

variable "instance_count" {
  description = "Number of instances to create."
  type        = number
  default     = 1
}

variable "instances" {
  description = "Optional list of per-instance configurations to create multiple different EC2 instances. If non-empty, overrides instance_count."
  type = list(object({
    region                      = string
    ami_id                      = string
    instance_type               = optional(string)
    instance_count              = optional(number)
    subnet_id                   = optional(string)
    security_group_ids          = optional(list(string))
    key_name                    = optional(string)
    associate_public_ip_address = optional(bool)
    monitoring                  = optional(bool)
    name                        = optional(string)
    tags                        = optional(map(string))
    user_data                   = optional(string)
  }))
  default = []
}

variable "user_data" {
  description = "User data script to run on instance boot (optional)."
  type        = string
  default     = null
}
