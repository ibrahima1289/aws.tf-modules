############################################
# Variables
############################################

# Required
variable "region" {
  description = "AWS region to deploy resources in."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to create the route table in."
  type        = string
}

# Optional tagging
variable "name" {
  description = "Optional Name tag value for the route table."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to merge into the route table (optional)."
  type        = map(string)
  default     = {}
}

############################################
# Multiple Route Tables Support
############################################

# Optional: define one or more route tables with routes and associations.
# If empty, the module will fall back to single-table variables (name, routes, subnet_ids, set_as_main).
variable "route_tables" {
  description = "List of route table definitions. Each entry may specify name, tags, routes, subnet group or explicit subnet_ids, and set_as_main."
  type = list(object({
    name        = optional(string)
    tags        = optional(map(string))

    # Routes
    routes = optional(list(object({
      destination_cidr_block      = optional(string)
      destination_ipv6_cidr_block = optional(string)
      destination_prefix_list_id  = optional(string)

      gateway_id                = optional(string) # IGW
      nat_gateway_id            = optional(string)
      transit_gateway_id        = optional(string)
      vpc_peering_connection_id = optional(string)
      egress_only_gateway_id    = optional(string)
      network_interface_id      = optional(string)
      local_gateway_id          = optional(string)
      vpc_endpoint_id           = optional(string)
    })))

    # Associations (choose one): subnet_group or explicit subnet_ids
    subnet_group = optional(string) # "public" | "private"
    subnet_ids   = optional(list(string))

    set_as_main = optional(bool)
  }))
  default = []
}

# Optional: provide public/private subnet lists used when a route table selects subnet_group
variable "public_subnet_ids" {
  description = "List of public subnet IDs available for associations when a route table sets subnet_group = 'public'."
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs available for associations when a route table sets subnet_group = 'private'."
  type        = list(string)
  default     = []
}

############################################
# Single-table fallback variables (optional)
############################################

# Optional: routes to add to the route table (single-table usage)
variable "routes" {
  description = "List of route objects to create for single-table usage."
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
  description = "List of subnet IDs to associate with the created route table (single-table usage)."
  type        = list(string)
  default     = []
}

variable "set_as_main" {
  description = "Whether to set this route table as the VPC's main route table (single-table usage)."
  type        = bool
  default     = false
}
