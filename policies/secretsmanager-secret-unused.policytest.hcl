# Copyright IBM Corp. 2026

# Tests for tag-presence enforcement.

policytest {
  targets = ["secretsmanager-secret-unused.policy.hcl"]
}

# PASS - Secret with LastAccessed tag
resource "aws_secretsmanager_secret" "pass_with_last_accessed" {
  attrs = {
    name = "compliant-secret"
    tags = {
      "Environment"  = "production"
      "LastAccessed" = "2025-04-20T10:00:00Z"
      "CreatedDate"  = "2024-01-15T08:30:00Z"
    }
    recovery_window_in_days = 30
  }
}

# PASS - Secret with CreatedDate fallback only
resource "aws_secretsmanager_secret" "pass_with_created_date" {
  attrs = {
    name = "secret-with-created-date"
    tags = {
      "Owner"       = "platform-team"
      "CreatedDate" = "2025-04-25T14:30:00Z"
    }
    recovery_window_in_days = 7
  }
}

# FAIL - Secret without LastAccessed/CreatedDate tags
resource "aws_secretsmanager_secret" "fail_without_tracking_tags" {
  expect_failure = true
  attrs = {
    name = "secret-without-tracking-tags"
    tags = {
      "Environment" = "staging"
    }
    recovery_window_in_days = 30
  }
}

# FAIL - Secret with empty tags map
resource "aws_secretsmanager_secret" "fail_with_empty_tags" {
  expect_failure = true
  attrs = {
    name                    = "secret-empty-tags"
    tags                    = {}
    recovery_window_in_days = 30
  }
}
