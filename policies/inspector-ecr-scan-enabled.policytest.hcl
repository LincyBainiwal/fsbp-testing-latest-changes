# Copyright IBM Corp. 2026

policytest {
    targets = [
        "inspector-ecr-scan-enabled.policy.hcl"
    ]
}

# Test 1: PASS - ECR only in resource_types
resource "aws_inspector2_enabler" "pass_ecr_only" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["ECR"]
  }
}

# Test 2: PASS - Multiple resource types including ECR
resource "aws_inspector2_enabler" "pass_multiple_types_with_ecr" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2", "ECR", "LAMBDA"]
  }
}

# Test 3: FAIL - No ECR in resource_types
resource "aws_inspector2_enabler" "fail_no_ecr" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2", "LAMBDA"]
  }
}

# Test 4: FAIL - Empty resource_types list
resource "aws_inspector2_enabler" "fail_ecr_empty_resource_types" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = []
  }
}

# Test 5: PASS - ECR scanning neabled
resource "aws_inspector2_organization_configuration" "pass_ecr_enabled" {
  attrs = {
    auto_enable = [
      {
        ecr = true
      }
    ]
  }
}

# Test 6: FAIL - ECR scanning disabled
resource "aws_inspector2_organization_configuration" "fail_ecr_disabled" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        ecr = false
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

# Test 8: FAIL - ECR scanning not configured
resource "aws_inspector2_organization_configuration" "fail_no_ecr_config" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        ec2 = true
      }
    ]
  }
}
