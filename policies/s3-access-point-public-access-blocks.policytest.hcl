# Copyright IBM Corp. 2026

policytest {
    targets = [
        "s3-access-point-public-access-blocks.policy.hcl"
    ]
}

# Test 1: Pass - All settings explicitly enabled
resource "aws_s3_access_point" "pass_all_settings_explicitly_enabled" {
  attrs = {
    bucket = "example-bucket"
    name = "compliant-access-point"
    public_access_block_configuration = [
      {
        block_public_acls = true
        block_public_policy = true
        ignore_public_acls = true
        restrict_public_buckets = true
      }
    ]
  }
}

# Test 2: Pass - No configuration specified (defaults to all true)
resource "aws_s3_access_point" "pass_no_configuration_defaults_to_true" {
  attrs = {
    bucket = "example-bucket"
    name = "default-access-point"
  }
}

# Test 3: Fail - block_public_acls disabled
resource "aws_s3_access_point" "fail_block_public_acls_disabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    name = "non-compliant-access-point-1"
    public_access_block_configuration = [
      {
        block_public_acls = false
        block_public_policy = true
        ignore_public_acls = true
        restrict_public_buckets = true
      }
    ]
  }
}

# Test 4: Fail - block_public_policy disabled
resource "aws_s3_access_point" "fail_block_public_policy_disabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    name = "non-compliant-access-point-2"
    public_access_block_configuration = [
      {
        block_public_acls = true
        block_public_policy = false
        ignore_public_acls = true
        restrict_public_buckets = true
      }
    ]
  }
}

# Test 5: Fail - ignore_public_acls disabled
resource "aws_s3_access_point" "fail_ignore_public_acls_disabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    name = "non-compliant-access-point-3"
    public_access_block_configuration = [
      {
        block_public_acls = true
        block_public_policy = true
        ignore_public_acls = false
        restrict_public_buckets = true
      }
    ]
  }
}

# Test 6: Fail - restrict_public_buckets disabled
resource "aws_s3_access_point" "fail_restrict_public_buckets_disabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    name = "non-compliant-access-point-4"
    public_access_block_configuration = [
      {
        block_public_acls = true
        block_public_policy = true
        ignore_public_acls = true
        restrict_public_buckets = false
      }
    ]
  }
}

# Test 7: Fail - Multiple settings disabled
resource "aws_s3_access_point" "fail_multiple_settings_disabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    name = "non-compliant-access-point-5"
    public_access_block_configuration = [
      {
        block_public_acls = false
        block_public_policy = false
        ignore_public_acls = true
        restrict_public_buckets = true
      }
    ]
  }
}