# Copyright IBM Corp. 2026

policytest {
  targets = ["kms-cmk-not-scheduled-for-deletion-2.policy.hcl"]
}

# Pass: deletion_window_in_days exactly at the required minimum (30)
resource "aws_kms_key" "compliant_minimum_window" {
  attrs = {
    description = "compliant-window-minimum"
    deletion_window_in_days = 30
    is_enabled = true
  }
}

# Pass: deletion_window_in_days omitted (provider default is 30)
resource "aws_kms_key" "compliant_default_window" {
  attrs = {
    description = "compliant-default-window"
    is_enabled = true
  }
}

# Fail: deletion_window_in_days below minimum (7, the provider's allowed minimum)
resource "aws_kms_key" "noncompliant_short_window" {
  expect_failure = true
  attrs = {
    description = "noncompliant-short-window"
    deletion_window_in_days = 7
    is_enabled = true
  }
}

# Fail: deletion_window_in_days just below minimum (29)
resource "aws_kms_key" "noncompliant_edge_window" {
  expect_failure = true
  attrs = {
    description = "noncompliant-edge-window"
    deletion_window_in_days = 29
    is_enabled = false
  }
}
