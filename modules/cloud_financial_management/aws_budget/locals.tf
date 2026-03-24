locals {
  # Step 1: Compute a one-time date stamp for resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build common tags applied to every resource in this module call.
  common_tags = merge(var.tags, {
    created_date = local.created_date
  })

  # Step 3: Convert the budgets list to a stable map keyed by budget.key for for_each.
  budgets_map = { for b in var.budgets : b.key => b }

  # Step 4: Flatten all budget actions into a single map for for_each creation.
  # Key format: "<budget_key>_<action_key>" ensures uniqueness across all budgets.
  budget_actions_map = {
    for entry in flatten([
      for b in var.budgets : [
        for a in coalesce(b.actions, []) : merge(a, { budget_key = b.key })
      ]
    ]) : "${entry.budget_key}_${entry.action_key}" => entry
  }
}
