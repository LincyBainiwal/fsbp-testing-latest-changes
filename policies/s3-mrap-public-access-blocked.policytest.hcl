# Copyright IBM Corp. 2026

policytest {
  targets = [
    "s3-mrap-public-access-blocked.policy.hcl"
  ]
}

# Test 1: PASS - No explicit public_access_block configuration (uses secure defaults)
resource "aws_s3control_multi_region_access_point" "pass_default_configuration" {
  attrs = {
    details = [
      {
        name = "example-mrap"
        region = [
          {
            bucket = "example-bucket-us-east-1"
          },
          {
            bucket = "example-bucket-us-west-2"
          }
        ]
      }
    ]
  }
}

# Test 2: PASS - All four settings explicitly set to true
resource "aws_s3control_multi_region_access_point" "pass_all_settings_true" {
  attrs = {
    details = [
      {
        name = "example-mrap"
        public_access_block = [
          {
            block_public_acls = true
            block_public_policy = true
            ignore_public_acls = true
            restrict_public_buckets = true
          }
        ]
        region = [
          {
            bucket = "example-bucket-us-east-1"
          }
        ]
      }
    ]
  }
}

# Test 3: PASS - Some settings omitted (using defaults)
resource "aws_s3control_multi_region_access_point" "pass_partial_explicit_configuration" {
  attrs = {
    details = [
      {
        name = "example-mrap"
        public_access_block = [
          {
            block_public_acls = true
            block_public_policy = true
          }
        ]
        region = [
          {
            bucket = "example-bucket-us-east-1"
          }
        ]
      }
    ]
  }
}

# Test 4: FAIL - block_public_acls set to false
resource "aws_s3control_multi_region_access_point" "fail_block_public_acls_false" {
  expect_failure = true
  attrs = {
    details = [
      {
        name = "example-mrap"
        public_access_block = [
          {
            block_public_acls = false
            block_public_policy = true
            ignore_public_acls = true
            restrict_public_buckets = true
          }
        ]
        region = [
          {
            bucket = "example-bucket-us-east-1"
          }
        ]
      }
    ]
  }
}

# Test 5: FAIL - block_public_policy set to false
resource "aws_s3control_multi_region_access_point" "fail_block_public_policy_false" {
  expect_failure = true
  attrs = {
    details = [
      {
        name = "example-mrap"
        public_access_block = [
          {
            block_public_acls = true
            block_public_policy = false
            ignore_public_acls = true
            restrict_public_buckets = true
          }
        ]
        region = [
          {
            bucket = "example-bucket-us-east-1"
          }
        ]
      }
    ]
  }
}

# Test 6: FAIL - ignore_public_acls set to false
resource "aws_s3control_multi_region_access_point" "fail_ignore_public_acls_false" {
  expect_failure = true
  attrs = {
    details = [
      {
        name = "example-mrap"
        public_access_block = [
          {
            block_public_acls = true
            block_public_policy = true
            ignore_public_acls = false
            restrict_public_buckets = true
          }
        ]
        region = [
          {
            bucket = "example-bucket-us-east-1"
          }
        ]
      }
    ]
  }
}

# Test 7: FAIL - restrict_public_buckets set to false
resource "aws_s3control_multi_region_access_point" "fail_restrict_public_buckets_false" {
  expect_failure = true
  attrs = {
    details = [
      {
        name = "example-mrap"
        public_access_block = [
          {
            block_public_acls = true
            block_public_policy = true
            ignore_public_acls = true
            restrict_public_buckets = false
          }
        ]
        region = [
          {
            bucket = "example-bucket-us-east-1"
          }
        ]
      }
    ]
  }
}

# Test 8: FAIL - Multiple settings set to false (shows all violations)
resource "aws_s3control_multi_region_access_point" "fail_multiple_violations" {
  expect_failure = true
  attrs = {
    details = [
      {
        name = "example-mrap"
        public_access_block = [
          {
            block_public_acls = false
            block_public_policy = false
            ignore_public_acls = true
            restrict_public_buckets = true
          }
        ]
        region = [
          {
            bucket = "example-bucket-us-east-1"
          }
        ]
      }
    ]
  }
}