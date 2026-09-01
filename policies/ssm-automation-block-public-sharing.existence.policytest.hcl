# Copyright IBM Corp. 2026

policytest {
  targets = [
    "ssm-automation-block-public-sharing.policy.hcl"
  ]
}

# FAIL - Only an unrelated SSM setting in the plan — the required
# public-sharing-permission setting is absent entirely.
resource "aws_ssm_service_setting" "fail_no_public_sharing_setting" {
  expect_failure = true
  attrs = {
    setting_id    = "/ssm/managed-instance/activation-tier"
    setting_value = "standard"
  }
}