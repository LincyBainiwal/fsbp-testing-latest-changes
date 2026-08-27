# Copyright IBM Corp. 2026

policytest {
    targets = [
        "s3-bucket-public-write-prohibited.policy.hcl"
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

# Test 8: Pass - aws_s3_bucket_acl with private canned ACL
resource "aws_s3_bucket_acl" "pass_private_acl" {
  attrs = {
    bucket = "example-bucket"
    acl = "private"
  }
}

# Test 9: Fail - aws_s3_bucket_acl with public-read-write canned ACL
resource "aws_s3_bucket_acl" "fail_public_read_write_acl" {
  expect_failure = true
  attrs = {
    bucket = "example-bucket"
    acl = "public-read-write"
  }
}

# Test 10: Fail - aws_s3_bucket_acl with access_control_policy granting WRITE to AllUsers
resource "aws_s3_bucket_acl" "fail_acp_write_all_users" {
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
            permission = "WRITE"
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

# Test 11: Fail - aws_s3_bucket_acl with access_control_policy granting FULL_CONTROL to AuthenticatedUsers
resource "aws_s3_bucket_acl" "fail_acp_full_control_authenticated" {
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
                uri = "http://acs.amazonaws.com/groups/global/AuthenticatedUsers"
              }
            ]
            permission = "FULL_CONTROL"
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
