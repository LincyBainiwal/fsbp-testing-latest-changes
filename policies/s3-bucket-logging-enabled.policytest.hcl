# Copyright IBM Corp. 2026

policytest {
  targets = [
    "s3-bucket-logging-enabled.policy.hcl"
  ]
}

# Test 1: PASS - bucket has logging with target_bucket and target_prefix
resource "aws_s3_bucket_logging" "logging_with_prefix" {
  attrs = {
    bucket        = "my-compliant-bucket"
    target_bucket = "my-log-bucket"
    target_prefix = "logs/"
  }
}

resource "aws_s3_bucket" "pass_with_prefix" {
  attrs = {
    bucket = "my-compliant-bucket"
  }
}

# Test 2: PASS - bucket has logging, target_prefix omitted
resource "aws_s3_bucket_logging" "logging_no_prefix" {
  attrs = {
    bucket        = "no-prefix-bucket"
    target_bucket = "my-log-bucket"
  }
}

resource "aws_s3_bucket" "pass_no_prefix" {
  attrs = {
    bucket = "no-prefix-bucket"
  }
}

# Test 3: PASS - bucket has logging, target_prefix is empty string
resource "aws_s3_bucket_logging" "logging_empty_prefix" {
  attrs = {
    bucket        = "empty-prefix-bucket"
    target_bucket = "my-log-bucket"
    target_prefix = ""
  }
}

resource "aws_s3_bucket" "pass_empty_prefix" {
  attrs = {
    bucket = "empty-prefix-bucket"
  }
}

# Test 4: FAIL - bucket has no associated aws_s3_bucket_logging resource
resource "aws_s3_bucket" "fail_no_logging" {
  expect_failure = true
  attrs = {
    bucket = "fail-no-logging"
  }
}

# Test 5: FAIL - bucket has logging but target_bucket is empty
resource "aws_s3_bucket_logging" "logging_empty_target" {
  attrs = {
    bucket        = "fail-empty-target"
    target_bucket = ""
  }
}

resource "aws_s3_bucket" "fail_empty_target" {
  expect_failure = true
  attrs = {
    bucket = "fail-empty-target"
  }
}
