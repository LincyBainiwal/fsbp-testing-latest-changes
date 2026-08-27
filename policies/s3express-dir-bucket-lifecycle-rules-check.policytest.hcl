# Copyright IBM Corp. 2026

policytest {
  targets = [
    "s3express-dir-bucket-lifecycle-rules-check.policy.hcl"
  ]
}

# Test 1: PASS - Enabled rule with expiration
resource "aws_s3_bucket_lifecycle_configuration" "pass_expiration" {
  attrs = {
    bucket = "my-dir-bucket--usw2-az1--x-s3"
    rule = [{
      id     = "expire-old-objects"
      status = "Enabled"
      expiration = [{
        days = 90
      }]
    }]
  }
}

# Test 2: PASS - Enabled rule with abort_incomplete_multipart_upload
resource "aws_s3_bucket_lifecycle_configuration" "pass_multipart" {
  attrs = {
    bucket = "multipart-bucket--usw2-az1--x-s3"
    rule = [{
      id     = "cleanup-incomplete-uploads"
      status = "Enabled"
      abort_incomplete_multipart_upload = [{
        days_after_initiation = 7
      }]
    }]
  }
}

# Test 3: PASS - Multiple enabled rules
resource "aws_s3_bucket_lifecycle_configuration" "pass_multiple_rules" {
  attrs = {
    bucket = "multi-rule-bucket--usw2-az1--x-s3"
    rule = [
      {
        id     = "expire-old-objects"
        status = "Enabled"
        expiration = [{
          days = 90
        }]
      },
      {
        id     = "cleanup-incomplete-uploads"
        status = "Enabled"
        abort_incomplete_multipart_upload = [{
          days_after_initiation = 7
        }]
      },
    ]
  }
}

# Test 4: PASS - One enabled + one disabled rule (enabled with an action is enough)
resource "aws_s3_bucket_lifecycle_configuration" "pass_mixed_rules" {
  attrs = {
    bucket = "mixed-bucket--usw2-az1--x-s3"
    rule = [
      {
        id     = "enabled-rule"
        status = "Enabled"
        expiration = [{
          days = 30
        }]
      },
      {
        id     = "disabled-rule"
        status = "Disabled"
        expiration = [{
          days = 60
        }]
      },
    ]
  }
}

# Test 5: FAIL - All rules disabled
resource "aws_s3_bucket_lifecycle_configuration" "fail_disabled_rules" {
  attrs = {
    bucket = "disabled-rules-bucket--usw2-az1--x-s3"
    rule = [{
      id     = "disabled-expiration"
      status = "Disabled"
      expiration = [{
        days = 90
      }]
    }]
  }
}

# Test 6: FAIL - Multiple disabled rules only
resource "aws_s3_bucket_lifecycle_configuration" "fail_only_disabled" {
  attrs = {
    bucket = "only-disabled-bucket--usw2-az1--x-s3"
    rule = [
      {
        id     = "disabled-rule-1"
        status = "Disabled"
        expiration = [{
          days = 30
        }]
      },
      {
        id     = "disabled-rule-2"
        status = "Disabled"
        abort_incomplete_multipart_upload = [{
          days_after_initiation = 7
        }]
      },
    ]
  }
}

# Test 7: FAIL - No rules at all
resource "aws_s3_bucket_lifecycle_configuration" "fail_no_rules" {
  attrs = {
    bucket = "no-rules-bucket--usw2-az1--x-s3"
    rule   = []
  }
}

# Test 8: FAIL - Enabled rule but no supported action
resource "aws_s3_bucket_lifecycle_configuration" "fail_no_action" {
  attrs = {
    bucket = "no-action-bucket--usw2-az1--x-s3"
    rule = [{
      id     = "enabled-but-no-action"
      status = "Enabled"
    }]
  }
}

# === Companion aws_s3_directory_bucket resources (S3.25 targets the directory bucket) ===

resource "aws_s3_directory_bucket" "pass_expiration_bucket" {
  attrs = { bucket = "my-dir-bucket--usw2-az1--x-s3" }
}

resource "aws_s3_directory_bucket" "pass_multipart_bucket" {
  attrs = { bucket = "multipart-bucket--usw2-az1--x-s3" }
}

resource "aws_s3_directory_bucket" "pass_multiple_rules_bucket" {
  attrs = { bucket = "multi-rule-bucket--usw2-az1--x-s3" }
}

resource "aws_s3_directory_bucket" "pass_mixed_rules_bucket" {
  attrs = { bucket = "mixed-bucket--usw2-az1--x-s3" }
}

# Test 5: FAIL - all rules disabled
resource "aws_s3_directory_bucket" "fail_disabled_rules_bucket" {
  expect_failure = true
  attrs = { bucket = "disabled-rules-bucket--usw2-az1--x-s3" }
}

# Test 6: FAIL - only disabled rules
resource "aws_s3_directory_bucket" "fail_only_disabled_bucket" {
  expect_failure = true
  attrs = { bucket = "only-disabled-bucket--usw2-az1--x-s3" }
}

# Test 7: FAIL - lifecycle config exists but no rules
resource "aws_s3_directory_bucket" "fail_no_rules_bucket" {
  expect_failure = true
  attrs = { bucket = "no-rules-bucket--usw2-az1--x-s3" }
}

# Test 8: FAIL - enabled rule but no supported action
resource "aws_s3_directory_bucket" "fail_no_action_bucket" {
  expect_failure = true
  attrs = { bucket = "no-action-bucket--usw2-az1--x-s3" }
}

# Additional: FAIL - directory bucket has no lifecycle configuration at all
resource "aws_s3_directory_bucket" "fail_no_lifecycle_bucket" {
  expect_failure = true
  attrs = { bucket = "no-lifecycle-bucket--usw2-az1--x-s3" }
}
