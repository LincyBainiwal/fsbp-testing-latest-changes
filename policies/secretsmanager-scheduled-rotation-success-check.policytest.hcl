# Copyright IBM Corp. 2026

policytest {
  targets = ["secretsmanager-scheduled-rotation-success-check.policy.hcl"]
}

# ---------- Companion aws_secretsmanager_secret resources ----------

resource "aws_secretsmanager_secret" "secret_auto_days" {
  attrs = {
    name = "my-secret"
    arn  = "my-secret"
  }
}

resource "aws_secretsmanager_secret" "secret_schedule_expr" {
  attrs = {
    name = "my-scheduled-secret"
    arn  = "my-scheduled-secret"
  }
}

resource "aws_secretsmanager_secret" "secret_both" {
  attrs = {
    name = "my-secret-both"
    arn  = "my-secret-both"
  }
}

resource "aws_secretsmanager_secret" "secret_empty_rules" {
  expect_failure = true
  attrs = {
    name = "my-secret-empty-rules"
    arn  = "my-secret-empty-rules"
  }
}

resource "aws_secretsmanager_secret" "secret_no_schedule" {
  expect_failure = true
  attrs = {
    name = "my-secret-no-schedule"
    arn  = "my-secret-no-schedule"
  }
}

resource "aws_secretsmanager_secret" "secret_too_long_window" {
  expect_failure = true
  attrs = {
    name = "my-secret-too-long"
    arn  = "my-secret-too-long"
  }
}

# Additional: FAIL - secret has no associated rotation resource
resource "aws_secretsmanager_secret" "secret_no_rotation" {
  expect_failure = true
  attrs = {
    name = "my-secret-no-rotation"
    arn  = "my-secret-no-rotation"
  }
}

# ---------- Rotation resources ----------

# Test 1: PASS - automatically_after_days within limit; secret exists
resource "aws_secretsmanager_secret_rotation" "pass_auto_days" {
  attrs = {
    secret_id           = "my-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 30
        schedule_expression      = null
      }
    ]
  }
}

# Test 2: PASS - schedule_expression configured; secret exists
resource "aws_secretsmanager_secret_rotation" "pass_schedule_expr" {
  attrs = {
    secret_id           = "my-scheduled-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = null
        schedule_expression      = "rate(30 days)"
      }
    ]
  }
}

# Test 3: PASS - both schedule types; secret exists
resource "aws_secretsmanager_secret_rotation" "pass_both_schedule_types" {
  attrs = {
    secret_id           = "my-secret-both"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 30
        schedule_expression      = "rate(30 days)"
      }
    ]
  }
}

# Test 4: FAIL - secret_id does not reference any aws_secretsmanager_secret in the plan
resource "aws_secretsmanager_secret_rotation" "fail_orphan_rotation" {
  attrs = {
    secret_id           = "nonexistent-secret"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 30
        schedule_expression      = null
      }
    ]
  }
}

# Test 5: FAIL - empty rotation_rules
resource "aws_secretsmanager_secret_rotation" "fail_empty_rotation_rules" {
  attrs = {
    secret_id           = "my-secret-empty-rules"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules      = []
  }
}

# Test 6: FAIL - rotation_rules with neither automatically_after_days nor schedule_expression
resource "aws_secretsmanager_secret_rotation" "fail_no_schedule_in_rules" {
  attrs = {
    secret_id           = "my-secret-no-schedule"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = null
        schedule_expression      = null
      }
    ]
  }
}

# Test 7: FAIL - automatically_after_days exceeds 90
resource "aws_secretsmanager_secret_rotation" "fail_too_long_window" {
  attrs = {
    secret_id           = "my-secret-too-long"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 180
        schedule_expression      = null
      }
    ]
  }
}