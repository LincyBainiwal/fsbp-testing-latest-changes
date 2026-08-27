# Copyright IBM Corp. 2026

policytest {
  targets = [
    "s3-lifecycle-policy-check.policy.hcl"
  ]
}

# Test 1: Lifecycle configuration with enabled rule and transition action (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "valid_lifecycle" {
  attrs = {
    bucket = "secure-bucket-with-lifecycle"
    rule = [
      {
        id     = "transition-rule"
        status = "Enabled"
        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
      }
    ]
  }
}

# Test 2: Lifecycle configuration with enabled rule and transition action (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_with_transition" {
  attrs = {
    bucket = "test-bucket-1"
    rule = [
      {
        id     = "glacier-transition"
        status = "Enabled"
        transition = [
          {
            days          = 90
            storage_class = "GLACIER"
          }
        ]
      }
    ]
  }
}

# Test 3: Lifecycle configuration with enabled rule and expiration action (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_with_expiration" {
  attrs = {
    bucket = "test-bucket-2"
    rule = [
      {
        id     = "expiration-rule"
        status = "Enabled"
        expiration = {
          days = 365
        }
      }
    ]
  }
}

# Test 4: Lifecycle configuration with no rules (FAIL)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_no_rules" {
  attrs = {
    bucket = "test-bucket-3"
    rule   = []
  }
}

# Test 7: Lifecycle configuration with disabled rules only (FAIL)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_disabled_rules" {
  attrs = {
    bucket = "test-bucket-4"
    rule = [
      {
        id     = "disabled-rule"
        status = "Disabled"
        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
      }
    ]
  }
}

# Test 8: Lifecycle configuration with rule but no actions (FAIL)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_no_actions" {
  attrs = {
    bucket = "test-bucket-5"
    rule = [
      {
        id     = "empty-rule"
        status = "Enabled"
      }
    ]
  }
}

# Test 9: Lifecycle configuration with valid storage classes (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_valid_storage_classes" {
  attrs = {
    bucket = "test-bucket-6"
    rule = [
      {
        id     = "multi-tier-transition"
        status = "Enabled"
        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          },
          {
            days          = 90
            storage_class = "GLACIER"
          },
          {
            days          = 180
            storage_class = "DEEP_ARCHIVE"
          }
        ]
      }
    ]
  }
}

# Test 10: Lifecycle configuration with INTELLIGENT_TIERING (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_intelligent_tiering" {
  attrs = {
    bucket = "test-bucket-7"
    rule = [
      {
        id     = "intelligent-tiering-rule"
        status = "Enabled"
        transition = [
          {
            days          = 0
            storage_class = "INTELLIGENT_TIERING"
          }
        ]
      }
    ]
  }
}

# Test 11: Lifecycle configuration with ONEZONE_IA (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_onezone_ia" {
  attrs = {
    bucket = "test-bucket-8"
    rule = [
      {
        id     = "onezone-ia-rule"
        status = "Enabled"
        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          }
        ]
      }
    ]
  }
}

# Test 12: Lifecycle configuration with GLACIER_IR (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_glacier_ir" {
  attrs = {
    bucket = "test-bucket-9"
    rule = [
      {
        id     = "glacier-ir-rule"
        status = "Enabled"
        transition = [
          {
            days          = 60
            storage_class = "GLACIER_IR"
          }
        ]
      }
    ]
  }
}

# Test 13: Lifecycle configuration with noncurrent version transition (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_noncurrent_transition" {
  attrs = {
    bucket = "test-bucket-10"
    rule = [
      {
        id     = "noncurrent-version-rule"
        status = "Enabled"
        noncurrent_version_transition = [
          {
            noncurrent_days = 30
            storage_class   = "STANDARD_IA"
          }
        ]
      }
    ]
  }
}

# Test 14: Lifecycle configuration with noncurrent version expiration (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_noncurrent_expiration" {
  attrs = {
    bucket = "test-bucket-11"
    rule = [
      {
        id     = "noncurrent-expiration-rule"
        status = "Enabled"
        noncurrent_version_expiration = {
          noncurrent_days = 90
        }
      }
    ]
  }
}

