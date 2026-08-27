# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-lambda-protection-enabled.policy.hcl"
    ]
}

# Test 1: PASS - Lambda Protection feature enabled
resource "aws_guardduty_detector_feature" "pass_lambda_network_logs_enabled" {
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "LAMBDA_NETWORK_LOGS"
    status = "ENABLED"
  }
}

# Test 2: FAIL - Lambda Protection feature disabled
resource "aws_guardduty_detector_feature" "fail_lambda_network_logs_disabled" {
  expect_failure = true
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "LAMBDA_NETWORK_LOGS"
    status = "DISABLED"
  }
}

# Test 3: FAIL - Lambda Protection feature status missing (defaults to DISABLED)
resource "aws_guardduty_detector_feature" "fail_lambda_network_logs_status_missing" {
  expect_failure = true
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "LAMBDA_NETWORK_LOGS"
  }
}

# Test 4: PASS - GuardDuty detector enabled
resource "aws_guardduty_organization_configuration_feature" "pass_org_lambda_network_logs" {
  attrs = {
    name = "LAMBDA_NETWORK_LOGS"
    auto_enable = "ALL"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 5: FAIL - GuardDuty detector disabled
resource "aws_guardduty_organization_configuration_feature" "fail_org_lambda_network_logs" {
  expect_failure = true
  attrs = {
    name = "LAMBDA_NETWORK_LOGS"
    auto_enable = "NONE"
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
  }
}

# Test 6: SKIP - Different feature name (not LAMBDA_NETWORK_LOGS) - should be filtered out
resource "aws_guardduty_detector_feature" "skip_different_feature" {
  attrs = {
    detector_id = "12abc34d567e8fa901bc2d34e56789f0"
    name = "S3_DATA_EVENTS"
    status = "ENABLED"
  }
}
