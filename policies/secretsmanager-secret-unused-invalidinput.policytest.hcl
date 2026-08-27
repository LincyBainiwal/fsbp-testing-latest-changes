# Copyright IBM Corp. 2026

# Invalid unusedForDays parameter input.

policytest {
  targets = ["secretsmanager-secret-unused.policy.hcl"]
}

inputs {
  unusedForDays = 366
}

# FAIL - unusedForDays outside allowed range (1-365)
resource "aws_secretsmanager_secret" "invalid_threshold_secret" {
  expect_failure = true
  attrs = {
    name = "invalid-threshold-secret"
    tags = {
      "LastAccessed" = "2025-01-01T00:00:00Z"
    }
    recovery_window_in_days = 30
  }
}
