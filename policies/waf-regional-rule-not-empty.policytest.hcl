# Copyright IBM Corp. 2026

policytest {
  targets = [
    "waf-regional-rule-not-empty.policy.hcl"
  ]
}

# Test 1: PASS - Rule with single predicate
resource "aws_wafregional_rule" "single_predicate_pass" {
  attrs = {
    name        = "regional-rule-single"
    metric_name = "regionalrulesingle"
    predicate = [
      {
        type    = "IPMatch"
        data_id = "example-ipset-id"
        negated = false
      }
    ]
  }
}

# Test 2: PASS - Rule with multiple predicates
resource "aws_wafregional_rule" "multiple_predicates_pass" {
  attrs = {
    name        = "regional-rule-multiple"
    metric_name = "regionalrulemultiple"
    predicate = [
      {
        type    = "IPMatch"
        data_id = "example-ipset-id"
        negated = false
      },
      {
        type    = "GeoMatch"
        data_id = "example-geo-id"
        negated = false
      }
    ]
  }
}

# Test 3: FAIL - Rule with empty predicates
resource "aws_wafregional_rule" "empty_predicates_fail" {
  expect_failure = true
  attrs = {
    name        = "regional-rule-empty"
    metric_name = "regionalruleempty"
    predicate   = []
  }
}

# Test 4: FAIL - Rule with no predicates
resource "aws_wafregional_rule" "missing_predicates_fail" {
  expect_failure = true
  attrs = {
    name        = "regional-rule-missing"
    metric_name = "regionalrulemissing"
  }
}
