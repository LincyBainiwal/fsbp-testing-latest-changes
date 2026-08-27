# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ssm-automation-block-public-sharing.policy.hcl"
  ]
}

# --------------- PASS cases ---------------

# Test 1: PASS - Correct setting_id with value "Disable"
resource "aws_ssm_service_setting" "pass_public_sharing_disabled" {
  attrs = {
    setting_id    = "/ssm/documents/console/public-sharing-permission"
    setting_value = "Disable"
  }
}

# Test 2: PASS - Unrelated SSM setting alongside the required one
# The unrelated setting must NOT fail (old bug: first enforce block failed it).
# The filter now correctly scopes evaluation to the required setting_id only.
resource "aws_ssm_service_setting" "pass_unrelated_setting_alongside" {
  attrs = {
    setting_id    = "/ssm/managed-instance/activation-tier"
    setting_value = "standard"
  }
}

# --------------- FAIL cases (value wrong) ---------------

# Test 3: FAIL - Correct setting_id but value is "Enable"
resource "aws_ssm_service_setting" "fail_public_sharing_enabled" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/documents/console/public-sharing-permission"
    setting_value = "Enable"
  }
}

# Test 4: FAIL - Correct setting_id but value is "Allow"
resource "aws_ssm_service_setting" "fail_wrong_value" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/documents/console/public-sharing-permission"
    setting_value = "Allow"
  }
}

# Test 5: FAIL - Correct setting_id but empty setting_value
resource "aws_ssm_service_setting" "fail_empty_setting_value" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/documents/console/public-sharing-permission"
    setting_value = ""
  }
}

# Test 6: FAIL - Correct setting_id but setting_value absent
resource "aws_ssm_service_setting" "fail_missing_setting_value" {
  expect_failure = true
  attrs = {
    setting_id = "/ssm/documents/console/public-sharing-permission"
  }
}

# Test 7: FAIL - Case sensitivity — "disable" (lowercase) is not "Disable"
resource "aws_ssm_service_setting" "fail_case_sensitive_value" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/documents/console/public-sharing-permission"
    setting_value = "disable"
  }
}

# --------------- FAIL cases (existence check) ---------------

# Test 8: FAIL - Only an unrelated SSM setting in the plan — no public-sharing setting at all.
# The existence check (block_public_sharing_exists) must catch this.
# NOTE: This test has ONLY an unrelated setting — no public-sharing setting resource.
resource "aws_ssm_service_setting" "fail_no_public_sharing_setting" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/managed-instance/activation-tier"
    setting_value = "standard"
  }
}