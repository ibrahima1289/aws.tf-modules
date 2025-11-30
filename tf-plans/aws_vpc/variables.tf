variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "defined_name" {
  description = "Optional name for the VPC (used as the Name tag)"
  type        = string
  default     = null
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (IPv4 or IPv6)"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (IPv4 or IPv6)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}