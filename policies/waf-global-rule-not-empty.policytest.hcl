# Copyright IBM Corp. 2026

policytest {
    targets = [
        "waf-global-rule-not-empty.policy.hcl"
    ]
}

# Test 1: PASS - WAF rule with single predicate
resource "aws_waf_rule" "pass_with_single_predicate" {
  attrs = {
    name        = "example-rule"
    metric_name = "exampleRule"
    predicates = [
      {
        data_id = "12345678-1234-1234-1234-123456789012"
        negated = false
        type    = "IPMatch"
      }
    ]
  }
}

# Test 2: PASS - WAF rule with multiple predicates
resource "aws_waf_rule" "pass_with_multiple_predicates" {
  attrs = {
    name        = "multi-rule"
    metric_name = "multiRule"
    predicates = [
      {
        data_id = "12345678-1234-1234-1234-123456789012"
        negated = false
        type    = "IPMatch"
      },
      {
        data_id = "87654321-4321-4321-4321-210987654321"
        negated = false
        type    = "ByteMatch"
      },
      {
        data_id = "11111111-2222-3333-4444-555555555555"
        negated = true
        type    = "SqlInjectionMatch"
      }
    ]
  }
}

# Test 3: FAIL - WAF rule without predicates attribute
resource "aws_waf_rule" "fail_with_no_predicates_attribute" {
  expect_failure = true
  attrs = {
    name        = "empty-rule"
    metric_name = "emptyRule"
  }
}

# Test 4: FAIL - WAF rule with empty predicates list
resource "aws_waf_rule" "fail_with_empty_predicates_list" {
  expect_failure = true
  attrs = {
    name        = "empty-list-rule"
    metric_name = "emptyListRule"
    predicates  = []
  }
}