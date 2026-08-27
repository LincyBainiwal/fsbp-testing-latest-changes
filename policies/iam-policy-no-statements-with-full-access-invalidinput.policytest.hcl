# Copyright IBM Corp. 2026

# Tests with an invalid excludePermissionBoundaryPolicy input value.

policytest {
  targets = ["iam-policy-no-statements-with-full-access.policy.hcl"]
}

inputs {
  excludePermissionBoundaryPolicy = "maybe"
}

# FAIL - input must be "true" or "false"
resource "aws_iam_policy" "invalid_exclude_permission_boundary_input" {
  expect_failure = true
  attrs = {
    arn    = "arn:aws:iam::123456789012:policy/invalid-exclude-input-policy"
    name   = "invalid-exclude-input-policy"
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"SpecificAction\",\"Effect\":\"Allow\",\"Action\":\"ec2:DescribeInstances\",\"Resource\":\"*\"}]}"
  }
}
