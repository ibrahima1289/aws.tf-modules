variable "region" {
  description = "The AWS region where Firewall Manager resources are managed."
  type        = string
}

variable "enable_admin_account" {
  description = "Set to true to designate this account as the Firewall Manager administrator. Requires AWS Organizations to be enabled. Only set from the management account or a delegated administrator account."
  type        = bool
  default     = false
}

variable "admin_account_id" {
  description = "The AWS account ID to register as the Firewall Manager administrator. When null the current caller account is used (requires no account_id in the API call)."
  type        = string
  default     = null
}

variable "policies" {
  description = <<-EOT
    List of Firewall Manager policy objects to create. Supported fields per policy:

    Required:
      name                               - Display name of the policy.
      security_service_type              - Policy type: WAF | WAFV2 | SHIELD_ADVANCED |
                                           SECURITY_GROUPS_COMMON | SECURITY_GROUPS_AUDIT |
                                           NETWORK_FIREWALL | DNS_FIREWALL |
                                           THIRD_PARTY_FIREWALL | NETWORK_ACL_COMMON.

    Optional:
      description                        - Human-readable description. Default: "".
      exclude_resource_tags              - Exclude resources matching resource_tags when true.
                                           Default: false.
      remediation_enabled                - Auto-remediate non-compliant resources. Default: false.
      delete_unused_fm_managed_resources - Delete managed resources on policy deletion.
                                           Default: false.
      resource_type                      - Single AWS resource type (e.g. AWS::EC2::VPC).
                                           Mutually exclusive with resource_type_list.
      resource_type_list                 - List of AWS resource types (e.g.
                                           ["AWS::ElasticLoadBalancingV2::LoadBalancer"]).
      resource_tags                      - Map of tags used to scope resources in/out of scope.
      managed_service_data               - JSON string with service-specific policy data
                                           (rule groups, ACL config, etc.).
      include_map_accounts               - List of account IDs to include in policy scope.
      include_map_orgunits               - List of OU IDs to include in policy scope.
      exclude_map_accounts               - List of account IDs to exclude from policy scope.
      exclude_map_orgunits               - List of OU IDs to exclude from policy scope.
      tags                               - Per-policy tags merged on top of common_tags.
  EOT
  type = list(object({
    name                               = string
    description                        = optional(string, "")
    exclude_resource_tags              = optional(bool, false)
    remediation_enabled                = optional(bool, false)
    delete_unused_fm_managed_resources = optional(bool, false)
    resource_type                      = optional(string)
    resource_type_list                 = optional(list(string))
    resource_tags                      = optional(map(string))
    security_service_type              = string
    managed_service_data               = optional(string)
    include_map_accounts               = optional(list(string))
    include_map_orgunits               = optional(list(string))
    exclude_map_accounts               = optional(list(string))
    exclude_map_orgunits               = optional(list(string))
    tags                               = optional(map(string))
  }))
  default = []
}

variable "tags" {
  description = "Common tags applied to all Firewall Manager resources created by this module."
  type        = map(string)
  default     = {}
}
