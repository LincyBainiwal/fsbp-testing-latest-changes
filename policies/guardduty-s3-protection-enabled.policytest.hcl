# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-s3-protection-enabled.policy.hcl"
    ]
}

# Test 1: PASS - aws_guardduty_detector_feature with S3_DATA_EVENTS enabled
resource "aws_guardduty_detector_feature" "pass_feature_enabled" {
  attrs = {
    detector_id = "abc123"
    name = "S3_DATA_EVENTS"
    status = "ENABLED"
  }
}

# Test 2: FAIL - aws_guardduty_detector_feature with S3_DATA_EVENTS disabled
resource "aws_guardduty_detector_feature" "fail_feature_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "abc123"
    name = "S3_DATA_EVENTS"
    status = "DISABLED"
  }
}

# Test 3: SKIP - aws_guardduty_detector_feature with different feature name
resource "aws_guardduty_detector_feature" "skip_different_feature" {
  attrs = {
    detector_id = "abc123"
    name = "EKS_AUDIT_LOGS"
    status = "ENABLED"
  }
}

# Test 4: PASS - S3_DATA_EVENTS enabled
resource "aws_guardduty_organization_configuration_feature" "pass_org_s3_logs" {
  attrs = {
    name = "S3_DATA_EVENTS"
    auto_enable = "ALL"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 5: FAIL - S3_DATA_EVENTS disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_s3_logs" {
  expect_failure = true
  attrs = {
    name = "S3_DATA_EVENTS"
    auto_enable = "NONE"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}
