# Copyright IBM Corp. 2026

policytest {
  targets = [
    "secretsmanager-secret-periodic-rotation.policy.hcl"
  ]
}

# Test 1: PASS - Rotation enabled with 30 days frequency (well within default 90)
resource "aws_secretsmanager_secret_rotation" "compliant_30d" {
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 30
      }
    ]
  }
}

# Test 2: PASS - Rotation enabled with 90 days frequency (boundary case at default)
resource "aws_secretsmanager_secret_rotation" "compliant_90d" {
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 90
      }
    ]
  }
}

# Test 3: PASS - Rotation enabled with 1 day frequency (minimum)
resource "aws_secretsmanager_secret_rotation" "compliant_1d" {
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 1
      }
    ]
  }
}

# Test 4: FAIL - Rotation frequency exceeds default 90 days
resource "aws_secretsmanager_secret_rotation" "non_compliant_120d" {
  expect_failure = true
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 120
      }
    ]
  }
}

# FAIL - automatically_after_days is missing (schedule_expression only).
# Isolated to its own file to avoid cty mixed-tuple type mismatch with other fixtures.
resource "aws_secretsmanager_secret_rotation" "missing_auto_days" {
  expect_failure = true
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        schedule_expression = "rate(30 days)"
      }
    ]
  }
}