# Test 15: Lifecycle configuration with abort incomplete multipart upload (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_abort_multipart" {
  attrs = {
    bucket = "test-bucket-12"
    rule = [
      {
        id     = "abort-multipart-rule"
        status = "Enabled"
        abort_incomplete_multipart_upload = {
          days_after_initiation = 7
        }
      }
    ]
  }
}

# Test 16: Lifecycle configuration with invalid storage class (FAIL)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_invalid_storage_class" {
  attrs = {
    bucket = "test-bucket-13"
    rule = [
      {
        id     = "invalid-storage-class-rule"
        status = "Enabled"
        transition = [
          {
            days          = 30
            storage_class = "INVALID_CLASS"
          }
        ]
      }
    ]
  }
}

# Test 17: Lifecycle configuration with mixed enabled and disabled rules (PASS if at least one enabled)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_mixed_rules" {
  attrs = {
    bucket = "test-bucket-14"
    rule = [
      {
        id     = "enabled-rule"
        status = "Enabled"
        transition = [
          {
            days          = 30
            storage_class = "GLACIER"
          }
        ]
      },
      {
        id     = "disabled-rule"
        status = "Disabled"
        expiration = {
          days = 365
        }
      }
    ]
  }
}

# Test 18: Lifecycle configuration with multiple actions in one rule (PASS)
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_multiple_actions" {
  attrs = {
    bucket = "test-bucket-15"
    rule = [
      {
        id     = "comprehensive-rule"
        status = "Enabled"
        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          }
        ]
        expiration = {
          days = 365
        }
        noncurrent_version_transition = [
          {
            noncurrent_days = 30
            storage_class   = "GLACIER"
          }
        ]
        noncurrent_version_expiration = {
          noncurrent_days = 90
        }
      }
    ]
  }
}

# === Companion aws_s3_bucket resources (S3.13 targets the bucket itself) ===

resource "aws_s3_bucket" "secure_bucket_with_lifecycle" {
  attrs = { bucket = "secure-bucket-with-lifecycle" }
}

resource "aws_s3_bucket" "test_bucket_1" {
  attrs = { bucket = "test-bucket-1" }
}

resource "aws_s3_bucket" "test_bucket_2" {
  attrs = { bucket = "test-bucket-2" }
}

# Test 4: FAIL - lifecycle config exists but has no rules
resource "aws_s3_bucket" "test_bucket_3" {
  expect_failure = true
  attrs = { bucket = "test-bucket-3" }
}

# Test 7: FAIL - all rules disabled
resource "aws_s3_bucket" "test_bucket_4" {
  expect_failure = true
  attrs = { bucket = "test-bucket-4" }
}

# Test 8: FAIL - rule has no actions
resource "aws_s3_bucket" "test_bucket_5" {
  expect_failure = true
  attrs = { bucket = "test-bucket-5" }
}

resource "aws_s3_bucket" "test_bucket_6" {
  attrs = { bucket = "test-bucket-6" }
}

resource "aws_s3_bucket" "test_bucket_7" {
  attrs = { bucket = "test-bucket-7" }
}

resource "aws_s3_bucket" "test_bucket_8" {
  attrs = { bucket = "test-bucket-8" }
}

resource "aws_s3_bucket" "test_bucket_9" {
  attrs = { bucket = "test-bucket-9" }
}

resource "aws_s3_bucket" "test_bucket_10" {
  attrs = { bucket = "test-bucket-10" }
}

resource "aws_s3_bucket" "test_bucket_11" {
  attrs = { bucket = "test-bucket-11" }
}

resource "aws_s3_bucket" "test_bucket_12" {
  attrs = { bucket = "test-bucket-12" }
}

# Test 16: FAIL - invalid storage class in transition
resource "aws_s3_bucket" "test_bucket_13" {
  expect_failure = true
  attrs = { bucket = "test-bucket-13" }
}

resource "aws_s3_bucket" "test_bucket_14" {
  attrs = { bucket = "test-bucket-14" }
}

resource "aws_s3_bucket" "test_bucket_15" {
  attrs = { bucket = "test-bucket-15" }
}

# Additional: FAIL - bucket has no lifecycle configuration at all
resource "aws_s3_bucket" "no_lifecycle_bucket" {
  expect_failure = true
  attrs = { bucket = "no-lifecycle-bucket" }
}
