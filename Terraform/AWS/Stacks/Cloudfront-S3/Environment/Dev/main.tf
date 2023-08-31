locals {
  application_name = "test-cloudfront"
  prefix           = "test"
  env_name         = "dev"
  env_full_name      = "${local.prefix}-${local.application_name}-${local.env_name}"
  account_id       = "123456789123"

#################
## API Config
################# 
api_bucket_acl  = "public-read"
api_bucket_name = "bucket-${local.prefix}-${local.application_name}-${local.env_name}"
api_bucket_cors_rules = [{
allowed_headers = ["*"]
allowed_methods = ["PUT", "POST", "GET", "DELETE"]
allowed_origins = ["http://localhost:3000"]
expose_headers  = [""]
max_age_seconds = 3000
},
{
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE"]
    allowed_origins = ["https://google.com"]
    expose_headers  = [""]
    max_age_seconds = 3000
}]
#################
## Cloudfront
################# 
api_cloudfront_name = "cloudfront-${local.prefix}-${local.application_name}-${local.env_name}"
}

module "api" {
  source = "./../../Systems/API"

  env_name         = local.env_name
  prefix           = local.prefix
  application_name = local.application_name
  env_full_name    = local.env_full_name
  region           = var.region
  account_id       = local.account_id


  bucket_acl        = local.api_bucket_acl
  bucket_name       = local.api_bucket_name
  bucket_cors_rules = local.api_bucket_cors_rules

  cloudfront_name = local.api_cloudfront_name
}