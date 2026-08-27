# Copyright IBM Corp. 2026

policytest {
    targets = [
        "guardduty-enabled-centralized.policy.hcl"
    ]
}

# Test 1: PASS - GuardDuty detector with enable explicitly set to true
resource "aws_guardduty_detector" "pass_explicitly_enabled" {
  attrs = {
    enable = true
    finding_publishing_frequency = "SIX_HOURS"
  }
}

# Test 2: FAIL - GuardDuty detector with enable explicitly set to false
resource "aws_guardduty_detector" "fail_explicitly_disabled" {
  expect_failure = true
  attrs = {
    enable = false
    finding_publishing_frequency = "SIX_HOURS"
  }
}

# Test 3: PASS - GuardDuty detector without enable attribute (defaults to true)
resource "aws_guardduty_detector" "pass_enable_not_specified" {
  attrs = {
    finding_publishing_frequency = "ONE_HOUR"
  }
}
