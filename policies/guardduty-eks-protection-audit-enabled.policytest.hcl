# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-eks-protection-audit-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Standalone account with EKS_AUDIT_LOGS enabled
resource "aws_guardduty_detector_feature" "pass_standalone_enabled" {
  attrs = {
    name = "EKS_AUDIT_LOGS"
    status = "ENABLED"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 2: FAIL - Standalone account with EKS_AUDIT_LOGS disabled
resource "aws_guardduty_detector_feature" "fail_standalone_disabled" {
  expect_failure = true
  attrs = {
    name = "EKS_AUDIT_LOGS"
    status = "DISABLED"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 3: FAIL - Standalone account with missing status (defaults to DISABLED)
resource "aws_guardduty_detector_feature" "fail_standalone_missing_status" {
  expect_failure = true
  attrs = {
    name = "EKS_AUDIT_LOGS"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 4: PASS - Organization configuration with auto_enable ALL
resource "aws_guardduty_organization_configuration_feature" "pass_org_auto_enable_all" {
  attrs = {
    name = "EKS_AUDIT_LOGS"
    auto_enable = "ALL"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 5: FAIL - Organization configuration with auto_enable NONE
resource "aws_guardduty_organization_configuration_feature" "fail_org_auto_enable_none" {
  expect_failure = true
  attrs = {
    name = "EKS_AUDIT_LOGS"
    auto_enable = "NONE"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 6: SKIP - Different feature type (S3_DATA_EVENTS) should be filtered out
resource "aws_guardduty_detector_feature" "skip_different_feature_standalone" {
  attrs = {
    name = "S3_DATA_EVENTS"
    status = "DISABLED"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}
