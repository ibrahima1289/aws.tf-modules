############################################
# AWS Internet Gateway (Optional Creation)
# - Creates an Internet Gateway attached to a VPC
# - Controlled via a boolean flag to optionally create
# - No data sources are used; all values provided as inputs
#
# Required when enabled:
# - `vpc_id`
#
# Optional:
# - `enable_internet_gateway` (default: true)
# - `name` (Name tag)
# - `tags` (extra tags merged with base tags)
############################################

resource "aws_internet_gateway" "this" {
	count  = var.enable_internet_gateway ? 1 : 0
	vpc_id = var.vpc_id

	tags = merge(
		local.base_tags,
		var.name != null ? { Name = var.name } : {},
		var.tags,
	)
}

