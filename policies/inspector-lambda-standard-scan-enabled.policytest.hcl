# Copyright IBM Corp. 2026

policytest {
    targets = [
        "inspector-lambda-standard-scan-enabled.policy.hcl"
    ]
}

# Test 1: PASS - LAMBDA only in resource_types
resource "aws_inspector2_enabler" "pass_lambda_only" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["LAMBDA"]
  }
}

# Test 2: PASS - Multiple resource types including LAMBDA
resource "aws_inspector2_enabler" "pass_multiple_types_with_lambda" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2", "LAMBDA_CODE", "LAMBDA"]
  }
}

# Test 3: FAIL - No LAMBDA in resource_types
resource "aws_inspector2_enabler" "fail_no_lambda" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2", "LAMBDA_CODE"]
  }
}

# Test 4: FAIL - Empty resource_types list
resource "aws_inspector2_enabler" "fail_lambda_empty_resource_types" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = []
  }
}

# Test 5: PASS - Lambda scanning neabled
resource "aws_inspector2_organization_configuration" "pass_lambda_enabled" {
  attrs = {
    auto_enable = [
      {
        lambda = true
      }
    ]
  }
}

# Test 6: FAIL - Lambda scanning disabled
resource "aws_inspector2_organization_configuration" "fail_lambda_disabled" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        lambda = false
      }
    ]
  }
}

# Test 7: FAIL - Empty auto_enable block
resource "aws_inspector2_organization_configuration" "fail_no_auto_enable" {
  attrs = {
    auto_enable = []
  }
}

# Test 8: FAIL - Lambda scanning not configured
resource "aws_inspector2_organization_configuration" "fail_no_lambda_config" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        ec2 = true
      }
    ]
  }
}
