# Copyright IBM Corp. 2026

policytest {
  targets = [
    "secretsmanager-rotation-enabled-check.policy.hcl"
  ]
}

# Test: PASS - Secret with rotation enabled via schedule_expression only (no automatically_after_days).
# When automatically_after_days is unset the frequency check has nothing to compare against; rotation
# is still considered enabled.
resource "aws_secretsmanager_secret" "rotation_schedule_only" {
  attrs = {
    arn  = "arn:aws:secretsmanager:us-east-1:123456789012:secret:no-freq"
    name = "rotation-schedule-only"
    id   = "rotation-schedule-only-id"
  }
}

resource "aws_secretsmanager_secret_rotation" "rotation_schedule_only" {
  attrs = {
    secret_id = "rotation-schedule-only"
    rotation_rules = [
      {
        schedule_expression = "rate(30 days)"
      }
    ]
  }
}
