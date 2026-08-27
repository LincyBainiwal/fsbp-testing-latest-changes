# Copyright IBM Corp. 2026

policytest {
    targets = [
        "waf-regional-webacl-not-empty.policy.hcl"
    ]
}

# Test 1: PASS - Web ACL with one rule configured
resource "aws_wafregional_web_acl" "pass_with_single_rule" {
  attrs = {
    name        = "example-web-acl"
    metric_name = "exampleWebAcl"
    default_action = [{
      type = "ALLOW"
    }]
    rule = [{
      priority = 1
      rule_id  = "rule-123456"
      action = [{
        type = "BLOCK"
      }]
      type = "REGULAR"
    }]
  }
}

# Test 2: FAIL - Web ACL with empty rule list
resource "aws_wafregional_web_acl" "fail_with_empty_rules" {
  expect_failure = true
  attrs = {
    name        = "empty-web-acl"
    metric_name = "emptyWebAcl"
    default_action = [{
      type = "ALLOW"
    }]
    rule = []
  }
}

# Test 3: PASS - Web ACL with multiple rules configured
resource "aws_wafregional_web_acl" "pass_with_multiple_rules" {
  attrs = {
    name        = "multi-rule-web-acl"
    metric_name = "multiRuleWebAcl"
    default_action = [{
      type = "ALLOW"
    }]
    rule = [
      {
        priority = 1
        rule_id  = "rule-123456"
        action = [{
          type = "BLOCK"
        }]
        type = "REGULAR"
      },
      {
        priority = 2
        rule_id  = "rule-789012"
        action = [{
          type = "COUNT"
        }]
        type = "RATE_BASED"
      },
      {
        priority = 3
        rule_id  = "group-345678"
        override_action = [{
          type = "NONE"
        }]
        type = "GROUP"
      }
    ]
  }
}

# Test 4: FAIL - Web ACL with no rules
resource "aws_wafregional_web_acl" "fail_with_no_rules" {
  expect_failure = true
  attrs = {
    name        = "empty-web-acl"
    metric_name = "emptyWebAcl"
    default_action = [{
      type = "ALLOW"
    }]
  }
}