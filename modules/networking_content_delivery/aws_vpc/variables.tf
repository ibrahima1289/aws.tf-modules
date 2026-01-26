variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC. Required if not using IPAM."
  type        = string
}

variable "defined_name" {
  description = "Optional name for the VPC."
  type        = string
  default     = null
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC."
  type        = string
  default     = null
}

variable "assign_generated_ipv6_cidr_block" {
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC."
  type        = bool
  default     = null
}

variable "ipv4_ipam_pool_id" {
  description = "The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR."
  type        = string
  default     = null
}

variable "ipv4_netmask_length" {
  description = "The netmask length of the IPv4 CIDR to allocate to this VPC."
  type        = number
  default     = null
}

variable "ipv6_ipam_pool_id" {
  description = "The ID of an IPv6 IPAM pool you want to use for allocating this VPC's CIDR."
  type        = string
  default     = null
}

variable "ipv6_cidr_block" {
  description = "The IPv6 CIDR block to associate with the VPC."
  type        = string
  default     = null
}

variable "ipv6_cidr_block_network_border_group" {
  description = "The location from which we advertise the IPV6 CIDR block."
  type        = string
  default     = null
}

variable "ipv6_netmask_length" {
  description = "The netmask length of the IPv6 CIDR to allocate to this VPC."
  type        = number
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (IPv4 or IPv6)."
  type        = list(string)
}

variable "public_subnet_is_ipv6" {
  description = "Set to true if public_subnet_cidrs are IPv6 CIDRs."
  type        = bool
  default     = false
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (IPv4 or IPv6)."
  type        = list(string)
}

variable "private_subnet_is_ipv6" {
  description = "Set to true if private_subnet_cidrs are IPv6 CIDRs."
  type        = bool
  default     = false
}