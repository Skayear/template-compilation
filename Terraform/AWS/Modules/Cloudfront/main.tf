locals {
  s3_origin_id = var.domain_name
  # iam_arn = var.bucket_arn_s3
}

# resource "aws_cloudfront_origin_access_control" "cloudfront_s3_oac" {
#   name                              = var.domain_name
#   description                       = "CloudFront S3 OAC"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }

resource "aws_cloudfront_origin_access_identity" "example" {
  comment = var.domain_name
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = var.domain_name
    # origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_s3_oac.id
    origin_id                = local.s3_origin_id
    custom_origin_config {
                        http_port              = 80
                        https_port             = 443
                        origin_protocol_policy = "https-only"
                        origin_ssl_protocols   = ["TLSv1.2"]
                }
    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
    # }
  }

  enabled             = true
  # is_ipv6_enabled     = false
  comment             = "Bucket access of ${var.domain_name}"

  # logging_config {
  #   include_cookies = false
  #   bucket          = "mylogs.s3.amazonaws.com"
  #   prefix          = "myprefix"
  # }

  # aliases = ["mysite.example.com", "yoursite.example.com"]            #(Optional) - Extra CNAMEs (alternate domain names), if any, for this distribution.

  # default_cache_behavior {
  #   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  #   cached_methods   = ["GET", "HEAD"]
  #   target_origin_id = local.s3_origin_id

  #   forwarded_values {
  #     query_string = false

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   viewer_protocol_policy = "allow-all"
  #   min_ttl                = 0
  #   default_ttl            = 3600
  #   max_ttl                = 86400
  # }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "example"

    default_ttl = 0
    min_ttl     = 0
    max_ttl     = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # Cache behavior with precedence 0
  # ordered_cache_behavior {
  #   path_pattern     = "/content/immutable/*"
  #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods   = ["GET", "HEAD", "OPTIONS"]
  #   target_origin_id = local.s3_origin_id

  #   forwarded_values {
  #     query_string = false
  #     headers      = ["Origin"]

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   default_ttl            = 86400
  #   max_ttl                = 31536000
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"
  # }

  # Cache behavior with precedence 1
  # ordered_cache_behavior {
  #   path_pattern     = "/content/*"
  #   allowed_methods  = ["GET", "HEAD", "OPTIONS"]
  #   cached_methods   = ["GET", "HEAD"]
  #   target_origin_id = local.s3_origin_id

  #   forwarded_values {
  #     query_string = false

  #     cookies {
  #       forward = "none"
  #     }
  #   }

  #   min_ttl                = 0
  #   default_ttl            = 3600
  #   max_ttl                = 86400
  #   compress               = true
  #   viewer_protocol_policy = "redirect-to-https"
  # }

  # price_class = "PriceClass_200"

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