# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ssm-automation-logging-enabled.policy.hcl"
  ]
}

# --------------- PASS cases ---------------

# Test 1: PASS - log-destination setting set to "CloudWatch"
resource "aws_ssm_service_setting" "pass_cloudwatch_destination" {
  attrs = {
    setting_id    = "/ssm/documents/console/customer-script-log-destination"
    setting_value = "CloudWatch"
  }
}

# Test 2: PASS - log-group-name setting set to a valid non-empty name
resource "aws_ssm_service_setting" "pass_log_group_name_configured" {
  attrs = {
    setting_id    = "/ssm/documents/console/customer-script-log-group-name"
    setting_value = "/aws/ssm/automation/executeScript"
  }
}

# Test 3: PASS - Unrelated SSM setting is NOT evaluated (filter scopes correctly)
resource "aws_ssm_service_setting" "pass_unrelated_setting_not_evaluated" {
  attrs = {
    setting_id    = "/ssm/managed-instance/activation-tier"
    setting_value = "standard"
  }
}

# Test 4: PASS - CloudWatch log group is no longer checked by this policy
# (the generic log-group-name check was removed as unrelated to SSM compliance)
resource "aws_cloudwatch_log_group" "pass_log_group_not_evaluated" {
  attrs = {
    name              = "/aws/ssm/automation/executeScript"
    retention_in_days = 7
  }
}

# --------------- FAIL cases — destination setting ---------------

# Test 5: FAIL - log-destination set to "S3" (not CloudWatch)
resource "aws_ssm_service_setting" "fail_s3_destination" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/documents/console/customer-script-log-destination"
    setting_value = "S3"
  }
}

# Test 6: FAIL - log-destination set to empty string
resource "aws_ssm_service_setting" "fail_empty_destination" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/documents/console/customer-script-log-destination"
    setting_value = ""
  }
}

# Test 7: FAIL - log-destination setting_value absent
resource "aws_ssm_service_setting" "fail_missing_destination_value" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/customer-script-log-destination"
  }
}

# --------------- FAIL cases — log-group-name setting ---------------

# Test 8: FAIL - log-group-name set to empty string
resource "aws_ssm_service_setting" "fail_empty_log_group_name" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/documents/console/customer-script-log-group-name"
    setting_value = ""
  }
}

# Test 9: FAIL - log-group-name setting_value absent
resource "aws_ssm_service_setting" "fail_missing_log_group_name_value" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/customer-script-log-group-name"
  }
}