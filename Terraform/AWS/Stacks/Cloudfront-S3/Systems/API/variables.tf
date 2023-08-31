########################
## Global Vars 
######################## 
variable "env_name" {
  description = "Name of the environment where the task is created."
}
 
variable "prefix" {
  description = "Prefix of the system."
}

variable "application_name" {
  
}

variable "env_full_name" {
  description = "Name of the environment including prefix where the task is created."  
}

variable "region" {
  description = "Region where the resources will be created"
}

variable "account_id" {
  description = "Id of the account where all  the resources will be created"
}

####################
## S3 Vars
####################
variable "bucket_acl" {
  description = "ACL of the bucket to create"
}

variable "bucket_name" {
  description = "Name of the Bucket to create"
}

variable "bucket_cors_rules" {
  description = "List of CORS rules for the bucket"

  type =  list(object({ 
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers = list(string)
    max_age_seconds = number 
  }))

}

####################
## Cloudfront
####################

variable "cloudfront_name" {
  
}
