# Copyright IBM Corp. 2026

policytest {
  targets = [
    "waf-regional-rulegroup-not-empty.policy.hcl"
  ]
}

# Test 1: PASS - Rule group with one activated rule
resource "aws_wafregional_rule_group" "pass_with_one_activated_rule" {
  attrs = {
    name        = "example-rule-group"
    metric_name = "exampleRuleGroup"
    activated_rule = [
      {
        action = {
          type = "BLOCK"
        }
        priority = 1
        rule_id  = "rule-12345"
        type     = "REGULAR"
      }
    ]
  }
}

# Test 2: PASS - Rule group with multiple activated rules
resource "aws_wafregional_rule_group" "pass_with_multiple_activated_rules" {
  attrs = {
    name        = "example-rule-group"
    metric_name = "exampleRuleGroup"
    activated_rule = [
      {
        action = {
          type = "BLOCK"
        }
        priority = 1
        rule_id  = "rule-12345"
        type     = "REGULAR"
      },
      {
        action = {
          type = "COUNT"
        }
        priority = 2
        rule_id  = "rule-67890"
        type     = "RATE_BASED"
      }
    ]
  }
}

# Test 3: FAIL - Rule group with no activated_rule blocks
resource "aws_wafregional_rule_group" "fail_with_no_activated_rule_blocks" {
  expect_failure = true
  attrs = {
    name        = "example-rule-group"
    metric_name = "exampleRuleGroup"
  }
}

# Test 4: FAIL - Rule group with empty activated_rule list
resource "aws_wafregional_rule_group" "fail_with_empty_activated_rule_list" {
  expect_failure = true
  attrs = {
    name           = "example-rule-group"
    metric_name    = "exampleRuleGroup"
    activated_rule = []
  }
}