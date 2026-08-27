# Copyright IBM Corp. 2026

policytest {
  targets = [
    "macie-auto-sensitive-data-discovery-check.policy.hcl"
  ]
}

# --------------- PASS cases ---------------

# Test 1: PASS - Macie enabled with finding_publishing_frequency configured
resource "aws_macie2_account" "pass_macie_enabled_with_frequency" {
  attrs = {
    status                       = "ENABLED"
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
}

# Test 2: PASS - Macie enabled without optional finding_publishing_frequency
resource "aws_macie2_account" "pass_macie_enabled_no_frequency" {
  attrs = {
    status = "ENABLED"
  }
}

# --------------- FAIL cases ---------------

# Test 3: FAIL - Macie status is PAUSED
resource "aws_macie2_account" "fail_macie_paused" {
  expect_failure = true
  attrs = {
    status                       = "PAUSED"
    finding_publishing_frequency = "ONE_HOUR"
  }
}

# Test 4: FAIL - Macie status explicitly DISABLED
resource "aws_macie2_account" "fail_macie_disabled" {
  expect_failure = true
  attrs = {
    status = "DISABLED"
  }
}

# --------------- FILTERED cases ---------------

# Test 5: FILTERED - No status attribute (filtered out, not evaluated)
# NOTE: This policy only validates Macie is enabled — it cannot validate
# automated sensitive data discovery (real Terraform provider gap).
resource "aws_macie2_account" "filtered_no_status" {
  attrs = {
    finding_publishing_frequency = "SIX_HOURS"
  }
}