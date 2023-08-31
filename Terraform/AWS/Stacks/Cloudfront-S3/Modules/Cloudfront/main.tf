locals {
  s3_origin_id = var.domain_name
  # iam_arn = var.bucket_arn_s3
}

###################################
# CloudFront Origin Access Identity
###################################
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = var.domain_name
}

###################################
# CloudFront Distribution
###################################
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = var.domain_name
    # origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
    origin_id                = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "Bucket access of ${var.domain_name}"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain_name

    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"  #One of allow-all, https-only, or redirect-to-https.
    compress               = false        #true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"                               #(Required) - Method that you want to use to restrict distribution of your content by country: none, whitelist, or blacklist.
      # locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = var.env_name
    Name = var.name
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

###################################
# IAM Policy Document
###################################
data "aws_iam_policy_document" "read_gitbook_bucket" {
  policy_id = "PolicyForCloudFrontPrivateContent"
  
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn_s3}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }

  statement {
    sid       = "2"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.bucket_arn_s3]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }

  statement {
    sid       = "3"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn_s3}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }

}

###################################
# S3 Bucket Policy
###################################
resource "aws_s3_bucket_policy" "read_gitbook" {
  bucket = var.bucket_id_s3
  policy = data.aws_iam_policy_document.read_gitbook_bucket.json
}