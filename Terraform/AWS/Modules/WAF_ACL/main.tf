locals {
  common_tags = {
    terraform = "true"
  }
}

##########################################
## WAFv2 Web ACL (Web Acess Control List)
##########################################

resource "aws_wafv2_web_acl" "WafWebAcl" {
  name  = "wafv2-web-acl-test"                                       # (Required) Friendly name of the WebACL.
  scope = "CLOUDFRONT"                                               # (Required) Specifies whether this is for an AWS CloudFront distribution or for a regional application. Valid values are CLOUDFRONT or REGIONAL.

  default_action {                                                   # (Required) Action to perform if none of the rules contained in the WebACL match. 
    allow {
    }
  }

  visibility_config {                                                # (Required) Defines and enables Amazon CloudWatch metrics and web request sample collection.
    cloudwatch_metrics_enabled = true
    metric_name                = "WAF_Common_Protections"
    sampled_requests_enabled   = true
  }

#-------------------------------------------------------------------------

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"                   # (Required) Friendly name of the WebACL.
    priority = 0                                                    # AWS WAF processes rules with lower priority first. (If you define more than one Rule in a WebACL)
    override_action {                                               # (Optional) Override action to apply to the rules in a rule group.
      none {
      }
    }
    statement {                                                     #
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"                
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            allow {}
          }

          name = "SizeRestrictions_BODY"
        }

        rule_action_override {
          action_to_use {
            allow {}
          }

          name = "NoUserAgent_HEADER"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

#-------------------------------------------------------------------------

  rule {
    name     = "AWS-AWSManagedRulesLinuxRuleSet"
    priority = 1
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesLinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

#-------------------------------------------------------------------------

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 2
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

#-------------------------------------------------------------------------

  rule {
    name     = "AWS-AWSManagedRulesAnonymousIpList"
    priority = 3
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            allow {}
          }

          name = "HostingProviderIPList"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

#-------------------------------------------------------------------------

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 4
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }
  }

#-------------------------------------------------------------------------

  rule {
    name     = "AWS-AWSManagedRulesUnixRuleSet"
    priority = 5
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesUnixRuleSet"
      sampled_requests_enabled   = true
    }
  }

#-------------------------------------------------------------------------

  rule {
    name     = "AWS-AWSManagedRulesWindowsRuleSet"
    priority = 6
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesWindowsRuleSet"
        vendor_name = "AWS"
        rule_action_override {
          action_to_use {
            allow {}
          }

          name = "WindowsShellCommands_BODY"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesWindowsRuleSet"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(
    local.common_tags, {
      customer = "wafv2-web-acl"
    }
  )

}

################################
# 
################################

resource "aws_cloudwatch_log_group" "WafWebAclLoggroup" {
  name              = "aws-waf-logs-wafv2-web-acl"
  retention_in_days = 30
}

################################
# Web ACL logging configuration
################################

resource "aws_wafv2_web_acl_logging_configuration" "WafWebAclLogging" {
  log_destination_configs = [aws_cloudwatch_log_group.WafWebAclLoggroup.arn]
  resource_arn            = aws_wafv2_web_acl.WafWebAcl.arn
  depends_on = [
    aws_wafv2_web_acl.WafWebAcl,
    aws_cloudwatch_log_group.WafWebAclLoggroup
  ]
}

################################
# 
################################

resource "aws_wafv2_web_acl_association" "WafWebAclAssociation" {
  resource_arn = var.aws_lb_arn
  web_acl_arn  = aws_wafv2_web_acl.WafWebAcl.arn
  depends_on = [
    aws_wafv2_web_acl.WafWebAcl,
    aws_cloudwatch_log_group.WafWebAclLoggroup
  ]
}