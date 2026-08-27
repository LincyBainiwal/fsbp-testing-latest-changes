# Copyright IBM Corp. 2026

policytest {
    targets = [
        "s3-account-level-public-access-blocks-periodic.policy.hcl"
    ]
}

# Test 1: Pass - All four settings enabled
resource "aws_s3_account_public_access_block" "pass_all_settings_enabled" {
  attrs = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Test 2: Fail - block_public_acls disabled
resource "aws_s3_account_public_access_block" "fail_block_public_acls_disabled" {
  expect_failure = true
  attrs = {
    block_public_acls       = false
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Test 3: Fail - block_public_policy disabled
resource "aws_s3_account_public_access_block" "fail_block_public_policy_disabled" {
  expect_failure = true
  attrs = {
    block_public_acls       = true
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Test 4: Fail - ignore_public_acls disabled
resource "aws_s3_account_public_access_block" "fail_ignore_public_acls_disabled" {
  expect_failure = true
  attrs = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = false
    restrict_public_buckets = true
  }
}

# Test 5: Fail - restrict_public_buckets disabled
resource "aws_s3_account_public_access_block" "fail_restrict_public_buckets_disabled" {
  expect_failure = true
  attrs = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = false
  }
}

# Test 6: Fail - All settings disabled
resource "aws_s3_account_public_access_block" "fail_all_settings_disabled" {
  expect_failure = true
  attrs = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
  }
}

# Test 7: Fail - Multiple settings disabled
resource "aws_s3_account_public_access_block" "fail_multiple_settings_disabled" {
  expect_failure = true
  attrs = {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

# Test 8: Pass - Settings not configured (defaults to false)
resource "aws_s3_account_public_access_block" "fail_settings_not_configured" {
  attrs = {}
}