region        = "us-east-1"
function_name = "test_lambda"
runtime       = "python3.11"
handler       = "index.print_family_tree"

memory_size = 256
timeout     = 10

tags = {
  project = "demo"
}

enable_function_url    = true
function_url_auth_type = "NONE"

# Ensure the Lambda function is created by providing a package source.
# Option 1: Zip package via local file
package_type = "Zip"
filename     = "./builds/index.zip"

# Option 2: Zip package via S3 (uncomment to use instead of filename)
# s3_bucket = "my-bucket"
# s3_key    = "lambda/builds/example-lambda.zip"
# s3_object_version = null

# Option 3: Container image (use when package_type = "Image")
# package_type = "Image"
# image_uri    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example:latest"

# Scaling options
# Reserved concurrency caps concurrent executions for the function
reserved_concurrent_executions = 10

# Provisioned concurrency keeps a number of executions warm on an alias
# Set alias name and the desired provisioned concurrency
enable_provisioned_concurrency    = true
provisioned_concurrency_alias     = "dev"
provisioned_concurrent_executions = 3

# Example: Zip package from S3 (uncomment to use)
# s3_bucket = "my-bucket"
# s3_key    = "lambda/builds/example-lambda.zip"
# s3_object_version = null

# Example: Container image (comment out Zip settings)
# image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/example:latest"
