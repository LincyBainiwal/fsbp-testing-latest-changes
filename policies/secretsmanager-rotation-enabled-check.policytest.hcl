# Copyright IBM Corp. 2026

policytest {
  targets = [
    "secretsmanager-rotation-enabled-check.policy.hcl"
  ]
}

# Test 1: PASS - Secret with rotation enabled and 30-day frequency
resource "aws_secretsmanager_secret" "compliant_secret" {
  attrs = {
    arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:compliant-secret"
    name = "compliant-secret"
    id   = "compliant-secret-id"
  }
}

resource "aws_secretsmanager_secret_rotation" "compliant_secret" {
  attrs = {
    secret_id = "compliant-secret"
    rotation_rules = [
      {
        automatically_after_days = 30
      }
    ]
  }
}

# Test 2: FAIL - Secret without rotation enabled
resource "aws_secretsmanager_secret" "no_rotation_secret" {
  expect_failure = true
  attrs = {
    arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:no-rotation"
    name = "no-rotation-secret"
    id   = "no-rotation-secret-id"
  }
}

# Test 3: PASS - Secret with rotation at 120 days when no maximumAllowedRotationFrequency input is provided
resource "aws_secretsmanager_secret" "threshold_secret" {
  attrs = {
    arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:threshold"
    name = "threshold-secret"
    id   = "threshold-secret-id"
  }
}

resource "aws_secretsmanager_secret_rotation" "threshold_secret" {
  attrs = {
    secret_id = "threshold-secret"
    rotation_rules = [
      {
        automatically_after_days = 120
      }
    ]
  }
}

# Test 4: PASS - Secret matched by name (id/arn are unknown at plan time, so the policy matches only by name)
resource "aws_secretsmanager_secret" "matched_by_arn" {
  attrs = {
    arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:matched-arn"
    name = "matched-by-arn"
    id   = "matched-by-arn-id"
  }
}

resource "aws_secretsmanager_secret_rotation" "matched_by_arn" {
  attrs = {
    secret_id = "matched-by-arn"
    rotation_rules = [
      {
        automatically_after_days = 7
      }
    ]
  }
}
