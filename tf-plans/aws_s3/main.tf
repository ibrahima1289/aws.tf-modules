
module "aws_s3" {
  source               = "../../modules/storage/aws_s3"
  region               = var.region
  tags                 = var.tags
  bucket_defaults      = var.bucket_defaults
  buckets              = var.buckets
  replication_role_arn = var.replication_role_arn
}
