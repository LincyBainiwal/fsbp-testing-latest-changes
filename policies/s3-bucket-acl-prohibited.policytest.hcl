# Copyright IBM Corp. 2026

policytest {
  targets = ["s3-bucket-acl-prohibited.policy.hcl"]
}

# Test 1: FAIL - bucket has an associated aws_s3_bucket_acl with canned acl "private"
resource "aws_s3_bucket" "fail_canned_private" {
  expect_failure = true
  attrs = {
    bucket = "legacy-bucket-1"
  }
}

resource "aws_s3_bucket_acl" "fail_canned_private_acl" {
  attrs = {
    bucket = "legacy-bucket-1"
    acl    = "private"
  }
}

# Test 2: FAIL - bucket has an associated aws_s3_bucket_acl with canned acl "public-read"
resource "aws_s3_bucket" "fail_canned_public_read" {
  expect_failure = true
  attrs = {
    bucket = "legacy-bucket-2"
  }
}

resource "aws_s3_bucket_acl" "fail_canned_public_read_acl" {
  attrs = {
    bucket = "legacy-bucket-2"
    acl    = "public-read"
  }
}

# Test 3: FAIL - bucket has an associated aws_s3_bucket_acl with access_control_policy grants
resource "aws_s3_bucket" "fail_acp_grants" {
  expect_failure = true
  attrs = {
    bucket = "legacy-bucket-3"
  }
}

resource "aws_s3_bucket_acl" "fail_acp_grants_acl" {
  attrs = {
    bucket = "legacy-bucket-3"
    access_control_policy = [{
      owner = [{ id = "owner-id" }]
      grant = [{
        grantee = [{
          id   = "grantee-id"
          type = "CanonicalUser"
        }]
        permission = "READ"
      }]
    }]
  }
}

# Test 4: PASS - bucket has no associated aws_s3_bucket_acl resource
resource "aws_s3_bucket" "pass_no_acl_resource" {
  attrs = {
    bucket = "compliant-bucket-1"
  }
}

# Test 5: PASS - bucket has an associated aws_s3_bucket_acl but it does not configure user access
resource "aws_s3_bucket" "pass_acl_resource_without_grants" {
  attrs = {
    bucket = "compliant-bucket-2"
  }
}

resource "aws_s3_bucket_acl" "pass_acl_resource_without_grants_acl" {
  attrs = {
    bucket = "compliant-bucket-2"
    acl    = ""
  }
}

# Test 6: FAIL - ACL set directly on the aws_s3_bucket resource (canned acl)
resource "aws_s3_bucket" "fail_direct_canned_acl" {
  expect_failure = true
  attrs = {
    bucket = "direct-acl-bucket"
    acl    = "private"
  }
}

# Test 7: FAIL - access_control_policy set directly on the aws_s3_bucket resource
resource "aws_s3_bucket" "fail_direct_acp" {
  expect_failure = true
  attrs = {
    bucket = "direct-acp-bucket"
    access_control_policy = [{
      owner = [{ id = "owner-id" }]
      grant = [{
        grantee    = [{ id = "grantee-id", type = "CanonicalUser" }]
        permission = "READ"
      }]
    }]
  }
}