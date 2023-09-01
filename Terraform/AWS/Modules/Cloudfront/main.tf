locals {
  s3_origin_id = var.domain_name
  # iam_arn = var.bucket_arn_s3
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = var.domain_name
}

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