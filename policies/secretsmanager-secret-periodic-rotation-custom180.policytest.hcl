# Copyright IBM Corp. 2026

policytest {
  targets = [
    "secretsmanager-secret-periodic-rotation.policy.hcl"
  ]
}

inputs  {
    maxDaysSinceRotation = 180
} 

# PASS - Custom maxDaysSinceRotation=180 allows 120 days
resource "aws_secretsmanager_secret_rotation" "compliant_custom_120d" {
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret-custom"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 120
      }
    ]
  }
}

# PASS - At exact upper threshold (180 == 180)
resource "aws_secretsmanager_secret_rotation" "compliant_at_max" {
  attrs = {
    secret_id           = "arn:aws:secretsmanager:us-east-1:123456789012:secret:test-secret-atmax"
    rotation_lambda_arn = "arn:aws:lambda:us-east-1:123456789012:function:rotation-function"
    rotation_rules = [
      {
        automatically_after_days = 180
      }
    ]
  }
}
