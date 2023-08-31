locals {
  system_name = "api"
  application_name = "glovender"
  prefix           = "glov"
  service_full_name = "${local.prefix}-${local.application_name}-${var.env_name}-${local.system_name}"
 
}

module "s3" {
  source = "../../Modules/S3"

  acl = var.bucket_acl
  bucket_name = var.bucket_name
  env_name = var.env_name
  cors_rules_list = var.bucket_cors_rules
}

module "cloudfront"{
  source = "../../Modules/Cloudfront"
  name = var.cloudfront_name
  domain_name = "${var.bucket_name}.s3.amazonaws.com"
  bucket_arn_s3 = module.s3.bucket_arn
  bucket_id_s3 = module.s3.bucket_id
  env_name = var.env_name
}