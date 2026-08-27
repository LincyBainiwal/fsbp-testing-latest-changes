# Copyright IBM Corp. 2026

policytest {
    targets = [
        "s3-bucket-level-public-access-prohibited.policy.hcl"
    ]
}

# Test 1: PASS - All four settings enabled
resource "aws_s3_bucket" "pass_all_settings_enabled" {
  attrs = {
    id = "my-secure-bucket"
    bucket = "my-secure-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "pass_all_settings_enabled" {
  skip = true
  attrs = {
    bucket = "my-secure-bucket"
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  }
}

# Test 2: FAIL - block_public_acls set to false
resource "aws_s3_bucket" "fail_block_public_acls_false" {
  expect_failure = true
  attrs = {
    id = "bucket-fail-acls"
    bucket = "bucket-fail-acls"
  }
}

resource "aws_s3_bucket_public_access_block" "fail_block_public_acls_false" {
  skip = true
  attrs = {
    bucket = "bucket-fail-acls"
    block_public_acls = false
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  }
}

# Test 3: FAIL - block_public_policy set to false
resource "aws_s3_bucket" "fail_block_public_policy_false" {
  expect_failure = true
  attrs = {
    id = "bucket-fail-policy"
    bucket = "bucket-fail-policy"
  }
}

resource "aws_s3_bucket_public_access_block" "fail_block_public_policy_false" {
  skip = true
  attrs = {
    bucket = "bucket-fail-policy"
    block_public_acls = true
    block_public_policy = false
    ignore_public_acls = true
    restrict_public_buckets = true
  }
}

# Test 4: FAIL - ignore_public_acls set to false
resource "aws_s3_bucket" "fail_ignore_public_acls_false" {
  expect_failure = true
  attrs = {
    id = "bucket-fail-ignore"
    bucket = "bucket-fail-ignore"
  }
}

resource "aws_s3_bucket_public_access_block" "fail_ignore_public_acls_false" {
  skip = true
  attrs = {
    bucket = "bucket-fail-ignore"
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = false
    restrict_public_buckets = true
  }
}

# Test 5: FAIL - restrict_public_buckets set to false
resource "aws_s3_bucket" "fail_restrict_public_buckets_false" {
  expect_failure = true
  attrs = {
    id = "bucket-fail-restrict"
    bucket = "bucket-fail-restrict"
  }
}

resource "aws_s3_bucket_public_access_block" "fail_restrict_public_buckets_false" {
  skip = true
  attrs = {
    bucket = "bucket-fail-restrict"
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = false
  }
}

# Test 6: FAIL - All settings set to false
resource "aws_s3_bucket" "fail_all_settings_false" {
  expect_failure = true
  attrs = {
    id = "bucket-fail-all"
    bucket = "bucket-fail-all"
  }
}

resource "aws_s3_bucket_public_access_block" "fail_all_settings_false" {
  skip = true
  attrs = {
    bucket = "bucket-fail-all"
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
  }
}

# Test 7: FAIL - Missing public access block configuration
resource "aws_s3_bucket" "fail_no_public_access_block" {
  expect_failure = true
  attrs = {
    id = "bucket-no-block"
    bucket = "bucket-no-block"
  }
}

# Test 8: FAIL - Public access block with missing attributes (defaults to false)
resource "aws_s3_bucket" "fail_missing_attributes" {
  expect_failure = true
  attrs = {
    id = "bucket-missing-attrs"
    bucket = "bucket-missing-attrs"
  }
}

resource "aws_s3_bucket_public_access_block" "fail_missing_attributes" {
  skip = true
  attrs = {
    bucket = "bucket-missing-attrs"
  }
}

# Test 9: FAIL - Multiple settings false
resource "aws_s3_bucket" "fail_multiple_false" {
  expect_failure = true
  attrs = {
    id = "bucket-multiple-fail"
    bucket = "bucket-multiple-fail"
  }
}

resource "aws_s3_bucket_public_access_block" "fail_multiple_false" {
  skip = true
  attrs = {
    bucket = "bucket-multiple-fail"
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = true
    restrict_public_buckets = true
  }
}
