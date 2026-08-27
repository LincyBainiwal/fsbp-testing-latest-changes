# Copyright IBM Corp. 2026

policytest {
  targets = [
    "access-keys-rotated.policy.hcl"
  ]
}

# Test 1: PASS - properly configured AWS managed Config rule with default 90-day rotation
resource "aws_config_config_rule" "pass_default" {
  attrs = {
    name = "access-keys-rotated"
    source = [{
      owner             = "AWS"
      source_identifier = "ACCESS_KEYS_ROTATED"
    }]
  }
}

# Test 2: PASS - explicit maxAccessKeyAge = 90
resource "aws_config_config_rule" "pass_explicit_90" {
  attrs = {
    name = "access-keys-rotated"
    source = [{
      owner             = "AWS"
      source_identifier = "ACCESS_KEYS_ROTATED"
    }]
    input_parameters = "{\"maxAccessKeyAge\":\"90\"}"
  }
}

# Test 2b: FAIL - maxAccessKeyAge is not customizable per IAM.3; any value other than 90
# (here, 30) makes Security Hub mark the control NON_COMPLIANT.
resource "aws_config_config_rule" "fail_custom_30" {
  expect_failure = true
  attrs = {
    name = "access-keys-rotated"
    source = [{
      owner             = "AWS"
      source_identifier = "ACCESS_KEYS_ROTATED"
    }]
    input_parameters = "{\"maxAccessKeyAge\":\"30\"}"
  }
}

# Test 3: FAIL - wrong source_identifier
resource "aws_config_config_rule" "fail_wrong_source" {
  expect_failure = true
  attrs = {
    name = "access-keys-rotated"
    source = [{
      owner             = "AWS"
      source_identifier = "SOME_OTHER_RULE"
    }]
  }
}

# Test 4: FAIL - not AWS managed (custom owner)
resource "aws_config_config_rule" "fail_custom_owner" {
  expect_failure = true
  attrs = {
    name = "access-keys-rotated"
    source = [{
      owner             = "CUSTOM_LAMBDA"
      source_identifier = "ACCESS_KEYS_ROTATED"
    }]
  }
}

# Test 5: FAIL - maxAccessKeyAge greater than 90
resource "aws_config_config_rule" "fail_too_long" {
  expect_failure = true
  attrs = {
    name = "access-keys-rotated"
    source = [{
      owner             = "AWS"
      source_identifier = "ACCESS_KEYS_ROTATED"
    }]
    input_parameters = "{\"maxAccessKeyAge\":\"180\"}"
  }
}

# Test 6: Filtered out - unrelated Config rule (different name)
resource "aws_config_config_rule" "filtered_other_rule" {
  attrs = {
    name = "some-other-rule"
    source = [{
      owner             = "AWS"
      source_identifier = "SOME_OTHER_RULE"
    }]
  }
}