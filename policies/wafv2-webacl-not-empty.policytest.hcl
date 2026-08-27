# Copyright IBM Corp. 2026

policytest {
  targets = [
    "wafv2-webacl-not-empty.policy.hcl"
  ]
}

# Pass case: Web ACL with single rule
resource "aws_wafv2_web_acl" "pass_with_single_rule" {
  attrs = {
    name  = "compliant-web-acl"
    scope = "REGIONAL"
    default_action = [{
      allow = [{}]
    }]
    rule = [
      {
        name     = "rate-limit-rule"
        priority = 1
        action = [{
          block = [{}]
        }]
        statement = [{
          rate_based_statement = [{
            limit              = 10000
            aggregate_key_type = "IP"
          }]
        }]
        visibility_config = [{
          cloudwatch_metrics_enabled = true
          metric_name                = "rate-limit-rule"
          sampled_requests_enabled   = true
        }]
      }
    ]
    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "compliant-web-acl"
      sampled_requests_enabled   = true
    }]
  }
}

# Pass case: Web ACL with multiple rules
resource "aws_wafv2_web_acl" "pass_with_multiple_rules" {
  attrs = {
    name  = "compliant-web-acl-multiple"
    scope = "CLOUDFRONT"
    default_action = [{
      allow = [{}]
    }]
    rule = [
      {
        name     = "ip-rate-limit"
        priority = 1
        action = [{
          block = [{}]
        }]
        statement = [{
          rate_based_statement = [{
            limit              = 2000
            aggregate_key_type = "IP"
          }]
        }]
        visibility_config = [{
          cloudwatch_metrics_enabled = true
          metric_name                = "ip-rate-limit"
          sampled_requests_enabled   = true
        }]
      },
      {
        name     = "geo-blocking"
        priority = 2
        action = [{
          block = [{}]
        }]
        statement = [{
          geo_match_statement = [{
            country_codes = ["CN", "RU"]
          }]
        }]
        visibility_config = [{
          cloudwatch_metrics_enabled = true
          metric_name                = "geo-blocking"
          sampled_requests_enabled   = true
        }]
      }
    ]
    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "compliant-web-acl-multiple"
      sampled_requests_enabled   = true
    }]
  }
}

# Fail case: Web ACL with empty rule list
resource "aws_wafv2_web_acl" "fail_with_empty_rules" {
  expect_failure = true
  attrs = {
    name  = "non-compliant-web-acl"
    scope = "REGIONAL"
    default_action = [{
      allow = [{}]
    }]
    rule = []
    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "non-compliant-web-acl"
      sampled_requests_enabled   = true
    }]
  }
}

# Fail case: Web ACL without rule attribute
resource "aws_wafv2_web_acl" "fail_without_rule_attribute" {
  expect_failure = true
  attrs = {
    name  = "non-compliant-web-acl-no-rules"
    scope = "REGIONAL"
    default_action = [{
      allow = [{}]
    }]
    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "non-compliant-web-acl-no-rules"
      sampled_requests_enabled   = true
    }]
  }
}
