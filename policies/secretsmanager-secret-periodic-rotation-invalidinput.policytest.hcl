# Copyright IBM Corp. 2026

policytest {
  targets = [
    "secretsmanager-secret-periodic-rotation.policy.hcl"
  ]
}

inputs {
    maxDaysSinceRotation = 181
}

# FAIL - Invalid maxDaysSinceRotation input outside allowed range (1-180)
resource "aws_secretsmanager_secret_rotation" "invalid_threshold_input" {
  expect_failure = true
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret-invalid-input"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 30
      }
    ]
  }
}
