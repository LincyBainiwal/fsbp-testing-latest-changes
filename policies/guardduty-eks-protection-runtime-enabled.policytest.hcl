# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-eks-protection-runtime-enabled.policy.hcl"
    ]
}

# Test 1: PASS - EKS Runtime Monitoring feature fully enabled with addon management
resource "aws_guardduty_detector_feature" "pass_fully_enabled" {
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 2: FAIL - EKS Runtime Monitoring feature with status DISABLED
resource "aws_guardduty_detector_feature" "fail_feature_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    status = "DISABLED"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        status = "ENABLED"
      }
    ]
  }
}

# Test 3: FAIL - EKS Runtime Monitoring enabled but addon management disabled
resource "aws_guardduty_detector_feature" "fail_addon_management_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    status = "ENABLED"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        status = "DISABLED"
      }
    ]
  }
}

# Test 4: FAIL - EKS Runtime Monitoring enabled but no additional_configuration
resource "aws_guardduty_detector_feature" "fail_no_addon_management" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    status = "ENABLED"
  }
}

# Test 5: PASS - EKS Runtime Monitoring feature fully enabled with addon management
resource "aws_guardduty_organization_configuration_feature" "pass_org_fully_enabled" {
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        auto_enable = "ALL"
      }
    ]
  }
}

# Test 6: FAIL - EKS Runtime Monitoring feature with status DISABLED
resource "aws_guardduty_organization_configuration_feature" "fail_org_feature_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    auto_enable = "NONE"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        auto_enable = "ALL"
      }
    ]
  }
}

# Test 7: FAIL - EKS Runtime Monitoring enabled but addon management disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_addon_management_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    auto_enable = "ALL"
    additional_configuration = [
      {
        name = "EKS_ADDON_MANAGEMENT"
        auto_enable = "NONE"
      }
    ]
  }
}

# Test 8: FAIL - EKS Runtime Monitoring enabled but no additional_configuration
resource "aws_guardduty_organization_configuration_feature" "fail_org_no_addon_management" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "EKS_RUNTIME_MONITORING"
    auto_enable = "ALL"
  }
}

# Test 9: SKIP - Different feature type (S3_DATA_EVENTS) should be filtered out
resource "aws_guardduty_detector_feature" "pass_different_feature_filtered" {
  attrs = {
    detector_id = "abc123"
    name = "S3_DATA_EVENTS"
    status = "ENABLED"
  }
}
