locals {
  common_tags = {
    terraform = "true"
  }
}

##########################################
## WAFv2 Web ACL (Web Acess Control List)
##########################################

resource "aws_wafv2_web_acl" "cloudfront" {
  name  = "cloudfront-webacl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfrontVisibilityConfig"
    sampled_requests_enabled   = true
  }

  tags = {
    Environment = "Production"
    Name        = "cloudfrontWebACL"
  }
}

resource "aws_cloudwatch_log_group" "WafWebAclLoggroup" {
  name              = "aws-waf-logs-wafv2-web-acl"
  retention_in_days = 30
}

################################
# Web ACL logging configuration
################################

resource "aws_wafv2_web_acl_logging_configuration" "WafWebAclLogging" {
  log_destination_configs = [aws_cloudwatch_log_group.WafWebAclLoggroup.arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront.arn
  depends_on = [
    aws_wafv2_web_acl.cloudfront,
    aws_cloudwatch_log_group.WafWebAclLoggroup
  ]
}

resource "aws_wafv2_web_acl_association" "WafWebAclAssociation" {
  resource_arn = var.aws_lb_arn
  web_acl_arn  = aws_wafv2_web_acl.cloudfront.arn
  depends_on = [
    aws_wafv2_web_acl.cloudfront,
    aws_cloudwatch_log_group.WafWebAclLoggroup
  ]
}