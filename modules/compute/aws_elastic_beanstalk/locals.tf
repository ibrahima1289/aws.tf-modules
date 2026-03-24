locals {
  # Step 1: Compute a one-time date stamp used for resource tagging.
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Step 2: Build common tags merged into every resource created by this module.
  common_tags = merge(var.tags, { created_date = local.created_date })

  # Step 3: Convert the applications list to a stable map keyed by application.key.
  # Used as the for_each argument on aws_elastic_beanstalk_application.
  applications_map = { for a in var.applications : a.key => a }

  # Step 4: Convert the environments list to a stable map keyed by environment.key.
  # Used as the for_each argument on aws_elastic_beanstalk_environment.
  environments_map = { for e in var.environments : e.key => e }

  # Step 5: Build the full flat list of aws_elastic_beanstalk_environment `setting`
  # blocks for each environment.  Convenience variables (instance type, VPC, etc.)
  # are translated into EBS namespace/option_name/value triplets here, so the
  # dynamic "setting" block in main.tf stays clean and uniform.
  environment_settings = {
    for e in var.environments : e.key => concat(

      # ── Instance configuration ─────────────────────────────────────────────
      [
        {
          namespace = "aws:autoscaling:launchconfiguration"
          name      = "InstanceType"
          value     = e.instance_type
          resource  = "" # No specific resource; applies to the whole environment
          # resource can be a resource like an ASG or ELB name to target settings more narrowly
        },
        {
          namespace = "aws:autoscaling:launchconfiguration"
          name      = "IamInstanceProfile"
          value     = e.iam_instance_profile
          resource  = "" # No specific resource; applies to the whole environment 
        },
      ],

      # EC2 key pair — optional; omitted when null so EBS uses no-key access
      e.ec2_key_name != null ? [{ namespace = "aws:autoscaling:launchconfiguration", name = "EC2KeyName", value = e.ec2_key_name, resource = "" }] : [],

      # ── Environment type and load balancer ─────────────────────────────────
      [
        {
          namespace = "aws:elasticbeanstalk:environment"
          name      = "EnvironmentType"
          value     = e.environment_type
          resource  = ""
        },
        {
          namespace = "aws:elasticbeanstalk:environment"
          name      = "LoadBalancerType"
          value     = e.load_balancer_type
          resource  = ""
        },
      ],

      # Service role — optional; defaults to the EBS-managed role when omitted
      e.service_role != null ? [{ namespace = "aws:elasticbeanstalk:environment", name = "ServiceRole", value = e.service_role, resource = "" }] : [],

      # ── Auto-scaling group capacity ────────────────────────────────────────
      [
        {
          namespace = "aws:autoscaling:asg"
          name      = "MinSize"
          value     = tostring(e.min_instances)
          resource  = ""
        },
        {
          namespace = "aws:autoscaling:asg"
          name      = "MaxSize"
          value     = tostring(e.max_instances)
          resource  = ""
        },
      ],

      # ── Deployment policy ──────────────────────────────────────────────────
      [
        {
          namespace = "aws:elasticbeanstalk:command"
          name      = "DeploymentPolicy"
          value     = e.deployment_policy
          resource  = ""
        },
      ],

      # ── Health check and health reporting ─────────────────────────────────
      [
        {
          namespace = "aws:elasticbeanstalk:application"
          name      = "Application Healthcheck URL"
          value     = e.health_check_path
          resource  = ""
        },
        {
          namespace = "aws:elasticbeanstalk:healthreporting:system"
          name      = "SystemType"
          value     = e.health_reporting
          resource  = ""
        },
      ],

      # ── VPC networking — all optional ──────────────────────────────────────
      e.vpc_id != null ? [{ namespace = "aws:ec2:vpc", name = "VPCId", value = e.vpc_id, resource = "" }] : [],
      length(coalesce(e.instance_subnets, [])) > 0 ? [{ namespace = "aws:ec2:vpc", name = "Subnets", value = join(",", e.instance_subnets), resource = "" }] : [],
      length(coalesce(e.elb_subnets, [])) > 0 ? [{ namespace = "aws:ec2:vpc", name = "ELBSubnets", value = join(",", e.elb_subnets), resource = "" }] : [],

      # ── Environment variables ─────────────────────────────────────────────
      # Each key-value pair in env_vars becomes one EBS setting in the
      # aws:elasticbeanstalk:application:environment namespace.
      [for k, v in coalesce(e.env_vars, {}) : {
        namespace = "aws:elasticbeanstalk:application:environment"
        name      = k
        value     = v
        resource  = ""
      }],

      # ── Custom / arbitrary settings ────────────────────────────────────────
      # Allows callers to pass any additional EBS namespace/name/value triplet
      # without modifying the module (e.g. scaling triggers, scheduled actions).
      [for s in coalesce(e.custom_settings, []) : {
        namespace = s.namespace
        name      = s.name
        value     = s.value
        resource  = s.resource != null ? s.resource : ""
      }]
    )
  }
}
