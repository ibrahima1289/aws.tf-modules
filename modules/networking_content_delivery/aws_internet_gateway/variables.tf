############################################
# Variables
############################################

# Required
variable "region" {
  description = "AWS region to deploy the Internet Gateway in."
  type        = string
}

# Conditionally required (when enable_internet_gateway = true)
variable "vpc_id" {
  description = "ID of the VPC to attach the Internet Gateway to. Required when enable_internet_gateway is true."
  type        = string
  default     = null

  validation {
    condition     = var.enable_internet_gateway ? (var.vpc_id != null && length(var.vpc_id) > 0) : true
    error_message = "vpc_id must be provided and non-empty when enable_internet_gateway is true."
  }
}

# Optional
variable "enable_internet_gateway" {
  description = "Whether to create the Internet Gateway. If false, no resources are created."
  type        = bool
  default     = true
}

variable "name" {
  description = "Optional Name tag value for the Internet Gateway."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to merge into the Internet Gateway resource (optional)."
  type        = map(string)
  default     = {}
}

# Validation: enforce vpc_id provided when enabled
