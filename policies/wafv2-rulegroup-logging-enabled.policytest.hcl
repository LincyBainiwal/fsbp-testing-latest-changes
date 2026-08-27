# Copyright IBM Corp. 2026

policytest {
  targets = ["wafv2-rulegroup-logging-enabled.policy.hcl"]
}

resource "aws_wafv2_rule_group" "compliant_rule_group" {
  attrs = {
    name     = "rg-compliant"
    scope    = "REGIONAL"
    capacity = 10

    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "rg-compliant-metric"
      sampled_requests_enabled   = true
    }]

    rule = [
      {
        name     = "allow-good"
        priority = 1
        action   = [{ allow = [{}] }]
        statement = [{
          geo_match_statement = [{
            country_codes = ["US"]
          }]
        }]
        visibility_config = [{
          cloudwatch_metrics_enabled = true
          metric_name                = "allow-good-metric"
          sampled_requests_enabled   = true
        }]
      }
    ]
  }
}

resource "aws_wafv2_rule_group" "rule_group_metrics_disabled" {
  expect_failure = true
  attrs = {
    name     = "rg-resource-disabled"
    scope    = "REGIONAL"
    capacity = 10

    visibility_config = [{
      cloudwatch_metrics_enabled = false
      metric_name                = "rg-disabled-metric"
      sampled_requests_enabled   = true
    }]

    rule = [
      {
        name     = "allow-good"
        priority = 1
        action   = [{ allow = [{}] }]
        statement = [{
          geo_match_statement = [{
            country_codes = ["US"]
          }]
        }]
        visibility_config = [{
          cloudwatch_metrics_enabled = true
          metric_name                = "allow-good-metric"
          sampled_requests_enabled   = true
        }]
      }
    ]
  }
}

resource "aws_wafv2_rule_group" "rule_group_missing_rule_visibility" {
  expect_failure = true
  attrs = {
    name     = "rg-missing-rule-visibility"
    scope    = "REGIONAL"
    capacity = 10

    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "rg-missing-rule-visibility-metric"
      sampled_requests_enabled   = true
    }]

    rule = [
      {
        name     = "missing-visibility"
        priority = 1
        action   = [{ allow = [{}] }]
        statement = [{
          geo_match_statement = [{
            country_codes = ["US"]
          }]
        }]
      }
    ]
  }
}

resource "aws_wafv2_web_acl" "compliant_web_acl" {
  attrs = {
    name  = "web-acl-compliant"
    scope = "REGIONAL"

    default_action = [{
      allow = [{}]
    }]

    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "web-acl-compliant-metric"
      sampled_requests_enabled   = true
    }]

    rule = [
      {
        name     = "managed-rule"
        priority = 1
        override_action = [{
          none = [{}]
        }]
        statement = [{
          managed_rule_group_statement = [{
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
          }]
        }]
        visibility_config = [{
          cloudwatch_metrics_enabled = true
          metric_name                = "managed-rule-metric"
          sampled_requests_enabled   = true
        }]
      }
    ]
  }
}

resource "aws_wafv2_web_acl" "web_acl_rule_metrics_disabled" {
  expect_failure = true
  attrs = {
    name  = "web-acl-rule-metrics-disabled"
    scope = "REGIONAL"

    default_action = [{
      allow = [{}]
    }]

    visibility_config = [{
      cloudwatch_metrics_enabled = true
      metric_name                = "web-acl-rule-metrics-disabled-metric"
      sampled_requests_enabled   = true
    }]

    rule = [
      {
        name     = "bad-managed-rule"
        priority = 1
        override_action = [{
          none = [{}]
        }]
        statement = [{
          managed_rule_group_statement = [{
            name        = "AWSManagedRulesCommonRuleSet"
            vendor_name = "AWS"
          }]
        }]
        visibility_config = [{
          cloudwatch_metrics_enabled = false
          metric_name                = "bad-managed-rule-metric"
          sampled_requests_enabled   = true
        }]
      }
    ]
  }
}
