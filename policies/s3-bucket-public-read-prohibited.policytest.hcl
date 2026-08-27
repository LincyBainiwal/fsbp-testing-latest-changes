# Copyright IBM Corp. 2026

policytest {
    targets = [
        "s3-bucket-public-read-prohibited.policy.hcl"
    ]
}

# Test 1: Pass - aws_s3_bucket_public_access_block with all blocking settings enabled
resource "aws_s3_bucket_public_access_block" "pass_all_settings_enabled" {
  attrs = {
    bucket = "example-bucket"
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  }
}

# Test 2: Fail - aws_s3_bucket_public_access_block with only block_public_acls enabled
resource "aws_s3_bucket_public_access_block" "fail_only_block_public_acls" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    block_public_acls = true
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
  }
}

# Test 3: Fail - aws_s3_bucket_public_access_block with only block_public_policy enabled
resource "aws_s3_bucket_public_access_block" "fail_only_block_public_policy" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    block_public_acls = false
    block_public_policy = true
    ignore_public_acls = false
    restrict_public_buckets = false
  }
}

# Test 4: Fail - aws_s3_bucket_public_access_block with three settings enabled
resource "aws_s3_bucket_public_access_block" "fail_three_settings_enabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = false
  }
}

# Test 5: Fail - aws_s3_bucket_public_access_block with two settings enabled
resource "aws_s3_bucket_public_access_block" "fail_two_settings_enabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = false
    restrict_public_buckets = false
  }
}

# Test 6: Fail - aws_s3_bucket_public_access_block with all blocking settings disabled
resource "aws_s3_bucket_public_access_block" "fail_all_settings_disabled" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
  }
}

# Test 7: Fail - aws_s3_bucket_public_access_block with no settings specified (defaults to false)
resource "aws_s3_bucket_public_access_block" "fail_no_settings_specified" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
  }
}

# Test 8: Pass - aws_s3_bucket_acl with acl set to 'private'
resource "aws_s3_bucket_acl" "pass_acl_private" {
  attrs = {
    bucket = "example-bucket"
    acl = "private"
  }
}

# Test 9: Pass - aws_s3_bucket_acl with acl set to 'bucket-owner-full-control'
resource "aws_s3_bucket_acl" "pass_acl_bucket_owner_full_control" {
  attrs = {
    bucket = "example-bucket"
    acl = "bucket-owner-full-control"
  }
}

# Test 10: Fail - aws_s3_bucket_acl with acl set to 'public-read'
resource "aws_s3_bucket_acl" "fail_acl_public_read" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    acl = "public-read"
  }
}

# Test 11: Fail - aws_s3_bucket_acl with acl set to 'public-read-write'
resource "aws_s3_bucket_acl" "fail_acl_public_read_write" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    acl = "public-read-write"
  }
}

# Test 12: Fail - aws_s3_bucket_acl with access_control_policy granting to AllUsers
resource "aws_s3_bucket_acl" "fail_access_control_policy_all_users" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    access_control_policy = [
      {
        grant = [
          {
            grantee = [
              {
                type = "Group"
                uri = "http://acs.amazonaws.com/groups/global/AllUsers"
              }
            ]
            permission = "READ"
          }
        ]
        owner = [
          {
            id = "owner-id"
          }
        ]
      }
    ]
  }
}

# Test 13: Pass - aws_s3_bucket_acl with access_control_policy granting to specific account
resource "aws_s3_bucket_acl" "pass_access_control_policy_specific_account" {
  attrs = {
    bucket = "example-bucket"
    access_control_policy = [
      {
        grant = [
          {
            grantee = [
              {
                type = "CanonicalUser"
                id = "specific-account-id"
              }
            ]
            permission = "READ"
          }
        ]
        owner = [
          {
            id = "owner-id"
          }
        ]
      }
    ]
  }
}
