locals {
  # Step 1: Compute a one-time date stamp used for resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build common tags merged into every resource created by this module.
  common_tags = merge(var.tags, { created_date = local.created_date })

  # Step 3: Convert the clusters list to a stable map keyed by cluster.key.
  # Used as the for_each argument on aws_ecs_cluster.
  clusters_map = { for c in var.clusters : c.key => c }

  # Step 4: Convert the task_definitions list to a stable map keyed by task.key.
  # Used as the for_each argument on aws_ecs_task_definition and the log groups.
  task_definitions_map = { for t in var.task_definitions : t.key => t }

  # Step 5: Convert the services list to a stable map keyed by service.key.
  # Used as the for_each argument on aws_ecs_service.
  services_map = { for s in var.services : s.key => s }
}
