#############################################
# AWS Lambda Module - Locals                #
#############################################

locals {
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Default assume role policy for Lambda service
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}
