# Copyright IBM Corp. 2026

policytest {
  targets = [
    "macie-status-check.policy.hcl"
  ]
}

resource "aws_macie2_account" "pass_macie_enabled" {
  attrs = {
    status = "ENABLED"
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
}

resource "aws_macie2_account" "fail_macie_paused" {
  expect_failure = true
  attrs = {
    status = "PAUSED"
    finding_publishing_frequency = "ONE_HOUR"
  }
}

resource "aws_macie2_account" "fail_status_missing" {
  expect_failure = true
  attrs = {
    finding_publishing_frequency = "SIX_HOURS"
  }
}

resource "aws_macie2_account" "fail_invalid_status" {
  expect_failure = true
  attrs = {
    status = "DISABLED"
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
}