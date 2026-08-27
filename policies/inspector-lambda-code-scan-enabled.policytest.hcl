# Copyright IBM Corp. 2026

policytest {
    targets = [
        "inspector-lambda-code-scan-enabled.policy.hcl"
    ]
}

# Test 1: PASS - LAMBDA_CODE only in resource_types
resource "aws_inspector2_enabler" "pass_lambda_code_only" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["LAMBDA_CODE"]
  }
}

# Test 2: PASS - Multiple resource types including LAMBDA_CODE
resource "aws_inspector2_enabler" "pass_multiple_types_with_lambda_code" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2", "LAMBDA_CODE", "LAMBDA"]
  }
}

# Test 3: FAIL - No LAMBDA_CODE in resource_types
resource "aws_inspector2_enabler" "fail_no_lambda_code" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2", "LAMBDA"]
  }
}

# Test 4: FAIL - Empty resource_types list
resource "aws_inspector2_enabler" "fail_lambda_code_empty_resource_types" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = []
  }
}

# Test 5: PASS - Lambda Code scanning neabled
resource "aws_inspector2_organization_configuration" "pass_lambda_code_enabled" {
  attrs = {
    auto_enable = [
      {
        lambda = true
        lambda_code = true
      }
    ]
  }
}

# Test 6: FAIL - Lambda Code scanning disabled
resource "aws_inspector2_organization_configuration" "fail_lambda_code_disabled" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        lambda = true
        lambda_code = false
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

# Test 8: FAIL - Lambda Code scanning not configured
resource "aws_inspector2_organization_configuration" "fail_no_lambda_code_config" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        lambda = true
      }
    ]
  }
}

# Test 9: FAIL - Lambda and Lambda Code scanning disabled
resource "aws_inspector2_organization_configuration" "fail_lambda_lambda_code_disabled" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        lambda = false
        lambda_code = false
      }
    ]
  }
}
