# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-rds-protection-enabled.policy.hcl"
    ]
}

# Test 1: PASS - RDS Protection enabled
resource "aws_guardduty_detector_feature" "pass_rds_protection_enabled" {
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "RDS_LOGIN_EVENTS"
    status = "ENABLED"
  }
}

# Test 2: FAIL - RDS Protection disabled
resource "aws_guardduty_detector_feature" "fail_rds_protection_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "RDS_LOGIN_EVENTS"
    status = "DISABLED"
  }
}

# Test 3: FAIL - RDS Protection status missing (defaults to DISABLED)
resource "aws_guardduty_detector_feature" "fail_rds_protection_status_missing" {
  expect_failure = true
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "RDS_LOGIN_EVENTS"
  }
}

# Test 4: PASS - RDS Protection enabled
resource "aws_guardduty_organization_configuration_feature" "pass_org_rds_protection" {
  attrs = {
    name = "RDS_LOGIN_EVENTS"
    auto_enable = "ALL"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 5: FAIL - RDS Protection disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_rds_protection" {
  expect_failure = true
  attrs = {
    name = "RDS_LOGIN_EVENTS"
    auto_enable = "NONE"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 6: SKIP - Different feature name (not RDS_LOGIN_EVENTS) - should be filtered out
resource "aws_guardduty_detector_feature" "skip_different_feature" {
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "S3_DATA_EVENTS"
    status = "ENABLED"
  }
}
