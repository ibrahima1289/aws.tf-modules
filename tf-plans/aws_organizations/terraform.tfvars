# Step 1: Target region for Organizations API calls.
region = "us-east-1"

# Step 2: Keep false to safely adopt existing org; set true only for first-time bootstrap.
#         When true, a new org will be created with the specified settings. 
#         When false, the module will check that the existing org matches the specified settings and fail if there are any mismatches.
create_organization = false

# Step 3: Organization bootstrap settings used only when create_organization = true.
#         These settings are also used as guardrails to validate an existing org when create_organization = false, 
#         so be sure to set them to match your existing org if not creating a new one.
organization = {
  # ALL enables every available feature, including advanced features like SCPs and Tag Policies.
  # Others are: "CONSOLIDATED_BILLING" (only consolidated billing features) 
  #             "ALL_SUPPORTED" (all features except those requiring additional setup or costs, currently only Tag Policies).
  feature_set = "ALL"
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com"
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
    "BACKUP_POLICY",
    "AISERVICES_OPT_OUT_POLICY"
  ]
}

# Step 4: Common tags applied to all taggable resources.
tags = {
  project     = "aws-organizations"
  environment = "platform"
  owner       = "cloud-team"
}

# Step 5: Create multiple OUs.
organizational_units = [
  {
    key        = "security"
    name       = "Security"
    parent_key = "ROOT"
    tags = {
      purpose = "security-services"
    }
  },
  {
    key        = "workloads"
    name       = "Workloads"
    parent_key = "ROOT"
  },
  {
    key        = "production"
    name       = "Prod"
    parent_key = "workloads"
  },
  {
    key        = "nonprod"
    name       = "Dev"
    parent_key = "workloads"
  }
]

# Step 6: Create multiple accounts.
accounts = [
  {
    key        = "shared"
    name       = "SharedServices"
    email      = "aws-shared-services@example.com"
    parent_key = "security"
    tags = {
      account_type = "shared"
    }
  },
  {
    key                        = "prod-apps"
    name                       = "ProdApplications"
    email                      = "aws-prod-apps@example.com"
    parent_key                 = "production"
    iam_user_access_to_billing = "DENY"
  },
  {
    key        = "dev-apps"
    name       = "DevApplications"
    email      = "aws-dev-apps@example.com"
    parent_key = "nonprod"
  }
]

# Step 7: Create policies.
policies = [
  {
    key         = "deny-leave-org"
    name        = "DenyLeaveOrganization"
    description = "Prevents member accounts from leaving the organization"
    type        = "SERVICE_CONTROL_POLICY"
    content     = "" # Loaded from policies/deny-leave-org.json at plan time
  }
]

# Step 8: Attach policies to ROOT, OUs, or accounts.
policy_attachments = [
  {
    key         = "attach-root-deny-leave"
    policy_key  = "deny-leave-org"
    target_type = "ROOT"
    target_key  = "" # Ignored for ROOT targets
  }
]
