# Copyright IBM Corp. 2026

policytest {
    targets = [
        "inspector-ec2-scan-enabled.policy.hcl"
    ]
}

# Test 1: PASS - EC2 only in resource_types
resource "aws_inspector2_enabler" "pass_ec2_only" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2"]
  }
}

# Test 2: PASS - Multiple resource types including EC2
resource "aws_inspector2_enabler" "pass_multiple_types_with_ec2" {
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["EC2", "ECR", "LAMBDA"]
  }
}

# Test 3: FAIL - No EC2 in resource_types
resource "aws_inspector2_enabler" "fail_no_ec2" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = ["ECR", "LAMBDA"]
  }
}

# Test 4: FAIL - Empty resource_types list
resource "aws_inspector2_enabler" "fail_empty_resource_types" {
  expect_failure = true
  attrs = {
    account_ids = ["123456789012"]
    resource_types = []
  }
}

# Test 5: PASS - EC2 scanning neabled
resource "aws_inspector2_organization_configuration" "pass_ec2_enabled" {
  attrs = {
    auto_enable = [
      {
        ec2 = true
      }
    ]
  }
}

# Test 6: FAIL - EC2 scanning disabled
resource "aws_inspector2_organization_configuration" "fail_ec2_disabled" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        ec2 = false
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

# Test 8: FAIL - EC2 scanning not configured
resource "aws_inspector2_organization_configuration" "fail_no_ec2_config" {
  expect_failure = true
  attrs = {
    auto_enable = [
      {
        ecr = true
      }
    ]
  }
}
