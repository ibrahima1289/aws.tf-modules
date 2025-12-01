region = "us-west-2"
users = [
  {
    name                            = "s3-user"
    path                            = "/"
    force_destroy                   = false
    permissions_boundary            = null
    tags                            = { Owner = "s3-team" }
    create_access_key               = true
    access_key_pgp_key              = null
    access_key_status               = "Active"
    access_key_description          = "Access key for s3-user"
  },
  {
    name                            = "ec2-user"
    path                            = "/"
    force_destroy                   = false
    permissions_boundary            = null
    tags                            = { Owner = "ec2-team" }
    create_access_key               = true
    access_key_pgp_key              = null
    access_key_status               = "Inactive"
    access_key_description          = "Access key for ec2-user"
  },
  {
    name                            = "readonly-user"
    path                            = "/"
    force_destroy                   = false
    permissions_boundary            = null
    tags                            = { Owner = "readonly-team" }
    create_access_key               = false
    access_key_pgp_key              = null
    access_key_status               = "Inactive"
    access_key_description          = "Access key for readonly-user"
  }
]

groups = [
  { name = "s3-group" },
  { name = "ec2-group" }
]

user_group_memberships = [
  { user = "s3-user", groups = ["s3-group"] },
  { user = "ec2-user", groups = ["s3-group", "ec2-group"] },
  { user = "readonly-user", groups = ["s3-group"] }
]

policies = [
  {
    name        = "s3-policy"
    path        = "/"
    description = "Allow S3 management."
    policy_json = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ],
          "Resource": [
            "arn:aws:s3:::*",
            "arn:aws:s3:::*/*"
          ]
        }
      ]
    }
    EOF
  },
  {
    name        = "ec2-policy"
    path        = "/"
    description = "Allow EC2 management."
    policy_json = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:Describe*",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:RebootInstances",
            "ec2:TerminateInstances",
            "ec2:RunInstances"
          ],
          "Resource": "*"
        }
      ]
    }
    EOF
  }
]

group_policy_attachments = [
  { group = "s3-group", policy = "s3-policy" },
  { group = "ec2-group", policy = "ec2-policy" }
]

tags = {
  Environment = "dev"
}
