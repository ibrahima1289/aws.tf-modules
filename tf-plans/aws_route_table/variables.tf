variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the route table will be created"
  type        = string
}

############################################
# Multiple route tables support
############################################

variable "route_tables" {
  description = "List of route table definitions (name/tags/routes/subnet_group or subnet_ids/set_as_main)."
  type = list(object({
    name = optional(string)
    tags = optional(map(string))
    routes = optional(list(object({
      destination_cidr_block      = optional(string)
      destination_ipv6_cidr_block = optional(string)
      destination_prefix_list_id  = optional(string)

      gateway_id                = optional(string)
      nat_gateway_id            = optional(string)
      transit_gateway_id        = optional(string)
      vpc_peering_connection_id = optional(string)
      egress_only_gateway_id    = optional(string)
      network_interface_id      = optional(string)
      local_gateway_id          = optional(string)
      vpc_endpoint_id           = optional(string)
    })))
    subnet_group = optional(string) # "public" | "private"
    subnet_ids   = optional(list(string))
    set_as_main  = optional(bool)
  }))
  default = []
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs used with subnet_group = 'public'"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs used with subnet_group = 'private'"
  type        = list(string)
  default     = []
}

############################################
# Single-table fallback
############################################

variable "name" {
  description = "Optional Name tag for a single route table (fallback)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to a single route table (fallback)"
  type        = map(string)
  default     = {}
}

variable "routes" {
  description = "List of route objects to create (fallback single table)"
  type = list(object({
    destination_cidr_block      = optional(string)
    destination_ipv6_cidr_block = optional(string)
    destination_prefix_list_id  = optional(string)

    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    transit_gateway_id        = optional(string)
    vpc_peering_connection_id = optional(string)
    egress_only_gateway_id    = optional(string)
    network_interface_id      = optional(string)
    local_gateway_id          = optional(string)
    vpc_endpoint_id           = optional(string)
  }))
  default = []
}

variable "subnet_ids" {
  description = "Subnet IDs to associate with the route table (fallback)"
  type        = list(string)
  default     = []
}

variable "set_as_main" {
  description = "Whether to set this route table as the VPC's main (fallback)"
  type        = bool
  default     = false
}
