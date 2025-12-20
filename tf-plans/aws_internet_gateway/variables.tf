variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to attach the Internet Gateway to"
  type        = string
  default     = null
}

variable "enable_internet_gateway" {
  description = "Whether to create the Internet Gateway"
  type        = bool
  default     = true
}

variable "name" {
  description = "Optional Name tag for the Internet Gateway"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
